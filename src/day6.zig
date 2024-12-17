const std = @import("std");
const input = @embedFile("data/day6.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    std.debug.print("Distinct positions : {d}", .{try getDistinctPositions(input)});
}

const Position = struct { x: i32, y: i32 };
const directions: [4]Position = [_]Position{
    Position{ .x = 0, .y = -1 },
    Position{ .x = 1, .y = 0 },
    Position{ .x = 0, .y = 1 },
    Position{ .x = -1, .y = 0 },
};

pub fn getDistinctPositions(map: []const u8) !u32 {
    var guard: Position = undefined;
    var obstacles: std.AutoHashMap(Position, void) = std.AutoHashMap(Position, void).init(allocator);
    var visited: std.AutoHashMap(Position, void) = std.AutoHashMap(Position, void).init(allocator);

    var map_it = std.mem.splitScalar(u8, map, '\n');
    var i: i32 = 0;
    var j: i32 = 0;
    while (map_it.next()) |line| : (i += 1) {
        if (line.len == 0) break;
        j = 0;
        for (line) |item| {
            if (item == '^') guard = Position{ .x = j, .y = i };
            if (item == '#') try obstacles.put(Position{ .x = j, .y = i }, {});
            j += 1;
        }
    }

    const height: i32 = i;
    const width: i32 = j;

    var distance: u32 = 0;
    var index: usize = 0;
    var direction: Position = directions[index];

    walk: while (true) {
        if (guard.x == width) break :walk;
        if (guard.x < 0) break :walk;
        if (guard.y == height) break :walk;
        if (guard.y < 0) break :walk;
        if (obstacles.contains(guard)) {
            guard.x -= direction.x;
            guard.y -= direction.y;
            index = (index + 1) % 4;
            direction = directions[index];
        }
        if (!visited.contains(guard)) {
            try visited.put(guard, {});
            distance += 1;
        }
        guard.x += direction.x;
        guard.y += direction.y;
    }

    return distance;
}

test "test parse examples" {
    const test_input =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ;
    try std.testing.expectEqual(41, getDistinctPositions(test_input));
}
