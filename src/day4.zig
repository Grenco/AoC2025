const expect = std.testing.expect;
const util = @import("util.zig");
const std = @import("std");

fn findAccessibleRolls(example: bool, part2: bool) anyerror!u64 {
    const input_file = try util.getInputFile(4, example);
    defer input_file.close();

    const allocator = std.heap.page_allocator;

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    const grid = try util.getGridFromReader(bool, allocator, &reader, isPaperRoll);
    defer grid.deinit(allocator);

    var accessible_roll_count: u32 = 1;
    var total_removed_rolls: u32 = 0;
    while (accessible_roll_count > 0) {
        accessible_roll_count = 0;

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
                if (part2) try grid.set(x, y, !accessible);
            }
            std.debug.print("\n", .{});
        }
        if (!part2) {
            return accessible_roll_count;
        }
        total_removed_rolls += accessible_roll_count;
    }
    return total_removed_rolls;
}

fn isPaperRoll(char: u8) bool {
    return char == '@';
}

const example_only = false;
test "Day 4 Part 1 Example" {
    const result = findAccessibleRolls(true, false) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 13);
}
test "Day 4 Part 1" {
    if (example_only) return;
    const result = findAccessibleRolls(false, false) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 RESULT: {d} \n", .{result});
    try expect(result == 1527);
}

test "Day 4 Part 2 Example" {
    const result = findAccessibleRolls(true, true) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 43);
}
test "Day 4 Part 2" {
    if (example_only) return;
    const result = findAccessibleRolls(false, true) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.2 RESULT: {d} \n", .{result});
    try expect(result > 0);
}
