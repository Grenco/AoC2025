const std = @import("std");
const expect = std.testing.expect;
const util = @import("util.zig");

fn findCombination(example: bool, _: bool) anyerror!u64 {
    const input_file = try util.getInputFile(3, example);
    defer input_file.close();

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    var totalJoltage: u64 = 0;

    while (reader.interface.takeDelimiterInclusive('\n')) |line| {
        var v1: u8 = 0;
        var v2: u8 = 0;
        for (line) |joltageChar| {
            const str: [1]u8 = .{joltageChar};
            const joltage = std.fmt.parseInt(u8, &str, 10) catch continue;
            if (v2 > v1) {
                v1 = v2;
                v2 = 0;
            }
            v2 = @max(v2, joltage);
        }
        totalJoltage += v1 * 10 + v2;
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
    const result = findCombination(true, false) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 357);
}
test "Day 3 Part 1" {
    if (example_only) return;
    const result = findCombination(false, false) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 RESULT: {d} \n", .{result});
    try expect(result > 0);
}

// test "Day 3 Part 2 Example" {
//     const result = findCombination(true, true) catch |err| {
//         std.debug.print("{s}\n", .{@errorName(err)});
//         return;
//     };
//     std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
//     try expect(result == 4174379265);
// }
// test "Day 3 Part 2" {
//     if (example_only) return;
//     const result = findCombination(false, true) catch |err| {
//         std.debug.print("{s}\n", .{@errorName(err)});
//         return;
//     };
//     std.debug.print("Pt.2 RESULT: {d} \n", .{result});
//     try expect(result == 41662374059);
// }
