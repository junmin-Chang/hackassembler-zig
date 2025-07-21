const std = @import("std");
const parser = @import("parser.zig");
const codegen = @import("codegen.zig");

pub fn main() !void {
    const cwd = std.fs.cwd();

    // make output_dir to store generated machine code;
    cwd.makeDir("output") catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    var output_dir = try cwd.openDir("output", .{});
    defer output_dir.close();

    const file = try output_dir.createFile("output.hack", .{});
    defer file.close();

    // parsing ... codegen ...

    std.debug.print("Successfully wrote nbytes.\n", .{});
}
