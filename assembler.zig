const std = @import("std");
const Parser = @import("parser.zig").Parser;
const Codegen = @import("codegen.zig").Codegen;
const SymbolTable = @import("symtab.zig").SymbolTable;

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
    var parser = Parser.init(input_file);
    var codegen = Codegen.init();
    var symtab = SymbolTable.init(allocator);
    defer symtab.deinit();

    // written bytes while generating machine code (useless but useful sometimes)
    var nbytes: usize = 0;
    // 1-pass
    pass_1: while (parser.hasMoreLines()) {
        try parser.advance();

        // collect symbol
        switch (parser.instruction_type) {
            .L_INSTRUCTION => {
                // (LABEL)
                const symbol = parser.symbol();
                try symtab.add_entry(symbol, parser.current_line);
            },

            else => continue :pass_1,
        }
    }

    try input_file.seekTo(0);
    parser = Parser.init(input_file);
    // 2-pass

    pass_2: while (parser.hasMoreLines()) {
        try parser.advance();

        switch (parser.instruction_type) {
            .A_INSTRUCTION => {
                // @[numeric]
                const symbol = parser.symbol();
                if (std.ascii.isDigit(symbol[0])) {
                    try codegen.gen_a_inst(parser.symbol());
                    nbytes += try output_file.write(&codegen.a_code);
                    _ = try output_file.write("\n");
                } else {
                    // @[alphabetic]
                    if (symtab.contains(symbol)) {
                        const value = try symtab.get_address(symbol);
                        try codegen.gen_a_inst(value);
                        nbytes += try output_file.write(&codegen.a_code);
                        _ = try output_file.write("\n");
                    } else {
                        // insert symbol to table
                        try symtab.add_entry(symbol, null);
                        const value = try symtab.get_address(symbol);
                        try codegen.gen_a_inst(value);
                        nbytes += try output_file.write(&codegen.a_code);
                        _ = try output_file.write("\n");
                    }
                }
            },
            .L_INSTRUCTION => {
                continue :pass_2;
            },
            .C_INSTRUCTION => {
                try codegen.dest(parser.dest());
                try codegen.comp(parser.comp());
                try codegen.jump(parser.jump());
                try codegen.gen_c_inst();
                nbytes += try output_file.write(&codegen.c_code);
                _ = try output_file.write("\n");
            },
            .NO_INSTRUCTION => {
                std.debug.print("No more Instruction\n", .{});
            },
        }
    }
    std.debug.print("Successfully Assembled! => {d}Bytes written\n", .{nbytes});
}
