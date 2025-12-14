const expect = std.testing.expect;
const util = @import("util.zig");
const std = @import("std");

fn findCombination(example: bool, digits: u8) anyerror!u64 {
    const input_file = try util.getInputFile(4, example);
    defer input_file.close();

    const allocator = std.heap.page_allocator;

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    const cellJoltage = try allocator.alloc(u8, digits);
    defer allocator.free(cellJoltage);

    const grid = try util.getGridFromReader(bool, allocator, &reader, isPaperRoll);
    defer grid.deinit(allocator);

    var accessible_roll_count: u32 = 0;
    for (0..grid.y_capacity) |y| {
        for (0..grid.x_capacity) |x| {
            const value = try grid.get(x, y);
            if (!value) {
                std.debug.print(".", .{});
                continue;
            }
            const neigbours = grid.getAllCellNeighbours(x, y, false);

            var blockedCount: u8 = 0;
            for (neigbours) |n| {
                blockedCount += if (n) 1 else 0;
            }

            const accessible = blockedCount < 4;
            std.debug.print("{s}", .{if (accessible) "x" else "@"});

            accessible_roll_count += if (accessible) 1 else 0;
        }
        std.debug.print("\n", .{});
    }
    return accessible_roll_count;
}

fn isPaperRoll(char: u8) bool {
    return char == '@';
}

const example_only = false;
test "Day 4 Part 1 Example" {
    const result = findCombination(true, 2) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 13);
}
test "Day 4 Part 1" {
    if (example_only) return;
    const result = findCombination(false, 2) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 RESULT: {d} \n", .{result});
    try expect(result == 1527);
}

// test "Day 4 Part 2 Example" {
//     const result = findCombination(true, 12) catch |err| {
//         std.debug.print("{s}\n", .{@errorName(err)});
//         return;
//     };
//     std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
//     try expect(result == 3121910778619);
// }
// test "Day 4 Part 2" {
//     if (example_only) return;
//     const result = findCombination(false, 12) catch |err| {
//         std.debug.print("{s}\n", .{@errorName(err)});
//         return;
//     };
//     std.debug.print("Pt.2 RESULT: {d} \n", .{result});
//     try expect(result == 171846613143331);
// }
