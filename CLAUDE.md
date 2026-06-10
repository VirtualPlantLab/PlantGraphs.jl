# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## General Guidelines

- Exploit `Revise` to amortize the cost of compilation time, which for Julia is
  quite high. This *requires* that you use the MCP server to avoid starting a
  new Julia session each time.

- Exploit Julia packages and macros for evaluating performance issues:
  `BenchmarkTools.jl` for micro-benchmarks, `Profile` for CPU profiling, and
  `Cthulhu.jl` for method analysis (or `@code_warntype`). These tools are in
  my global (fallback) environment.

- Use `Pkg.test()` for a final run only when ready to submit a pull request.

- Use the local `Project.toml` environment when available. Revise, TestEnv,
  Cthulhu, and some other developer-oriented tools are in my global (fallback)
  environment

- When adding new packages to a local project, also update the `[compat]`
  section of `Project.toml` to bound the version of the new dependency.
  After making edits to `Project.toml`, run `Pkg.resolve()`.
  Resolver errors sometimes indicate package conflict. `Pkg.update()` can fix such errors.

- Avoid being unnecessarily restrictive about method arguments. `f(A::Float64)`
  silently excludes `Float32`, dual numbers, and anything else that would work fine —
  the caller gets a confusing `MethodError` instead. Annotate only as specifically as
  the implementation requires.
