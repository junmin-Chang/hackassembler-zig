const std = @import("std");
const eql = std.mem.eql;

const CodeError = error{
    InvalidInstruction,
    InvalidDestCode,
    InvalidCompCode,
    InvalidJumpCode,
};

pub const Codegen = struct {
    dest_code: [3]u8 = undefined,
    comp_code: [7]u8 = undefined,
    jump_code: [3]u8 = undefined,

    pub fn init() Codegen {
        return Codegen{};
    }

    pub fn dest(self: *Codegen, str_optional: ?[]const u8) !void {
        if (str_optional == null) {
            self.dest_code = "000".*;
            return;
        }

        const str = str_optional.?;

        if (eql(u8, str, "")) {
            self.dest_code = "000".*;
        } else if (eql(u8, str, "M")) {
            self.dest_code = "001".*;
        } else if (eql(u8, str, "D")) {
            self.dest_code = "010".*;
        } else if (eql(u8, str, "DM")) {
            self.dest_code = "011".*;
        } else if (eql(u8, str, "A")) {
            self.dest_code = "100".*;
        } else if (eql(u8, str, "AM")) {
            self.dest_code = "101".*;
        } else if (eql(u8, str, "AD")) {
            self.dest_code = "110".*;
        } else if (eql(u8, str, "ADM")) {
            self.dest_code = "111".*;
        } else {
            return CodeError.InvalidDestCode;
        }
    }

    pub fn comp(self: *Codegen, str_optional: ?[]const u8) !void {
        // 7-bit output
        if (str_optional == null) return CodeError.InvalidCompCode;

        const str = str_optional.?;
        if (eql(u8, str, "0")) {
            self.comp_code = "0101010".*;
        } else if (eql(u8, str, "1")) {
            self.comp_code = "0111111".*;
        } else if (eql(u8, str, "-1")) {
            self.comp_code = "0111010".*;
        } else if (eql(u8, str, "D")) {
            self.comp_code = "0001100".*;
        } else if (eql(u8, str, "A")) {
            self.comp_code = "0110000".*;
        } else if (eql(u8, str, "M")) {
            self.comp_code = "1110000".*;
        } else if (eql(u8, str, "!D")) {
            self.comp_code = "0001101".*;
        } else if (eql(u8, str, "!A")) {
            self.comp_code = "0110001".*;
        } else if (eql(u8, str, "!M")) {
            self.comp_code = "1110001".*;
        } else if (eql(u8, str, "-D")) {
            self.comp_code = "0001111".*;
        } else if (eql(u8, str, "-A")) {
            self.comp_code = "0110011".*;
        } else if (eql(u8, str, "-M")) {
            self.comp_code = "1110011".*;
        } else if (eql(u8, str, "D+1")) {
            self.comp_code = "0011111".*;
        } else if (eql(u8, str, "A+1")) {
            self.comp_code = "0110111".*;
        } else if (eql(u8, str, "M+1")) {
            self.comp_code = "1110111".*;
        } else if (eql(u8, str, "D-1")) {
            self.comp_code = "0001110".*;
        } else if (eql(u8, str, "A-1")) {
            self.comp_code = "0110010".*;
        } else if (eql(u8, str, "M-1")) {
            self.comp_code = "1110010".*;
        } else if (eql(u8, str, "D+A")) {
            self.comp_code = "0000010".*;
        } else if (eql(u8, str, "D+M")) {
            self.comp_code = "1000010".*;
        } else if (eql(u8, str, "D-A")) {
            self.comp_code = "0010011".*;
        } else if (eql(u8, str, "D-M")) {
            self.comp_code = "1010011".*;
        } else if (eql(u8, str, "A-D")) {
            self.comp_code = "0000111".*;
        } else if (eql(u8, str, "M-D")) {
            self.comp_code = "1000111".*;
        } else if (eql(u8, str, "D&A")) {
            self.comp_code = "0000000".*;
        } else if (eql(u8, str, "D&M")) {
            self.comp_code = "1000000".*;
        } else if (eql(u8, str, "D|A")) {
            self.comp_code = "0010101".*;
        } else if (eql(u8, str, "D|M")) {
            self.comp_code = "1010101".*;
        } else return CodeError.InvalidCompCode;
    }

    pub fn jump(self: *Codegen, str_optional: ?[]const u8) !void {
        // 3-bit output
        if (str_optional == null) {
            self.jump_code = "000".*;
            return;
        }

        const str = str_optional.?;

        if (eql(u8, str, "")) {
            self.jump_code = "000".*;
        } else if (eql(u8, str, "JGT")) {
            self.jump_code = "001".*;
        } else if (eql(u8, str, "JEQ")) {
            self.jump_code = "010".*;
        } else if (eql(u8, str, "JGE")) {
            self.jump_code = "011".*;
        } else if (eql(u8, str, "JLT")) {
            self.jump_code = "100".*;
        } else if (eql(u8, str, "JNE")) {
            self.jump_code = "101".*;
        } else if (eql(u8, str, "JLE")) {
            self.jump_code = "110".*;
        } else if (eql(u8, str, "JMP")) {
            self.jump_code = "111".*;
        } else return CodeError.InvalidJumpCode;
    }
};
