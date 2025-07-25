const std = @import("std");

const SymbolTableError = error{
    NotFoundSymbol,
    AlreadyExistsSymbol,
};

pub const SymbolTable = struct {
    table: std.StringHashMap(u32),
    allocator: std.mem.Allocator,
    key_list: std.ArrayList([]const u8),
    var_value: u32 = 16,

    pub fn init(allocator: std.mem.Allocator) SymbolTable {
        var self = SymbolTable{
            .table = std.StringHashMap(u32).init(allocator),
            .allocator = allocator,
            .key_list = std.ArrayList([]const u8).init(allocator),
        };

        self.table.put("R0", 0) catch @panic("symtab initial put failed..\n");
        self.table.put("R1", 1) catch @panic("symtab initial put failed..\n");
        self.table.put("R2", 2) catch @panic("symtab initial put failed..\n");
        self.table.put("R3", 3) catch @panic("symtab initial put failed..\n");
        self.table.put("R4", 4) catch @panic("symtab initial put failed..\n");
        self.table.put("R5", 5) catch @panic("symtab initial put failed..\n");
        self.table.put("R6", 6) catch @panic("symtab initial put failed..\n");
        self.table.put("R7", 7) catch @panic("symtab initial put failed..\n");
        self.table.put("R8", 8) catch @panic("symtab initial put failed..\n");
        self.table.put("R9", 9) catch @panic("symtab initial put failed..\n");
        self.table.put("R10", 10) catch @panic("symtab initial put failed..\n");
        self.table.put("R11", 11) catch @panic("symtab initial put failed..\n");
        self.table.put("R12", 12) catch @panic("symtab initial put failed..\n");
        self.table.put("R13", 13) catch @panic("symtab initial put failed..\n");
        self.table.put("R14", 14) catch @panic("symtab initial put failed..\n");
        self.table.put("R15", 15) catch @panic("symtab initial put failed..\n");

        self.table.put("SP", 0) catch @panic("symtab initial put failed..\n");
        self.table.put("LCL", 1) catch @panic("symtab initial put failed..\n");
        self.table.put("ARG", 2) catch @panic("symtab initial put failed..\n");
        self.table.put("THIS", 3) catch @panic("symtab initial put failed..\n");
        self.table.put("THAT", 4) catch @panic("symtab initial put failed..\n");
        self.table.put("SCREEN", 16384) catch @panic("symtab initial put failed..\n");
        self.table.put("KBD", 24576) catch @panic("symtab initial put failed..\n");

        return self;
    }

    pub fn addEntry(self: *SymbolTable, key: []const u8, value: ?u32) !void {
        if (self.contains(key)) {
            return SymbolTableError.AlreadyExistsSymbol;
        }

        const key_copy = try self.allocator.dupe(u8, key); // "@xxx" || (LABEL)?

        try self.key_list.append(key_copy);
        if (value == null) {
            // @xxx
            try self.table.put(key_copy, self.var_value);
            self.var_value += 1;
        } else {
            // (LABEL)
            try self.table.put(key_copy, value.?);
        }
    }

    pub fn contains(self: SymbolTable, key: []const u8) bool {
        return self.table.contains(key);
    }

    pub fn get_address(self: SymbolTable, key: []const u8) SymbolTableError!u32 {
        // check if key exists in hash table
        if (self.contains(key)) {
            return self.table.get(key).?;
        } else {
            // throw error if key doesn't exist in hash table
            return SymbolTableError.NotFoundSymbol;
        }
    }

    pub fn deinit(self: *SymbolTable) void {
        // free not only table but also entries in ArrayList(key_list)
        self.table.deinit();
        for (self.key_list.items) |key| {
            self.allocator.free(key);
        }
        self.key_list.deinit();
    }
};
