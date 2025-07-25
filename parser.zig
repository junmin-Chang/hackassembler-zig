const std = @import("std");

const InstructionType = enum {
    A_INSTRUCTION,
    C_INSTRUCTION,
    L_INSTRUCTION,
    NO_INSTRUCTION,
};
pub const Parser = struct {
    // parse line by line..
    reader: std.io.BufferedReader(4096, std.fs.File.Reader),
    line_buffer: [4096]u8 = undefined,
    line_len: usize = 0,
    instruction_type: InstructionType = .NO_INSTRUCTION,
    symbol_or_value: []const u8 = "", // for A-Instruction / L-Instruction

    current_dest: ?[]const u8 = null,
    current_comp: ?[]const u8 = null,
    current_jump: ?[]const u8 = null,

    eof_reached: bool = false,
    current_line: u32 = 0,

    pub fn init(file: std.fs.File) Parser {
        return Parser{
            .reader = std.io.bufferedReader(file.reader()),
        };
    }
    pub fn hasMoreLines(self: *Parser) bool {
        return !self.eof_reached;
    }

    pub fn instructionType(self: Parser) InstructionType {
        return self.instruction_type;
    }

    pub fn advance(self: *Parser) !void {
        while (true) {
            // get a line from file & stores it to `line_buffer`
            if (try self.reader.reader().readUntilDelimiterOrEof(self.line_buffer[0..], '\n')) |line| {
                self.line_len = line.len;
            } else {
                self.eof_reached = true;
                self.instruction_type = .NO_INSTRUCTION;
                return;
            }
            // remove comment & space of parsing line
            var line: []const u8 = self.line_buffer[0..self.line_len];

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

            if (line[0] == '@') {
                // A-Instruction ! parse something like @xxx
                self.instruction_type = InstructionType.A_INSTRUCTION;
                self.symbol_or_value = line[1..];
                self.current_line += 1;
            } else if (line[0] == '(' and line[line.len - 1] == ')') {
                // L-Instruction ! parse something like (xxx) <-- which is label
                self.instruction_type = InstructionType.L_INSTRUCTION;
                self.symbol_or_value = line[1 .. line.len - 1];
            } else {
                // C-Instruction ! parse something like M=A+D
                // ..There are no spaces between operator & operand
                self.instruction_type = InstructionType.C_INSTRUCTION;

                const eq_idx = std.mem.indexOf(u8, line, "=");
                const semicolon_idx = std.mem.indexOf(u8, line, ";");
                var comp_idx: usize = 0;

                if (eq_idx) |idx| {
                    // dest=comp
                    self.current_dest = line[0..idx];
                    comp_idx = idx + 1;
                } else {
                    // comp;jump || comp
                    comp_idx = 0;
                }

                if (semicolon_idx) |idx| {
                    // comp;jump
                    self.current_comp = line[comp_idx..idx];
                    self.current_jump = line[idx + 1 ..];
                } else {
                    // comp
                    self.current_comp = line[comp_idx..];
                }

                self.current_line += 1;
            }
            break;
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

    pub fn symbol(self: Parser) []const u8 {
        std.debug.assert(self.instruction_type == InstructionType.A_INSTRUCTION or self.instruction_type == InstructionType.L_INSTRUCTION);
        return self.symbol_or_value;
    }
};
