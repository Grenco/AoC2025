const expect = std.testing.expect;
const util = @import("util.zig");
const std = @import("std");
const File = std.fs.File;
const Allocator = std.mem.Allocator;

fn solveCephalopodMaths(example: bool, comptime part2: bool) anyerror!u64 {
    const input_file = try util.getInputFile(6, example);
    defer input_file.close();

    const allocator = std.heap.page_allocator;

    var buffer: [4096]u8 = undefined;
    var reader = input_file.reader(&buffer);

    const totals = try (if (part2) solveItCorrectly else solveOperations)(&reader, allocator);
    defer allocator.free(totals);

    var result: u64 = 0;
    std.debug.print("TOTALS: ", .{});
    for (totals) |v| {
        std.debug.print("{d},", .{v});
        result += v;
    }
    std.debug.print("\n", .{});
    return result;
}

fn solveItCorrectly(reader: *File.Reader, gpa: Allocator) ![]u64 {
    const grid = try util.getGridFromReader(u8, gpa, reader, getChar);
    defer grid.deinit(gpa);

    var operators = try std.ArrayList(u8).initCapacity(gpa, 128);
    for (0..grid.x_capacity) |x| {
        const op = try grid.get(x, grid.y_capacity - 1);
        if (op != '+' and op != '*') continue;
        try operators.append(gpa, op);
    }

    var values_to_operate = try std.ArrayList(u32).initCapacity(gpa, grid.x_capacity);
    defer values_to_operate.deinit(gpa);
    var totals = try gpa.alloc(u64, operators.items.len);
    var i: usize = 0;
    for (0..grid.x_capacity) |x| {
        var value: u32 = 0;
        var digit_count: u32 = 0;
        var y = grid.y_capacity - 1;
        while (y > 0) : (y -= 1) {
            const digit = [_]u8{try grid.get(x, y - 1)};

            const num = std.fmt.parseInt(u8, &digit, 10) catch continue;

            value += num * try std.math.powi(u32, 10, digit_count);

            digit_count += 1;
        }
        if (value != 0) try values_to_operate.append(gpa, value);

        if (value == 0 or x == grid.x_capacity - 1) {
            for (values_to_operate.items, 0..) |num, j| {
                totals[i] = if (j == 0) num else switch (operators.items[i]) {
                    '+' => totals[i] + num,
                    '*' => totals[i] * num,
                    else => totals[i],
                };
            }
            i += 1;
            values_to_operate.clearRetainingCapacity();
            continue;
        }
    }

    return totals;
}
fn getChar(v: u8) u8 {
    return v;
}

fn solveOperations(reader: *File.Reader, gpa: Allocator) ![]u64 {
    var operators = try std.ArrayList(u8).initCapacity(gpa, 128);
    defer operators.deinit(gpa);
    var line_count: usize = 0;
    while (try reader.interface.takeDelimiter('\n')) |l| {
        line_count += 1;
        var split_line = std.mem.splitScalar(u8, l, ' ');
        while (split_line.next()) |operator| {
            if (operator.len == 0) continue;
            const op = operator[0];
            if (op != '+' and op != '*') break;
            try operators.append(gpa, op);
        }
    }

    try reader.seekTo(0);

    var totals = try gpa.alloc(u64, operators.items.len);
    var first_pass = true;
    var line_num: usize = 0;
    while (try reader.interface.takeDelimiter('\n')) |l| {
        line_num += 1;
        if (line_num == line_count) break;

        var split_line = std.mem.splitScalar(u8, l, ' ');
        var i: usize = 0;
        while (split_line.next()) |num_string| {
            if (i >= operators.items.len) break;
            const num = std.fmt.parseInt(u64, num_string, 10) catch continue;
            defer i += 1;

            if (first_pass) {
                totals[i] = num;
                continue;
            }
            totals[i] = switch (operators.items[i]) {
                '+' => totals[i] + num,
                '*' => totals[i] * num,
                else => totals[i],
            };
        }
        first_pass = false;
    }

    return totals;
}

const example_only = false;
test "Day 6 Part 1 Example" {
    const result = try solveCephalopodMaths(true, false);
    std.debug.print("Pt.1 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 4277556);
}
test "Day 6 Part 1" {
    if (example_only) return;
    const result = try solveCephalopodMaths(false, false);
    std.debug.print("Pt.1 RESULT: {d} \n", .{result});
    try expect(result == 4580995422905);
}

test "Day 6 Part 2 Example" {
    const result = solveCephalopodMaths(true, true) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 3263827);
}
test "Day 6 Part2" {
    if (example_only) return;
    const result = solveCephalopodMaths(false, true) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.2 RESULT: {d} \n", .{result});
    try expect(result == 10875057285868);
}
