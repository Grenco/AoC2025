const std = @import("std");
const expect = std.testing.expect;
const util = @import("util.zig");

fn findCombination(example: bool, digits: u8) anyerror!u64 {
    const input_file = try util.getInputFile(3, example);
    defer input_file.close();

    const allocator = std.heap.page_allocator;

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    var totalJoltage: u64 = 0;

    const cellJoltage = try allocator.alloc(u8, digits);
    defer allocator.free(cellJoltage);

    while (reader.interface.takeDelimiterInclusive('\n')) |line| {
        for (0..digits) |i| {
            cellJoltage[i] = 0;
        }

        for (line) |joltageChar| {
            const str = [_]u8{joltageChar};
            const joltage = std.fmt.parseInt(u8, &str, 10) catch continue;

            for (0..digits - 1) |i| {
                const v1 = cellJoltage[i];
                const v2 = cellJoltage[i + 1];
                if (v2 > v1) {
                    cellJoltage[i] = v2;
                    cellJoltage[i + 1] = 0;
                }
            }

            cellJoltage[digits - 1] = @max(cellJoltage[digits - 1], joltage);
        }
        for (cellJoltage, 1..) |v, i| {
            totalJoltage += v * try std.math.powi(u64, 10, digits - i);
        }
    } else |err| switch (err) {
        error.EndOfStream => return totalJoltage,
        error.StreamTooLong, // line could not fit in buffer
        error.ReadFailed, // caller can check reader implementation for diagnostics
        => |e| return e,
    }
    return totalJoltage;
}

const example_only = false;
test "Day 3 Part 1 Example" {
    const result = findCombination(true, 2) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 357);
}
test "Day 3 Part 1" {
    if (example_only) return;
    const result = findCombination(false, 2) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 RESULT: {d} \n", .{result});
    try expect(result == 17324);
}

test "Day 3 Part 2 Example" {
    const result = findCombination(true, 12) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 3121910778619);
}
test "Day 3 Part 2" {
    if (example_only) return;
    const result = findCombination(false, 12) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.2 RESULT: {d} \n", .{result});
    try expect(result == 171846613143331);
}
