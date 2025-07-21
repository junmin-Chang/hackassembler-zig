const std = @import("std");
const parser = @import("parser.zig");
const codegen = @import("codegen.zig");

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: ./assembler <filename>\n", .{});
        return error.MissingArgument;
    }

    const cwd = std.fs.cwd();

    var input_file = try cwd.openFile(args[1], .{});
    defer input_file.close();

    std.debug.print("filename: {s}, file: {}", .{ args[1], input_file });

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
