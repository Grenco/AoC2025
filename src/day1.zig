const std = @import("std");
const expect = std.testing.expect;
const util = @import("util.zig");

fn findCombination(example: bool, part2: bool) anyerror!u32 {
    const input_file = try util.getInputFile(1, example);
    defer input_file.close();

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    var dial_position: i16 = 50;
    var zero_count: u16 = 0;
    var passed_zero_count: u16 = 0;

    while (reader.interface.takeDelimiterInclusive('\n')) |line| {
        const direction = line[0];
        const multiplier: i8 = switch (direction) {
            'L' => -1,
            'R' => 1,
            else => 0,
        };

        const num_string = line[1 .. line.len - 1];

        const value = try std.fmt.parseInt(i16, num_string, 10);

        const was_on_zero: u8 = if (dial_position == 0 and multiplier == -1) 1 else 0;

        dial_position += multiplier * value;

        const on_zero: u8 = if (dial_position == 0) 1 else 0;
        const zero_ticks = @abs(@divFloor(dial_position, 100));

        dial_position = @mod(dial_position, 100);

        const is_negative_zero: u8 = if (dial_position == 0 and multiplier == -1 and value >= 100) 1 else 0;

        passed_zero_count += zero_ticks - was_on_zero + on_zero + is_negative_zero;

        if (dial_position == 0) {
            zero_count += 1;
        }
    } else |err| switch (err) {
        error.EndOfStream => return if (part2) passed_zero_count else zero_count, // stream ended not on a line break
        error.StreamTooLong, // line could not fit in buffer
        error.ReadFailed, // caller can check reader implementation for diagnostics
        => |e| return e,
    }
    return if (part2) passed_zero_count else zero_count;
}

const example_only = false;
test "Day 1 Part 1 Example" {
    const result = findCombination(true, false) catch |err| {
        std.debug.print("{s}", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 3);
}
test "Day 1 Part 1" {
    if (example_only) return;
    const result = findCombination(false, false) catch |err| {
        std.debug.print("{s}", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 RESULT: {d} \n", .{result});
    try expect(result == 995);
}

test "Day 1 Part 2 Example" {
    const result = findCombination(true, true) catch |err| {
        std.debug.print("{s}", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 6);
}
test "Day 1 Part 2" {
    if (example_only) return;
    const result = findCombination(false, true) catch |err| {
        std.debug.print("{s}", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.2 RESULT: {d} \n", .{result});
    try expect(result == 5847);
}
