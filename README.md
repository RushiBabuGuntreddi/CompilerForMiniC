Compiler for miniC

Course project — Prof. Rupesh Nasre | Aug–Nov 2024

This repository contains a working compiler for miniC (educational subset of C).

Highlights
- Lexing and parsing components (flex & bison sources).
- TAC (Three Address Code) generation modules.
- Backend code generation modules to produce x86 assembly from TAC.
- A basic block-level optimization pass (live-variable analysis and removal of dead TAC lines).

Structure
- lexing_parsing/: flex/yacc sources and a small set of testcases (valid/invalid).
- tac_generation/: flex/yacc sources used to produce TAC from parsed AST.
- codegen/: code generation sources that translate TAC to x86 (assembly) and helper scripts.
- optimizations/: sources implementing basic block and TAC-level optimizations.

How I want this to appear on the remote
- Only the compiler project files are included (the `CompilerForMiniC` folder).
- Lab folders, zip archives, and generated binaries are excluded.

Build & run (example, on Linux)
1. cd lexing_parsing
2. make
3. ./a.out < test.c

License
MIT
