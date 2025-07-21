const std = @import("std");

const InstructionType = enum {
    A_INSTRUCTION,
    C_INSTRUCTION,
    L_INSTRUCTION,
    CONSTANT,
};
pub const Parser = struct {
    // parse line by line..
    reader: std.io.BufferedReader(std.fs.File.Reader),
    line_buffer: [256]u8 = undefined,
    line_len: usize = 0,
    instruction_type: InstructionType = .CONSTANT,
    symbol_or_value: []u8 = "", // for A-Instruction / L-Instruction

    current_dest: ?[]const u8 = null,
    current_comp: ?[]const u8 = null,
    current_jump: ?[]const u8 = null,

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, file: std.fs.File) Parser {
        return Parser{
            .reader = std.io.bufferedReader(file.reader()),
            .allocator = allocator,
        };
    }

    pub fn hasMoreLines() bool {}
    pub fn instructionType(self: Parser) InstructionType {
        return self.instruction_type;
    }

    pub fn advance(self: *Parser) !void {
        while (1) {
            // get a line from file & stores it to `line_buffer`
            self.line_len = self.reader.readUntilDelimiterOrEof(&self.line_buffer, '\n') orelse {
                self.instruction_type = .CONSTANT;
                return;
            };

            // remove comment & space of parsing line
            var line = self.line_buffer[0..self.line_len];

            if (std.mem.indexOf(u8, line, "//")) |idx| {
                line = line[0..idx];
            }

            line = std.mem.trim(u8, line, " \t\r\n");

            if (line.len == 0) continue;

            // initialize
            self.symbol_or_value = "";
            self.current_dest = null;
            self.current_comp = null;
            self.current_jump = null;
        }
    }
    pub fn dest(self: Parser) ?[]const u8 {
        std.debug.assert(self.instruction_type == InstructionType.C_INSTRUCTION);
        return self.current_dest;
    }

    pub fn comp(self: Parser) ?[]const u8 {
        std.debug.assert(self.instruction_type == InstructionType.C_INSTRUCTION);
        return self.current_comp;
    }

    pub fn jump(self: Parser) ?[]const u8 {
        std.debug.assert(self.instruction_type == InstructionType.C_INSTRUCTION);
        return self.current_jump;
    }
};

pub fn parse(input: std.fs.File) void {
    const parser = Parser{ .input = input };

    // while ()
}
