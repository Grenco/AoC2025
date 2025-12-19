const expect = std.testing.expect;
const util = @import("util.zig");
const std = @import("std");
const File = std.fs.File;
const Allocator = std.mem.Allocator;

var start_point_counter: usize = 0;
var start_point: usize = undefined;
fn countBeams(example: bool, _: bool) anyerror!u64 {
    const input_file = try util.getInputFile(7, example);
    defer input_file.close();

    start_point_counter = 0;
    const allocator = std.heap.page_allocator;

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    const grid = try util.getGridFromReader(bool, allocator, &reader, convert);

    const x_size = grid.x_capacity;
    var beams = try allocator.alloc(bool, x_size);
    for (0..x_size) |i| {
        beams[i] = i == start_point;
    }

    var split_count: u64 = 0;
    for (1..grid.y_capacity) |y| {
        var v: bool = undefined;
        for (0..x_size) |x| {
            const beam_prev = if (x > 0) beams[x - 1] else false;
            const beam_current = beams[x];
            const beam_next = if (x < x_size - 1) beams[x + 1] else false;

            const barrier_prev = if (x > 0) try grid.get(x - 1, y) else false;
            const barrier_current = try grid.get(x, y);
            const barrier_next = grid.get(x + 1, y) catch false;

            if (beam_current and barrier_current) split_count += 1;
            if (x > 0) {
                beams[x - 1] = v;
            }
            v = !barrier_current and (beam_current or (beam_prev and barrier_prev) or (beam_next and barrier_next));
        }
        beams[x_size - 1] = v;
    }

    return split_count;
}

fn convert(v: u8) bool {
    if (v == 'S') start_point = start_point_counter;
    start_point_counter += 1;
    return v == '^';
}

const example_only = false;
test "Day 7 Part 1 Example" {
    const result = try countBeams(true, false);
    std.debug.print("Pt.1 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 21);
}
test "Day 7 Part 1" {
    if (example_only) return;
    const result = try countBeams(false, false);
    std.debug.print("Pt.1 RESULT: {d} \n", .{result});
    try expect(result > 0);
}

// test "Day 7 Part 2 Example" {
//     const result = solveCephalopodMaths(true, true) catch |err| {
//         std.debug.print("{s}\n", .{@errorName(err)});
//         return;
//     };
//     std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
//     try expect(result == 3263827);
// }
// test "Day 7 Part2" {
//     if (example_only) return;
//     const result = solveCephalopodMaths(false, true) catch |err| {
//         std.debug.print("{s}\n", .{@errorName(err)});
//         return;
//     };
//     std.debug.print("Pt.2 RESULT: {d} \n", .{result});
//     try expect(result == 10875057285868);
// }
