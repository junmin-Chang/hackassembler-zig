const std = @import("std");
const Parser = @import("parser.zig").Parser;
const Codegen = @import("codegen.zig").Codegen;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: ./assembler <filename>\n", .{});
        return error.MissingArgument;
    }

    const cwd = std.fs.cwd();

    var input_file = try cwd.openFile(args[1], .{});
    defer input_file.close();

    // make output_dir to store generated machine code;
    cwd.makeDir("output") catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    var output_dir = try cwd.openDir("output", .{});
    defer output_dir.close();

    const output_file = try output_dir.createFile("output.hack", .{});
    defer output_file.close();

    // initialize parser & codegen module
    var parser = Parser.init(allocator, input_file);
    var codegen = Codegen.init();

    while (parser.hasMoreLines()) {
        try parser.advance();

        switch (parser.instruction_type) {
            .A_INSTRUCTION => {
                // version 1 => @[only_numeric]
                // version 2 => @[numeric || alphabetic symbol]
                try codegen.gen_a_inst(parser.symbol());
                _ = try output_file.write(&codegen.a_code);
                _ = try output_file.write("\n");
            },
            .L_INSTRUCTION => {
                std.debug.print("L-Instruction: {s}\n", .{parser.symbol()});
                // symbol_table["name"] <==  current line + 1
            },
            .C_INSTRUCTION => {
                try codegen.dest(parser.dest());
                try codegen.comp(parser.comp());
                try codegen.jump(parser.jump());
                try codegen.gen_c_inst();

                _ = try output_file.write(&codegen.c_code);
                _ = try output_file.write("\n");
            },
            .NO_INSTRUCTION => {
                std.debug.print("No more Instruction\n", .{});
            },
        }
    }

    std.debug.print("Successfully wrote nbytes.\n", .{});
}
