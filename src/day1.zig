const std = @import("std");
const mem = std.mem;
const input = @embedFile("data/day1.txt");

pub fn distance(list1: []u32, list2: []u32) u32 {
    mem.sort(u32, list1, {}, comptime std.sort.asc(u32));
    mem.sort(u32, list2, {}, comptime std.sort.asc(u32));
    var dist: u32 = 0;

    for (list1, list2) |e1, e2| {
        dist += if (e1 >= e2) e1 - e2 else e2 - e1;
    }
    return dist;
}

pub fn similarity(llist: []u32, rlist: []u32) mem.Allocator.Error!u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    for (llist) |k| if (!map.contains(k)) try map.put(k, 0);
    for (rlist) |k| if (map.contains(k)) try map.put(k, map.get(k).? + 1);

    var sum: u32 = 0;
    for (llist) |e| {
        sum += e * map.get(e).?;
    }

    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var token_it = mem.tokenizeScalar(u8, input, '\n');
    var rlist = std.ArrayList(u32).init(allocator);
    var llist = std.ArrayList(u32).init(allocator);
    defer rlist.deinit();
    defer llist.deinit();

    while (token_it.next()) |token| {
        var scalars_it = mem.splitSequence(u8, token, "   ");
        var scalar_str = scalars_it.next().?;
        var scalar = try std.fmt.parseInt(u32, scalar_str, 10);
        try rlist.append(scalar);
        scalar_str = scalars_it.next().?;
        scalar = try std.fmt.parseInt(u32, scalar_str, 10);
        try llist.append(scalar);
    }

    const dist = distance(rlist.items, llist.items);
    const sim_score = try similarity(rlist.items, llist.items);
    std.debug.print("dist : {d} - sim_score : {d}", .{ dist, sim_score });
}

test "IDs distances" {
    var ids1 = [_]u32{ 3, 4, 2, 1, 3 };
    var ids2 = [_]u32{ 4, 3, 5, 3, 9 };

    const dist = distance(ids1[0..5], ids2[0..5]);
    try std.testing.expectEqual(11, dist);
}

test "IDs similarity" {
    var llist = [_]u32{ 3, 4, 2, 1, 3, 3 };
    var rlist = [_]u32{ 4, 3, 5, 3, 9, 3 };

    const sim = try similarity(llist[0..6], rlist[0..6]);
    try std.testing.expectEqual(31, sim);
}
