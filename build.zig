const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{});
    const libexternals = b.addStaticLibrary(.{
        .name = "externals",
        .target = target,
        .optimize = optimize,
    });
    libexternals.linkLibCpp();
    libexternals.addCSourceFiles(.{
        .root = upstream.path("externals"),
        .files = &libexternals_src,
        .flags = &.{},
    });
    libexternals.installHeader(
        upstream.path("externals/tinyxml2/tinyxml2.h"),
        "tinyxml2.h",
    );
    libexternals.addIncludePath(upstream.path("externals/tinyxml2"));
    libexternals.installHeader(
        upstream.path("externals/simplecpp/simplecpp.h"),
        "simplecpp.h",
    );
    libexternals.addIncludePath(upstream.path("externals/simplecpp"));
    libexternals.installHeader(
        upstream.path("externals/picojson/picojson.h"),
        "picojson.h",
    );

    const libcppcheck = b.addStaticLibrary(.{
        .name = "cppcheck",
        .target = target,
        .optimize = optimize,
    });
    libcppcheck.linkLibrary(libexternals);
    libcppcheck.linkLibCpp();
    libcppcheck.addCSourceFiles(.{
        .root = upstream.path("lib"),
        .files = &libcppcheck_src,
        .flags = &.{},
    });
    libcppcheck.addIncludePath(upstream.path("lib"));
    libcppcheck.installHeadersDirectory(upstream.path("lib"), "", .{});

    const exe = b.addExecutable(.{
        .name = "cppcheck",
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibCpp();
    exe.addCSourceFiles(.{
        .root = upstream.path("cli"),
        .files = &cppcheck_src,
        .flags = &.{},
    });
    exe.addIncludePath(upstream.path("cli"));
    exe.linkLibrary(libcppcheck);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = upstream.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = upstream.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

const libexternals_src = [_][]const u8{
    "tinyxml2/tinyxml2.cpp",
    "simplecpp/simplecpp.cpp",
};

const libcppcheck_src = [_][]const u8{
    "addoninfo.cpp",
    "analyzerinfo.cpp",
    "astutils.cpp",
    "check.cpp",
    "check64bit.cpp",
    "checkassert.cpp",
    "checkautovariables.cpp",
    "checkbool.cpp",
    "checkboost.cpp",
    "checkbufferoverrun.cpp",
    "checkclass.cpp",
    "checkcondition.cpp",
    "checkers.cpp",
    "checkersreport.cpp",
    "checkexceptionsafety.cpp",
    "checkfunctions.cpp",
    "checkinternal.cpp",
    "checkio.cpp",
    "checkleakautovar.cpp",
    "checkmemoryleak.cpp",
    "checknullpointer.cpp",
    "checkother.cpp",
    "checkpostfixoperator.cpp",
    "checksizeof.cpp",
    "checkstl.cpp",
    "checkstring.cpp",
    "checktype.cpp",
    "checkuninitvar.cpp",
    "checkunusedfunctions.cpp",
    "checkunusedvar.cpp",
    "checkvaarg.cpp",
    "clangimport.cpp",
    "color.cpp",
    "cppcheck.cpp",
    "ctu.cpp",
    "errorlogger.cpp",
    "errortypes.cpp",
    "forwardanalyzer.cpp",
    "fwdanalysis.cpp",
    "importproject.cpp",
    "infer.cpp",
    "keywords.cpp",
    "library.cpp",
    "mathlib.cpp",
    "path.cpp",
    "pathanalysis.cpp",
    "pathmatch.cpp",
    "platform.cpp",
    "preprocessor.cpp",
    "programmemory.cpp",
    "reverseanalyzer.cpp",
    "settings.cpp",
    "summaries.cpp",
    "suppressions.cpp",
    "symboldatabase.cpp",
    "templatesimplifier.cpp",
    "timer.cpp",
    "token.cpp",
    "tokenize.cpp",
    "tokenlist.cpp",
    "utils.cpp",
    "valueflow.cpp",
    "vfvalue.cpp",
};

const cppcheck_src = [_][]const u8{
    "cmdlineparser.cpp",
    "cppcheckexecutor.cpp",
    "cppcheckexecutorseh.cpp",
    "executor.cpp",
    "filelister.cpp",
    "main.cpp",
    "processexecutor.cpp",
    "signalhandler.cpp",
    "singleexecutor.cpp",
    "stacktrace.cpp",
    "threadexecutor.cpp",
};
