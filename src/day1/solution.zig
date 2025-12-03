const std = @import("std");
const expect = std.testing.expect;

pub fn findCombination(fileName: []const u8) anyerror!u32 {
    const parts = [_][]const u8{ "src/day1/", fileName };
    const allocator = std.heap.page_allocator;
    const full_path = std.mem.concat(allocator, u8, &parts) catch unreachable;
    std.debug.print("PATH {s}", .{full_path});
    defer allocator.free(full_path);

    const input_file = try std.fs.cwd().openFile(full_path, .{});
    defer input_file.close();

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    var dial_position: i16 = 50;
    var zero_count: u16 = 0;

    while (reader.interface.takeDelimiterInclusive('\n')) |line| {
        const direction = line[0];
        const multiplier: i8 = switch (direction) {
            'L' => -1,
            'R' => 1,
            else => 0,
        };

        const num_string = line[1 .. line.len - 1];

        const value = try std.fmt.parseInt(i16, num_string, 10);
        dial_position += multiplier * value;
        while (dial_position < 0) {
            dial_position += 100;
        }
        dial_position = @mod(dial_position, 100);

        if (dial_position == 0) {
            zero_count += 1;
        }
    } else |err| switch (err) {
        error.EndOfStream => return zero_count, // stream ended not on a line break
        error.StreamTooLong, // line could not fit in buffer
        error.ReadFailed, // caller can check reader implementation for diagnostics
        => |e| return e,
    }
    return zero_count;
}

test "Day 1 Part 1 Example" {
    const result = findCombination("exampleInput.txt") catch |err| {
        std.debug.print("{s}", .{@errorName(err)});
        return;
    };
    std.debug.print("EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 3);
}

test "Day 1 Part 1" {
    const result = findCombination("input.txt") catch |err| {
        std.debug.print("{s}", .{@errorName(err)});
        return;
    };
    std.debug.print("RESULT: {d} \n", .{result});
    try expect(result > 0);
}
