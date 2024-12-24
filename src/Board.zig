const std = @import("std");
const Board = @This();
const expect = std.testing.expect;

white: Pieces,
black: Pieces,
/// `false` for white, `true` for black
side_to_move: bool,

pub const Bitboard = struct {
    state: u64,

    pub fn initEmpty() Bitboard {
        return .{ .state = 0 };
    }

    pub fn set(bit_board: *Bitboard, index: u64) void {
        bit_board.state |= @as(u64, 1) << @intCast(index);
    }

    pub fn isSet(bit_board: Bitboard, index: u64) bool {
        return bit_board.state & (@as(u64, 1) << @intCast(index)) != 0;
    }
};

const Pieces = struct {
    pawns: Bitboard,
    knights: Bitboard,
    bishops: Bitboard,
    rooks: Bitboard,
    queens: Bitboard,
    king: Bitboard,

    const zero: Pieces = .{
        .pawns = Bitboard.initEmpty(),
        .knights = Bitboard.initEmpty(),
        .bishops = Bitboard.initEmpty(),
        .rooks = Bitboard.initEmpty(),
        .queens = Bitboard.initEmpty(),
        .king = Bitboard.initEmpty(),
    };
};

fn initZero() Board {
    return .{
        .white = Pieces.zero,
        .black = Pieces.zero,
        .side_to_move = false,
    };
}

pub fn parseFen(fen: []const u8) !Board {
    var board = Board.initZero();
    var square: u64 = 56;
    var fields = std.mem.tokenizeScalar(u8, fen, ' ');
    const pieces = fields.next().?;

    for (pieces) |piece| {
        if (std.ascii.isDigit(piece)) {
            square += piece - '0';
        } else if (piece == '/') {
            square -= 16;
        } else {
            const target = switch (piece) {
                'P' => &board.white.pawns,
                'p' => &board.black.pawns,
                'N' => &board.white.knights,
                'n' => &board.black.knights,
                'B' => &board.white.bishops,
                'b' => &board.black.bishops,
                'R' => &board.white.rooks,
                'r' => &board.black.rooks,
                'Q' => &board.white.queens,
                'q' => &board.black.queens,
                'K' => &board.white.king,
                'k' => &board.black.king,
                else => @panic("unknown piece"),
            };
            target.set(square);
            square += 1;
        }
    }

    const turn = fields.next().?;
    board.side_to_move = std.mem.eql(u8, turn, "b");

    return board;
}

pub fn format(
    board: Board,
    comptime _: []const u8,
    _: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    var buffer: [64]u8 = .{'.'} ** 64;
    const white = board.white;
    const black = board.black;

    // zig fmt: off
    for (0..64) |index| {
        if (white.pawns  .isSet(index)) buffer[index] = 'P';
        if (white.knights.isSet(index)) buffer[index] = 'N';
        if (white.bishops.isSet(index)) buffer[index] = 'B';
        if (white.rooks  .isSet(index)) buffer[index] = 'R';
        if (white.queens .isSet(index)) buffer[index] = 'Q';
        if (white.king   .isSet(index)) buffer[index] = 'K';
    }

    for (0..64) |index| {
        if (black.pawns  .isSet(index)) buffer[index] = 'p';
        if (black.knights.isSet(index)) buffer[index] = 'n';
        if (black.bishops.isSet(index)) buffer[index] = 'b';
        if (black.rooks  .isSet(index)) buffer[index] = 'r';
        if (black.queens .isSet(index)) buffer[index] = 'q';
        if (black.king   .isSet(index)) buffer[index] = 'k';
    }
    // zig fmt: on

    try writer.writeAll("   a b c d e f g h\n");
    try writer.writeAll(" +----------------+\n");

    for (0..8) |row| {
        const rank = 7 - row;
        try writer.print("{} |", .{rank + 1});
        for (0..8) |file| {
            const square = (rank * 8) + file;
            try writer.print(" {c}", .{buffer[square]});
        }
        try writer.writeAll("\n");
    }

    try writer.writeAll(" +----------------+\n");
    try writer.writeAll("   a b c d e f g h\n");
    try writer.print("Side to move: {s}", .{if (board.side_to_move) "black" else "white"});
}

test "parse fen startpos" {
    const board = try Board.parseFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
    try expect(board.side_to_move == false);
}
