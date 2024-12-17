const std = @import("std");
const input = @embedFile("data/day4.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    std.debug.print("{d}", .{countXMAS(input, 141)});
}

pub fn checkWord(screen: []const u8, line_size: usize, word: []const u8, index: usize) u32 {
    var result: u32 = 0;
    var directions: [4]u32 = [_]u32{ 0, 0, 0, 0 };

    for (0..word.len) |i| {
        if (index + i >= screen.len) continue;
        if (screen[index + i] == word[i]) directions[0] += 1;
        if (index + i * line_size - i >= screen.len) continue;
        if (screen[index + i * line_size - i] == word[i]) directions[2] += 1;
        if (index + i * line_size >= screen.len) continue;
        if (screen[index + i * line_size] == word[i]) directions[1] += 1;
        if (index + i * line_size + i >= screen.len) continue;
        if (screen[index + i * line_size + i] == word[i]) directions[3] += 1;
    }

    for (directions) |d| {
        if (d == 4) result += 1;
    }

    return result;
}

pub fn countXMAS(screen: []const u8, line_size: usize) u32 {
    var result: u32 = 0;
    var i: usize = 0;

    while (i < screen.len) : (i += 1) {
        if (screen[i] == 'X') result += checkWord(screen, line_size, "XMAS", i);
        if (screen[i] == 'S') result += checkWord(screen, line_size, "SAMX", i);
    }

    return result;
}

test "test parse examples" {
    const test_input =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    try std.testing.expectEqual(18, countXMAS(test_input, 11));
}
