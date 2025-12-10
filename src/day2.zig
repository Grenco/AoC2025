const std = @import("std");
const expect = std.testing.expect;
const util = @import("util.zig");

fn findCombination(example: bool, _: bool) anyerror!u64 {
    const input_file = try util.getInputFile(2, example);
    defer input_file.close();

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    var total: u64 = 0;

    while (reader.interface.takeDelimiterInclusive(',')) |line| {
        var splitLine = std.mem.splitScalar(u8, line, '-');
        const startStr = splitLine.next() orelse "";
        const endStr = splitLine.next() orelse "";

        const endsWithComma = endStr[endStr.len - 1] == ',';
        const sub: u8 = if (endsWithComma) 1 else 0;

        const start = try std.fmt.parseInt(u64, startStr, 10);
        const end = try std.fmt.parseInt(u64, endStr[0 .. endStr.len - sub], 10);
        std.debug.print("{d}, {d}\n", .{ start, end });

        var value = start;
        while (value <= end) : (value += 1) {
            // var powerOfTen: u64 = 10;
            const pow: u16 = std.math.log10_int(value);
            if (@mod(pow, 2) == 0) {
                continue;
            }

            const powerOfTen = try std.math.powi(u64, 10, @divFloor(pow, 2) + 1);
            const lower = @mod(value, powerOfTen);
            const upper = @divFloor(value, powerOfTen);

            // std.debug.print("TESTING: {d}, POW: {d}, POWEROFTEN {d}, LOWER: {d}, UPPER {d}\n", .{ value, pow, powerOfTen, lower, upper });

            if (lower == upper) {
                total += value;
                std.debug.print("INVALID: {d}\n", .{value});
            }
            // const invalidCode = while (upper >= lower) {
            //     if (upper == lower) break value;
            //     powerOfTen *= 10;
            //     lower = @mod(value, powerOfTen);
            //     upper = @divFloor(value, powerOfTen);
            // } else 0;

            // if (invalidCode > 0) {
            //     std.debug.print("INVALID: {d}\n", .{invalidCode});
            // }
        }
    } else |err| switch (err) {
        error.EndOfStream => return total,
        error.StreamTooLong, // line could not fit in buffer
        error.ReadFailed, // caller can check reader implementation for diagnostics
        => |e| return e,
    }
    return total;
}

const example_only = false;
test "Day 2 Part 1 Example" {
    const result = findCombination(true, false) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 1227775554);
}
test "Day 2 Part 1" {
    if (example_only) return;
    const result = findCombination(false, false) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 RESULT: {d} \n", .{result});
    try expect(result > 0);
}

// test "Day 2 Part 2 Example" {
//     const result = findCombination(true, true) catch |err| {
//         std.debug.print("{s}\n", .{@errorName(err)});
//         return;
//     };
//     std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
//     try expect(result > 0);
// }
// test "Day 2 Part 2" {
//     if (example_only) return;
//     const result = findCombination(false, true) catch |err| {
//         std.debug.print("{s}\n", .{@errorName(err)});
//         return;
//     };
//     std.debug.print("Pt.2 RESULT: {d} \n", .{result});
//     try expect(result > 0);
// }
