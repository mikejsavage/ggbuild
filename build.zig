const std = @import("std");

pub fn build(b: *std.Build) !void {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();
    const gpa = gp.allocator();

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const a = arena.allocator();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const t = target.result;
    const windows = t.os.tag == .windows;

    var exe_suffix : []const u8 = "";
    var lua_os_name : []const u8 = "-DLUA_OS_NAME=\"Windows\"";
    if (t.os.tag == .macos) {
        exe_suffix = if (t.cpu.arch == .x86_64) ".macos.x64" else ".macos.arm64";
        lua_os_name = "-DLUA_OS_NAME=\"macOS\"";
    }
    else if (t.os.tag == .linux) {
        exe_suffix = ".linux";
        lua_os_name = "-DLUA_OS_NAME=\"Linux\"";
    }

    const lua_cflags : []const []const u8 = &.{
        lua_os_name,
        if (!windows) "-DLUA_USE_POSIX" else "",
    };

    const lua = b.addExecutable(.{
        .name = try std.fmt.allocPrint(a, "lua{s}", .{ exe_suffix }),
        .target = target,
        .optimize = optimize,
        .strip = !windows,
    });
    b.installArtifact(lua);
    lua.linkLibC();
    lua.addIncludePath(b.path("lua-5.4.4/src"));
    lua.addCSourceFiles(.{
        .files = &.{
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
        },
        .flags = lua_cflags,
    });

    const ninja = b.addExecutable(.{
        .name = try std.fmt.allocPrint(a, "ninja{s}", .{ exe_suffix }),
        .target = target,
        .optimize = optimize,
        .strip = !windows,
    });
    b.installArtifact(ninja);
    ninja.linkLibC();
    if (!windows) {
        ninja.linkLibCpp();
    }
    ninja.addCSourceFiles(.{
        .files = &.{
            "ninja-1.13.2/src/build.cc",
            "ninja-1.13.2/src/build_log.cc",
            "ninja-1.13.2/src/clean.cc",
            "ninja-1.13.2/src/clparser.cc",
            "ninja-1.13.2/src/debug_flags.cc",
            "ninja-1.13.2/src/depfile_parser.cc",
            "ninja-1.13.2/src/deps_log.cc",
            "ninja-1.13.2/src/disk_interface.cc",
            "ninja-1.13.2/src/dyndep.cc",
            "ninja-1.13.2/src/dyndep_parser.cc",
            "ninja-1.13.2/src/edit_distance.cc",
            "ninja-1.13.2/src/elide_middle.cc",
            "ninja-1.13.2/src/eval_env.cc",
            "ninja-1.13.2/src/getopt.c",
            "ninja-1.13.2/src/graph.cc",
            "ninja-1.13.2/src/graphviz.cc",
            "ninja-1.13.2/src/jobserver.cc",
            "ninja-1.13.2/src/json.cc",
            "ninja-1.13.2/src/lexer.cc",
            "ninja-1.13.2/src/line_printer.cc",
            "ninja-1.13.2/src/manifest_parser.cc",
            "ninja-1.13.2/src/metrics.cc",
            "ninja-1.13.2/src/missing_deps.cc",
            "ninja-1.13.2/src/ninja.cc",
            "ninja-1.13.2/src/parser.cc",
            "ninja-1.13.2/src/real_command_runner.cc",
            "ninja-1.13.2/src/state.cc",
            "ninja-1.13.2/src/status_printer.cc",
            "ninja-1.13.2/src/string_piece_util.cc",
            "ninja-1.13.2/src/util.cc",
            "ninja-1.13.2/src/version.cc",
        },
    });

    if (windows) {
        ninja.addCSourceFiles(.{
            .files = &.{
                "ninja-1.13.2/src/includes_normalize-win32.cc",
                "ninja-1.13.2/src/jobserver-win32.cc",
                "ninja-1.13.2/src/minidump-win32.cc",
                "ninja-1.13.2/src/msvc_helper-win32.cc",
                "ninja-1.13.2/src/msvc_helper_main-win32.cc",
                "ninja-1.13.2/src/subprocess-win32.cc",
                // "ninja-1.13.2/windows/ninja.manifest",
            },
        });
    }
    else {
        ninja.addCSourceFiles(.{
            .files = &.{
                "ninja-1.13.2/src/jobserver-posix.cc",
                "ninja-1.13.2/src/subprocess-posix.cc",
            },
        });
    }
}
