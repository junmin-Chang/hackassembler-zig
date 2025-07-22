const std = @import("std");
const Parser = @import("parser.zig").Parser;
const codegen = @import("codegen.zig");

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

    var parser = Parser.init(allocator, input_file);

    std.debug.print("Parsing .. {}\n", input_file);

    while (parser.hasMoreLines()) {
        try parser.advance();

        switch (parser.instruction_type) {
            .A_INSTRUCTION => {
                std.debug.print("A-Instruction : {s}\n", .{parser.symbol()});
            },
            .L_INSTRUCTION => {
                std.debug.print("L-Instruction: {s}\n", .{parser.symbol()});
            },
            .C_INSTRUCTION => {
                std.debug.print("C-Instruction: dest={?s}, comp={?s}, jump={?s}\n", .{
                    parser.dest(),
                    parser.comp(),
                    parser.jump(),
                });
            },
            .NO_INSTRUCTION => {
                std.debug.print("No Instruction\n", .{});
            },
        }
    }
    // make output_dir to store generated machine code;
    cwd.makeDir("output") catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    var output_dir = try cwd.openDir("output", .{});
    defer output_dir.close();

    const output_file = try output_dir.createFile("output.hack", .{});
    defer output_file.close();

    // parsing ... codegen ...

    std.debug.print("Successfully wrote nbytes.\n", .{});
}
