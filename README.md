# 🧩 Compiler for miniC

> **Course:** Compiler Construction (Aug–Nov 2024)  
> **Instructor:** Prof. Rupesh Nasre, IIT Madras  

---

## 🧠 Overview

This project was developed as part of the **Compiler Construction** course under Prof. Rupesh Nasre (Aug–Nov 2024) at IIT Madras.  
The primary goal was to build a fully functioning compiler for **miniC**, an educational subset of the C programming language, with components for **lexing**, **parsing**, **semantic analysis**, and **code generation**.

---

## 📂 Directory Structure

| Directory | Description |
|:--|:--|
| `codegen/` | Target assembly code generation |
| `lexing_parsing/` | Lexer, parser, and semantic checking |
| `optimizations/` | Three Address Code (TAC) optimization passes |
| `tac_generation/` | TAC (Three Address Code) generation modules |

---

## ⚙️ Features

- Implements complete lexing, parsing, and semantic analysis for miniC.  
- Generates TAC and applies basic block–level optimizations.  
- Converts optimized TAC to target assembly.  
- Validates correctness by comparing generated assembly output with original miniC program output.

---
