## Hack Assembler in Zig language

This project is a Hack Assembler implemented in the Zig programming language, based on the specification from The Elements of Computing Systems (Nand2Tetris).

While there are already many Hack assemblers available in various languages, I noticed there weren’t written in Zig...maybe?  So I decided to build one myself.

I wrote all the code without using generative AI, *as a way to challenge myself* and improve my understanding. 
As a result, some parts of the code may look a bit rough or unconventional, but it was a meaningful experience, especially since this was my first time using Zig.


The codebase is organized into 4 modules:
- `assembler.zig` (aka main)
- `parser.zig`
- `codegen.zig`
- `symtab.zig`

As you guys know, Hack assembler is 2-pass assembler. So, we don't need to worry about `forward reference`.

During `pass_1`,
The assembler scans the entire source code to collect all label declarations (e.g., (LOOP)) and records their corresponding instruction addresses in a symbol table (symtab).
No actual machine code is generated in this pass—it's just about building the symbol table.


During `pass_2`,
The assembler translates each instruction (A- and C-instructions) into binary.
If it encounters a symbol (e.g., @LOOP), it looks it up in the symbol table created during the first pass.
For variables, if a symbol is not found in the table, it's treated as a new variable and assigned to the next available memory address starting at `16`.
