const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{});
    const libexternals = b.addLibrary(.{
        .name = "externals",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    });
    libexternals.root_module.addCSourceFiles(.{
        .root = upstream.path("externals"),
        .files = &libexternals_src,
        .flags = &.{},
    });
    libexternals.installHeader(
        upstream.path("externals/tinyxml2/tinyxml2.h"),
        "tinyxml2.h",
    );
    libexternals.root_module.addIncludePath(upstream.path("externals/tinyxml2"));
    libexternals.installHeader(
        upstream.path("externals/simplecpp/simplecpp.h"),
        "simplecpp.h",
    );
    libexternals.root_module.addIncludePath(upstream.path("externals/simplecpp"));
    libexternals.installHeader(
        upstream.path("externals/picojson/picojson.h"),
        "picojson.h",
    );

    const libcppcheck = b.addLibrary(.{
        .name = "cppcheck",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    });
    libcppcheck.root_module.linkLibrary(libexternals);
    libcppcheck.root_module.addCSourceFiles(.{
        .root = upstream.path("lib"),
        .files = &libcppcheck_src,
        .flags = &.{},
    });
    libcppcheck.root_module.addIncludePath(upstream.path("lib"));
    libcppcheck.installHeadersDirectory(upstream.path("lib"), "", .{});

    const exe = b.addExecutable(.{
        .name = "cppcheck",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    });
    exe.root_module.addCSourceFiles(.{
        .root = upstream.path("cli"),
        .files = &cppcheck_src,
        .flags = &.{},
    });
    exe.root_module.addIncludePath(upstream.path("cli"));
    exe.root_module.linkLibrary(libcppcheck);
    b.installDirectory(.{
        .source_dir = upstream.path("cfg"),
        .install_dir = .{ .custom = "cfg" },
        .install_subdir = "",
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addPassthruArgs();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
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
