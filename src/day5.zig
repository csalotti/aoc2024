const std = @import("std");
const input = @embedFile("data/day5.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    const part1_result: u32 = try getPageOrder(input);
    std.debug.print("Part 1 :{d}", .{part1_result});
}

pub fn parseLine(line: []const u8) ![][]const u8 {
    var line_array = std.ArrayList([]const u8).init(allocator);

    var i: usize = 0;
    var start: usize = 0;
    while (i < line.len) : (i += 1) {
        if (line[i] == ',') {
            try line_array.append(line[start..i]);
            start = i + 1;
        }
    }
    // Last number doesn't stop with ','
    try line_array.append(line[start..i]);

    return line_array.items;
}

pub fn getPageOrder(instructions: []const u8) !u32 {
    var result: u32 = 0;

    var input_it = std.mem.splitSequence(u8, instructions, "\n\n");
    const ordering = input_it.next().?;
    const pages_to_produce = input_it.next().?;

    var rules = std.StringHashMap(void).init(allocator);

    var rules_it = std.mem.splitScalar(u8, ordering, '\n');
    while (rules_it.next()) |rule| try rules.put(rule, undefined);

    var production_it = std.mem.splitScalar(u8, pages_to_produce, '\n');
    production: while (production_it.next()) |line| {
        const pages: [][]const u8 = try parseLine(line);
        var middle: u32 = 0;
        for (0..pages.len - 1) |i| {
            if (i == (pages.len - 1 - i)) middle = try std.fmt.parseInt(u32, pages[i], 10);
            for (i + 1..pages.len) |j| {
                const key_str = try std.fmt.allocPrint(allocator, "{s}|{s}", .{ pages[i], pages[j] });
                if (!rules.contains(key_str)) continue :production;
            }
        }
        result += middle;
    }
    return result;
}

test "test parse examples" {
    const test_input =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;
    try std.testing.expectEqual(getPageOrder(test_input), 143);
}
