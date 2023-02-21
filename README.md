# ggbuild - DIY build system

ggbuild is prebuilt lua/luafilesystem/ninja bins for Windows/macOS
(universal amd64+x64)/Linux (static linked musl).

To use lfs do `local lfs = require( "INTERNAL_LFS" )`

ggbuild itself is compiled with zig, cross-compiled from Windows to the
other platforms.

Lua sources have been modified to load lfs and add a variable `os.name`
which is set to `"Windows"`/`"macOS"`/`"Linux"`. Ninja sources have been modified to
build on macOS without a getopt dependency. Changes have been marked
with `// GGBUILD`.

ducible.exe is from https://github.com/jasonwhite/ducible/releases

lipo.exe is from https://github.com/konoui/lipo/releases
