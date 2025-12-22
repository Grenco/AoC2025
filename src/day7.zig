const expect = std.testing.expect;
const util = @import("util.zig");
const std = @import("std");
const File = std.fs.File;
const Allocator = std.mem.Allocator;
const Grid = @import("grid.zig").Grid;
const CellRef = @import("grid.zig").CellRef;

var start_point_counter: usize = 0;
var start_point: usize = undefined;
fn countBeams(example: bool, comptime part2: bool) anyerror!u64 {
    const input_file = try util.getInputFile(7, example);
    defer input_file.close();

    start_point_counter = 0;
    const allocator = std.heap.page_allocator;

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    const grid = try util.getGridFromReader(bool, allocator, &reader, convert);
    defer grid.deinit(allocator);

    return if (part2) countTotalPaths(grid, allocator) else countBeamSplits(grid, allocator);
}

fn countTotalPaths(grid: Grid(bool), gpa: Allocator) !u64 {
    var count_cache = std.AutoHashMap(CellRef, u64).init(gpa);
    defer count_cache.deinit();

    var stack = try std.ArrayList(CellRef).initCapacity(gpa, 1024);
    defer stack.deinit(gpa);

    const start_ref = CellRef{ .x = start_point, .y = 0 };

    try stack.append(gpa, .{ .x = start_point, .y = 1 });

    var current_stack = try std.ArrayList(CellRef).initCapacity(gpa, grid.y_capacity);
    defer current_stack.deinit(gpa);

    try current_stack.append(gpa, start_ref);
    try count_cache.put(start_ref, 1);

    while (stack.pop()) |ref| {
        if (count_cache.contains(ref)) {
            const count_from_this_cell = count_cache.get(ref) orelse 0;
            for (current_stack.items) |stackCell| {
                const count: usize = count_cache.get(stackCell) orelse 0;
                try count_cache.put(stackCell, count + count_from_this_cell);
            }
            continue;
        }

        if (ref.y >= grid.y_capacity - 1) continue;

        while (current_stack.items.len > ref.y) {
            _ = current_stack.pop() orelse CellRef{ .x = 0, .y = 0 };
        }

        try current_stack.append(gpa, ref);

        const barrier = try grid.get(ref.x, ref.y);

        if (barrier) {
            try stack.append(gpa, .{ .x = ref.x -% 1, .y = ref.y + 1 });
            try stack.append(gpa, .{ .x = ref.x + 1, .y = ref.y + 1 });

            for (current_stack.items) |stack_cell| {
                const count: usize = count_cache.get(stack_cell) orelse 0;
                try count_cache.put(stack_cell, count + 1);
            }
            continue;
        }

        try stack.append(gpa, .{ .x = ref.x, .y = ref.y + 1 });
    }

    return count_cache.get(start_ref) orelse 0;
}

fn countBeamSplits(grid: Grid(bool), gpa: Allocator) !u64 {
    var split_count: u64 = 0;

    const x_size = grid.x_capacity;
    var beams = try gpa.alloc(bool, x_size);
    defer gpa.free(beams);

    for (0..x_size) |i| {
        beams[i] = i == start_point;
    }

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
    try expect(result == 1566);
}

test "Day 7 Part 2 Example" {
    const result = try countBeams(true, true);
    std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 40);
}
test "Day 7 Part2" {
    if (example_only) return;
    const result = try countBeams(false, true);
    std.debug.print("Pt.2 RESULT: {d} \n", .{result});
    try expect(result == 5921061943075);
}
