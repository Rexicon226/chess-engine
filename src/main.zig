const std = @import("std");
const Board = @import("Board.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    _ = allocator;

    const board = try Board.parseFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
    std.debug.print("board:\n{}\n", .{board});
}

fn loop() !void {
    var buffer: [4096]u8 = undefined;
    var stdin = std.io.getStdIn().reader();
    var stdout = std.io.getStdOut().writer();

    var board = Board.initZero();

    loop: while (true) {
        const line = try stdin.readUntilDelimiterOrEof(&buffer, '\n') orelse break :loop;
        var iter = std.mem.tokenizeScalar(u8, line, ' ');
        const base = iter.next() orelse continue;

        if (std.mem.eql(u8, base, "uci")) {
            try stdout.writeAll(
                \\id name ZigEngine
                \\id author David Rubin
                \\uciok
                \\
            );
            continue;
        }
        if (std.mem.eql(u8, base, "isready")) {
            try stdout.writeAll("readyok\n");
            continue;
        }
        if (std.mem.eql(u8, base, "debug")) {
            const argument = iter.next().?;
            _ = argument; // TODO: handle this
            continue;
        }
        if (std.mem.eql(u8, base, "ucinewgame")) {
            board = Board.initZero();
            continue;
        }
        if (std.mem.eql(u8, base, "position")) {
            const argument = iter.next().?;
            if (std.mem.eql(u8, argument, "startpos")) {
                board = try Board.parseFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
            } else {
                @panic("TODO");
            }
            continue;
        }
        if (std.mem.eql(u8, base, "quit")) {
            break :loop;
        }

        std.debug.panic("unknown command: {s}", .{base});
    }
}
