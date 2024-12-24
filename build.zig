const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const engine = b.addExecutable(.{
        .name = "engine",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });
    b.installArtifact(engine);

    const run_step = b.step("run", "");
    const run_engine = b.addRunArtifact(engine);
    run_step.dependOn(&run_engine.step);

    const test_exe = b.addTest(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/test.zig"),
    });

    const test_step = b.step("test", "");
    const run_test = b.addRunArtifact(test_exe);
    test_step.dependOn(&run_test.step);
}
