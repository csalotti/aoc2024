const std = @import("std");

const input = @embedFile("data/day7.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    std.debug.print("Distinct positions +*: {d}\n", .{try getTotalCallibration(input, "+*")});
    std.debug.print("Distinct positions +*|: {d}", .{try getTotalCallibration(input, "*+|")});
}

pub fn isValid(operands: []u64, equation: u64, target: u64, operations: []const u8) !bool {
    if (operands.len == 0) return equation == target;
    const head: u64 = operands[0];
    const rest: []u64 = operands[1..];
    var _equation: u64 = undefined;
    for (operations) |op| {
        switch (op) {
            '+' => _equation = equation + head,
            '*' => _equation = equation * head,
            '|' => {
                const equation_str: []u8 = try std.fmt.allocPrint(allocator, "{d}{d}", .{ equation, head });
                _equation = try std.fmt.parseInt(u64, equation_str, 10);
            },
            else => undefined,
        }
        if (try isValid(rest, _equation, target, operations)) return true;
    }
    return false;
}

pub fn getTotalCallibration(equations: []const u8, operations: []const u8) !u64 {
    var result: u64 = 0;
    var it = std.mem.tokenizeScalar(u8, equations, '\n');
    while (it.next()) |eq| {
        var eq_it = std.mem.tokenizeAny(u8, eq, ": ");
        const target: u64 = try std.fmt.parseInt(u64, eq_it.next().?, 10);
        var operands: std.ArrayList(u64) = std.ArrayList(u64).init(allocator);
        while (eq_it.next()) |op| try operands.append(try std.fmt.parseInt(u64, op, 10));
        if (try isValid(operands.items, 0, target, operations)) result += target;
    }

    return result;
}

test "test callibration +*" {
    const test_input =
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
    ;
    try std.testing.expectEqual(3749, getTotalCallibration(test_input, "+*"));
}

test "test callibraton +*|" {
    const test_input =
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
    ;
    try std.testing.expectEqual(11387, getTotalCallibration(test_input, "+*|"));
}
