# ggbuild - DIY build system

ggbuild is prebuilt lua/luafilesystem/ninja bins for Windows/macOS (x64)/Linux (static
linked musl).

To use lfs do `local lfs = require( "INTERNAL_LFS" )`

ggbuild itself is compiled with zig, cross-compiled from Windows to the
other platforms.

Lua sources have been modified to load lfs. Ninja sources have been
modified to build on macOS without a getopt dependency. Changes have
been marked with `// GGBUILD`.
