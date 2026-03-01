#! /bin/sh

zig_version="0.15.2"
zig="zig-x86_64-windows-$zig_version"

if [ ! -e "$zig/zig.exe" ]; then
	wget "https://ziglang.org/download/$zig_version/$zig.zip"
	unzip "$zig.zip"
fi

"$zig/zig.exe" build -Doptimize=ReleaseFast -Dtarget=x86_64-windows-msvc
"$zig/zig.exe" build -Doptimize=ReleaseFast -Dtarget=aarch64-macos
"$zig/zig.exe" build -Doptimize=ReleaseFast -Dtarget=x86_64-macos
"$zig/zig.exe" build -Doptimize=ReleaseFast -Dtarget=x86_64-linux-musl
