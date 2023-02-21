const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();
    const gpa = gp.allocator();

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const a = arena.allocator();

    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    var exe_suffix : []const u8 = "";
    var lua_os_name : []const u8 = "-DLUA_OS_NAME=\"Windows\"";
    if (target.isDarwin()) {
        exe_suffix = if (target.getCpuArch().isX86()) ".macos.x64" else ".macos.arm64";
        lua_os_name = "-DLUA_OS_NAME=\"macOS\"";
    }
    else if (target.isLinux()) {
        exe_suffix = ".linux";
        lua_os_name = "-DLUA_OS_NAME=\"Linux\"";
    }

    const lua_cflags : []const []const u8 = &.{
        lua_os_name,
        if (!target.isWindows()) "-DLUA_USE_POSIX" else "",
    };

    const lua = b.addExecutable(try std.fmt.allocPrint(a, "lua{s}", .{ exe_suffix }), null);
    lua.setTarget(target);
    lua.setBuildMode(mode);
    lua.install();
    lua.strip = !target.isWindows();
    lua.linkLibC();
    lua.addIncludePath("lua-5.4.4/src");
    lua.addCSourceFiles(&.{
        "lua-5.4.4/src/lapi.c",
        "lua-5.4.4/src/lauxlib.c",
        "lua-5.4.4/src/lbaselib.c",
        "lua-5.4.4/src/lcode.c",
        "lua-5.4.4/src/lcorolib.c",
        "lua-5.4.4/src/lctype.c",
        "lua-5.4.4/src/ldblib.c",
        "lua-5.4.4/src/ldebug.c",
        "lua-5.4.4/src/ldo.c",
        "lua-5.4.4/src/ldump.c",
        "lua-5.4.4/src/lfunc.c",
        "lua-5.4.4/src/lgc.c",
        "lua-5.4.4/src/linit.c",
        "lua-5.4.4/src/liolib.c",
        "lua-5.4.4/src/llex.c",
        "lua-5.4.4/src/lmathlib.c",
        "lua-5.4.4/src/lmem.c",
        "lua-5.4.4/src/loadlib.c",
        "lua-5.4.4/src/lobject.c",
        "lua-5.4.4/src/lopcodes.c",
        "lua-5.4.4/src/loslib.c",
        "lua-5.4.4/src/lparser.c",
        "lua-5.4.4/src/lstate.c",
        "lua-5.4.4/src/lstring.c",
        "lua-5.4.4/src/lstrlib.c",
        "lua-5.4.4/src/ltable.c",
        "lua-5.4.4/src/ltablib.c",
        "lua-5.4.4/src/ltm.c",
        "lua-5.4.4/src/lua.c",
        "lua-5.4.4/src/lundump.c",
        "lua-5.4.4/src/lutf8lib.c",
        "lua-5.4.4/src/lvm.c",
        "lua-5.4.4/src/lzio.c",

        "luafilesystem-1_8_0/src/lfs.c",
    }, lua_cflags);

    const ninja = b.addExecutable(try std.fmt.allocPrint(a, "ninja{s}", .{ exe_suffix }), null);
    ninja.setTarget(target);
    ninja.setBuildMode(mode);
    ninja.install();
    ninja.strip = !target.isWindows();
    ninja.linkLibC();
    if (!target.isWindows()) {
        ninja.linkLibCpp();
    }
    ninja.addCSourceFiles(&.{
        "ninja-1.11.1/src/build_log.cc",
        "ninja-1.11.1/src/build.cc",
        "ninja-1.11.1/src/clean.cc",
        "ninja-1.11.1/src/clparser.cc",
        "ninja-1.11.1/src/depfile_parser.cc",
        "ninja-1.11.1/src/dyndep.cc",
        "ninja-1.11.1/src/dyndep_parser.cc",
        "ninja-1.11.1/src/debug_flags.cc",
        "ninja-1.11.1/src/deps_log.cc",
        "ninja-1.11.1/src/disk_interface.cc",
        "ninja-1.11.1/src/edit_distance.cc",
        "ninja-1.11.1/src/eval_env.cc",
        "ninja-1.11.1/src/getopt.c",
        "ninja-1.11.1/src/graph.cc",
        "ninja-1.11.1/src/graphviz.cc",
        "ninja-1.11.1/src/json.cc",
        "ninja-1.11.1/src/lexer.cc",
        "ninja-1.11.1/src/line_printer.cc",
        "ninja-1.11.1/src/manifest_parser.cc",
        "ninja-1.11.1/src/metrics.cc",
        "ninja-1.11.1/src/missing_deps.cc",
        "ninja-1.11.1/src/ninja.cc",
        "ninja-1.11.1/src/parser.cc",
        "ninja-1.11.1/src/state.cc",
        "ninja-1.11.1/src/status.cc",
        "ninja-1.11.1/src/string_piece_util.cc",
        "ninja-1.11.1/src/util.cc",
        "ninja-1.11.1/src/version.cc",
    }, &.{});

    if (target.isWindows()) {
        ninja.addCSourceFiles(&.{
            "ninja-1.11.1/src/includes_normalize-win32.cc",
            "ninja-1.11.1/src/minidump-win32.cc",
            "ninja-1.11.1/src/msvc_helper-win32.cc",
            "ninja-1.11.1/src/msvc_helper_main-win32.cc",
            "ninja-1.11.1/src/subprocess-win32.cc",
            // "ninja-1.11.1/windows/ninja.manifest",
        }, &.{});
    }
    else {
        ninja.addCSourceFiles(&.{ "ninja-1.11.1/src/subprocess-posix.cc" }, &.{});
    }
}
