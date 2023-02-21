#! /bin/sh

zig_version="0.10.1"
zig="zig-windows-x86_64-$zig_version"

if [ ! -e "$zig/zig.exe" ]; then
	wget "https://ziglang.org/download/$zig_version/$zig.zip"
	tar xf "$zig.tar.xz"
fi

"$zig/zig.exe" build -Drelease-fast -Dtarget=x86_64-windows-msvc
"$zig/zig.exe" build -Drelease-fast -Dtarget=x86_64-macos
"$zig/zig.exe" build -Drelease-fast -Dtarget=aarch64-macos
"$zig/zig.exe" build -Drelease-fast -Dtarget=x86_64-linux-musl
