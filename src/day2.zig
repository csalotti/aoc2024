const std = @import("std");
const mem = std.mem;
const input = @embedFile("data/day2.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    var token_it = mem.tokenizeScalar(u8, input, '\n');
    var report: std.ArrayList(i32) = undefined;
    var safety_score: u32 = 0;
    var safety_dampner_score: u32 = 0;
    while (token_it.next()) |token| {
        std.debug.print("{s}\n", .{token});
        var scalars_it = mem.splitSequence(u8, token, " ");
        report = std.ArrayList(i32).init(allocator);
        defer report.deinit();
        var scalar: i32 = undefined;
        while (scalars_it.next()) |scalar_str| {
            scalar = try std.fmt.parseInt(i32, scalar_str, 10);
            try report.append(scalar);
        }
        if (checkSafety(report.items) == Safety.Safe) {
            safety_score += 1;
        }
        if (try checkDampnerSafety(report.items) == Safety.Safe) {
            safety_dampner_score += 1;
        }
    }

    std.debug.print("Safety Score {d} - Safety Dampner Score {d}", .{ safety_score, safety_dampner_score });
}

const Safety = enum { Safe, Unsafe };

pub fn isInBound(diff: i32) bool {
    return (@abs(diff) >= 1) and (@abs(diff) <= 3);
}

pub fn checkSafety(levels: []const i32) Safety {
    var diff: i32 = undefined;
    var sign_prev: i2 = undefined;
    var sign_curr: i2 = undefined;
    for (0..levels.len - 1) |i| {
        diff = levels[i] - levels[i + 1];
        if (!isInBound(diff)) return Safety.Unsafe;
        sign_curr = if (diff > 0) 1 else -1;
        if ((i > 0) and (sign_curr != sign_prev)) return Safety.Unsafe;
        sign_prev = sign_curr;
    }

    return Safety.Safe;
}

pub fn checkDampnerSafety(levels: []const i32) std.mem.Allocator.Error!Safety {
    if (checkSafety(levels) == Safety.Safe) return Safety.Safe;

    var diff: i32 = undefined;
    var diffs_list = std.ArrayList(i32).init(allocator);
    var signs_list = std.ArrayList(i2).init(allocator);
    for (0..levels.len - 1) |i| {
        diff = levels[i] - levels[i + 1];
        try diffs_list.append(diff);
        try signs_list.append(if (diff > 0) 1 else -1);
    }

    const diffs = diffs_list.items;
    const signs = signs_list.items;
    var chance: bool = true;
    var i: usize = 0;
    const diff_len: usize = levels.len - 1;
    while (i < diff_len) : (i += 1) {
        if (!isInBound(diffs[i])) {
            if (!chance) return Safety.Unsafe;
            chance = false;
            if (i == diff_len - 1) continue;
            if (isInBound(diffs[i] + diffs[i + 1])) i += 1 else if (i != 0) return Safety.Unsafe;
            continue;
        }
        if (i == diff_len - 1) continue;
        if (signs[i] != signs[i + 1]) {
            if (!chance) return Safety.Unsafe;
            chance = false;
            if (i == diff_len - 2) continue;
            if (signs[i] == signs[i + 2]) i += 1;
        }
    }

    return Safety.Safe;
}

test "test check safety" {
    const reports = [6][5]i32{
        [5]i32{ 7, 6, 4, 2, 1 },
        [5]i32{ 1, 2, 7, 8, 9 },
        [5]i32{ 9, 7, 6, 2, 1 },
        [5]i32{ 1, 3, 2, 4, 5 },
        [5]i32{ 8, 6, 4, 4, 1 },
        [5]i32{ 1, 3, 6, 7, 9 },
    };

    const answers = [6]Safety{ Safety.Safe, Safety.Unsafe, Safety.Unsafe, Safety.Unsafe, Safety.Unsafe, Safety.Safe };

    for (reports, answers) |report, answer| {
        try std.testing.expectEqual(answer, checkSafety(report[0..report.len]));
    }
}

test "test check Dampener safety" {
    const reports = [_][5]i32{
        [5]i32{ 7, 6, 4, 2, 1 },
        [5]i32{ 1, 2, 7, 8, 9 },
        [5]i32{ 9, 7, 6, 2, 1 },
        [5]i32{ 1, 3, 2, 4, 5 },
        [5]i32{ 8, 6, 4, 4, 1 },
        [5]i32{ 1, 3, 6, 7, 9 },
        [5]i32{ 4, 3, 6, 7, 9 },
        [5]i32{ 1, 3, 6, 7, 5 },
        [5]i32{ 1, 2, 3, 4, 8 },
        [5]i32{ 10, 4, 3, 2, 1 },
        [5]i32{ 8, 6, 4, 4, 6 },
        [5]i32{ 3, 1, 2, 4, 5 },
    };

    const answers = [_]Safety{
        Safety.Safe,
        Safety.Unsafe,
        Safety.Unsafe,
        Safety.Safe,
        Safety.Safe,
        Safety.Safe,
        Safety.Safe,
        Safety.Safe,
        Safety.Safe,
        Safety.Safe,
        Safety.Unsafe,
        Safety.Safe,
    };

    for (reports, answers) |report, answer| {
        std.debug.print("{d}\n", .{report});
        try std.testing.expectEqual(answer, checkDampnerSafety(report[0..report.len]));
    }
}

test "text check puzzle input" {
    const report = [_]i32{ 15, 19, 20, 20, 22, 26 };

    try std.testing.expectEqual(Safety.Unsafe, checkDampnerSafety(report[0..report.len]));
}
