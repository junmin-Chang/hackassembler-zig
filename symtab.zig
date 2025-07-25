const std = @import("std");

const SymbolTableError = error{
    NotFoundSymbol,
};

pub const SymbolTable = struct {
    table: std.StringHashMap(u32),
    allocator: std.mem.Allocator,
    key_list: std.ArrayList([]const u8),
    var_value: u32 = 16,

    pub fn init(allocator: std.mem.Allocator) SymbolTable {
        return SymbolTable{
            .table = std.StringHashMap(u32).init(allocator),
            .allocator = allocator,
            .key_list = std.ArrayList([]const u8).init(allocator),
        };
    }

    pub fn insert_var_symbol(self: *SymbolTable, key: []const u8) !void {
        const key_copy = try self.allocator.dupe(u8, key);
        try self.key_list.append(key_copy);
        try self.table.put(key_copy, self.var_value);
        self.var_value += 1;
    }

    pub fn insert_label_symbol(self: *SymbolTable, key: []const u8, line: u32) !void {
        const key_copy = try self.allocator.dupe(u8, key);
        try self.key_list.append(key_copy);
        try self.table.put(key_copy, line);
    }

    pub fn get_value(self: SymbolTable, key: []const u8) SymbolTableError!u32 {
        const is_exist = self.table.contains(key);

        if (is_exist) {
            return self.table.get(key).?;
        } else {
            return SymbolTableError.NotFoundSymbol;
        }
    }

    pub fn deinit(self: *SymbolTable) void {
        self.table.deinit();
        for (self.key_list.items) |key| {
            self.allocator.free(key);
        }
        self.key_list.deinit();
    }
};
