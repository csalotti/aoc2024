const std = @import("std");
const input = @embedFile("data/day3.txt");

pub fn main() !void {
    std.debug.print("parse {d}\n", .{try parse(input, input.len, false)});
    std.debug.print("parse with conditions {d}\n", .{try parse(input, input.len, true)});
}

pub fn parse(memory: []const u8, size: usize, condition: bool) std.fmt.ParseIntError!u32 {
    var i: usize = 0;
    var nmatches: u32 = 0;
    var result: u32 = 0;
    var enable: bool = true;
    outer: while (i < size - 4) : (i += 1) {
        if (condition) {
            if (std.mem.eql(u8, memory[i .. i + 4], "do()")) {
                enable = true;
                i += 3;
                continue :outer;
            }
            if ((i < size - 7) and (std.mem.eql(u8, memory[i .. i + 7], "don't()"))) {
                enable = false;
                i += 6;
                continue :outer;
            }
        }
        if (!enable) continue :outer;
        if (std.mem.eql(u8, memory[i .. i + 4], "mul(")) {
            i += 4;
            const start = i;
            var valid: bool = false;
            inner: while (i < size) : (i += 1) {
                switch (memory[i]) {
                    '0'...'9' => continue :inner,
                    ',' => continue :inner,
                    ')' => {
                        valid = true;
                        break :inner;
                    },
                    else => continue :outer,
                }
                if (i == size - 1) break :outer;
            }
            if (!valid) continue :outer;
            var mul: u32 = 1;
            var it = std.mem.splitScalar(u8, memory[start..i], ',');
            var it_size: u2 = 0;
            while (it.next()) |num| {
                mul *= try std.fmt.parseInt(u32, num, 10);
                it_size += 1;
            }
            if (it_size != 2) continue :outer;
            result += mul;
            nmatches += 1;
        }
    }
    std.debug.print("nmatches : {d}\n", .{nmatches});

    return result;
}

test "test parse examples" {
    const test_input: []const u8 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    try std.testing.expectEqual(161, parse(test_input, test_input.len, false));
}

test "unit tests parse" {
    try std.testing.expectEqual(0, parse("mul(2,4", 7, false));
    try std.testing.expectEqual(0, parse("mul(2,4]", 8, false));
    try std.testing.expectEqual(0, parse("mul(2,4,", 8, false));
    try std.testing.expectEqual(0, parse("mul2,4)", 7, false));
    try std.testing.expectEqual(0, parse("mul(24", 6, false));
    try std.testing.expectEqual(0, parse("mul(24)", 7, false));
}

test "test parse with condition" {
    const test_input = ("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))");
    try std.testing.expectEqual(48, parse(test_input, test_input.len, true));
}
