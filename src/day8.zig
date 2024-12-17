const std = @import("std");

const input = @embedFile("data/day8.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    std.debug.print("Number of antinodes: {d}\n", .{try countAntiNode(input)});
    std.debug.print("Number of harmonics: {d}\n", .{try countAntiNodeWithHarmonics(input)});
}

const Position = struct { x: i32, y: i32 };

pub fn parseMap(
    map: []const u8,
    positions: *std.AutoHashMap(Position, u8),
    pool: *std.AutoArrayHashMap(u8, std.ArrayList(Position)),
    height: *i32,
    width: *i32,
) !void {
    var it = std.mem.tokenizeScalar(u8, map, '\n');
    var i: i32 = 0;
    while (it.next()) |line| : (i += 1) {
        width.* = @intCast(line.len);
        for (line, 0..) |el, j| {
            if (el == '.') continue;
            const j_isize: isize = @bitCast(j);
            const antenna_position = Position{ .y = i, .x = @truncate(j_isize) };
            try positions.put(antenna_position, el);
            if (!pool.contains(el)) try pool.put(el, std.ArrayList(Position).init(allocator));
            var antenna_pool = pool.getPtr(el);
            try antenna_pool.?.append(antenna_position);
        }
    }
    height.* = i;
}

pub fn getAntiNodes(
    first: Position,
    second: Position,
    max_x: i32,
    max_y: i32,
    node_positions: *std.AutoHashMap(Position, u8),
) !u32 {
    var n_anti_node: u32 = 0;
    var antinodes: [2]Position = [_]Position{ undefined, undefined };

    const dx: i32 = first.x - second.x;
    const dy: i32 = first.y - second.y;

    antinodes[0] = Position{ .x = first.x + dx, .y = first.y + dy };
    antinodes[1] = Position{ .x = second.x - dx, .y = second.y - dy };

    for (antinodes) |anode| {
        if ((anode.x < 0) or (anode.x >= max_x)) continue;
        if ((anode.y < 0) or (anode.y >= max_y)) continue;
        if (node_positions.contains(anode) and node_positions.get(anode) == '#') continue;
        try node_positions.put(anode, '#');
        n_anti_node += 1;
    }

    return n_anti_node;
}

pub fn countAntiNode(map: []const u8) !u32 {
    var n_anti_node: u32 = 0;
    var height: i32 = undefined;
    var width: i32 = undefined;

    var node_positions = std.AutoHashMap(Position, u8).init(allocator);
    var pool = std.AutoArrayHashMap(u8, std.ArrayList(Position)).init(allocator);

    try parseMap(map, &node_positions, &pool, &height, &width);

    var pool_it = pool.iterator();
    while (pool_it.next()) |entry| {
        const apos: []Position = entry.value_ptr.*.items;
        for (apos, 0..) |first, i| {
            for (apos[i + 1 ..]) |second| {
                n_anti_node += try getAntiNodes(first, second, width, height, &node_positions);
            }
        }
    }

    return n_anti_node;
}

pub fn getAntiNodesHarmonics(
    first: Position,
    second: Position,
    max_x: i32,
    max_y: i32,
    node_positions: *std.AutoHashMap(Position, u8),
) !u32 {
    var n_anti_node: u32 = 0;
    const mults: [2]i32 = [_]i32{ 1, -1 };

    const dx: i32 = first.x - second.x;
    const dy: i32 = first.y - second.y;

    for (mults) |mult| {
        var curr = first;
        while (true) {
            curr = Position{ .x = curr.x + mult * dx, .y = curr.y + mult * dy };
            if ((curr.x < 0) or (curr.x >= max_x)) break;
            if ((curr.y < 0) or (curr.y >= max_y)) break;
            if (node_positions.contains(curr)) continue;
            try node_positions.put(curr, '#');
            n_anti_node += 1;
        }
    }

    return n_anti_node;
}

pub fn countAntiNodeWithHarmonics(map: []const u8) !u32 {
    var total: u32 = 0;
    var height: i32 = undefined;
    var width: i32 = undefined;

    var node_positions = std.AutoHashMap(Position, u8).init(allocator);
    var pool = std.AutoArrayHashMap(u8, std.ArrayList(Position)).init(allocator);

    try parseMap(map, &node_positions, &pool, &height, &width);

    var pool_it = pool.iterator();
    while (pool_it.next()) |entry| {
        const apos: []Position = entry.value_ptr.*.items;
        for (apos, 0..) |first, i| {
            for (apos[i + 1 ..]) |second| {
                const harmonics = try getAntiNodesHarmonics(first, second, width, height, &node_positions);
                total += harmonics;
            }
            total += 1;
        }
    }

    return total;
}

test "test callibration 0A" {
    const test_input =
        \\............
        \\........0...
        \\.....0......
        \\.......0....
        \\....0.......
        \\......A.....
        \\............
        \\............
        \\........A...
        \\.........A..
        \\............
        \\............
    ;
    try std.testing.expectEqual(14, countAntiNode(test_input));
}

test "test callibration single" {
    const test_input =
        \\..........
        \\..........
        \\..........
        \\....a.....
        \\........a.
        \\.....a....
        \\..........
        \\..........
        \\..........
        \\..........
    ;
    try std.testing.expectEqual(4, countAntiNode(test_input));
}

test "test callibration occupency" {
    const test_input =
        \\..........
        \\..........
        \\..........
        \\....a.....
        \\........a.
        \\.....a....
        \\..........
        \\......A...
        \\..........
        \\..........
    ;
    try std.testing.expectEqual(4, countAntiNode(test_input));
}

test "test harmonics single" {
    const test_input =
        \\T.........
        \\...T......
        \\.T........
        \\..........
        \\..........
        \\..........
        \\..........
        \\..........
        \\..........
        \\..........
    ;
    try std.testing.expectEqual(9, countAntiNodeWithHarmonics(test_input));
}

test "test harmonics 0A" {
    const test_input =
        \\............
        \\........0...
        \\.....0......
        \\.......0....
        \\....0.......
        \\......A.....
        \\............
        \\............
        \\........A...
        \\.........A..
        \\............
        \\............
    ;
    try std.testing.expectEqual(34, countAntiNodeWithHarmonics(test_input));
}
