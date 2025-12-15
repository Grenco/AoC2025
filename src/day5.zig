const expect = std.testing.expect;
const util = @import("util.zig");
const std = @import("std");
const File = std.fs.File;
const Allocator = std.mem.Allocator;
const Range = @import("range.zig").Range;

fn findFreshIngredientIds(example: bool, part2: bool) anyerror!u64 {
    const input_file = try util.getInputFile(5, example);
    defer input_file.close();

    const allocator = std.heap.page_allocator;

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    var ranges = try readRanges(&reader, allocator);
    defer ranges.deinit(allocator);

    if (part2) {
        return try findTotalSizeOfRanges(allocator, &ranges);
    }

    var fresh_stock: u64 = 0;
    var l = try reader.interface.takeDelimiter('\n') orelse "";
    while (l.len > 0) : (l = try reader.interface.takeDelimiter('\n') orelse "") {
        const v = try std.fmt.parseInt(u64, l, 10);
        const fresh = for (ranges.items) |range| {
            if (range.contains(v)) break true;
        } else false;
        if (fresh) fresh_stock += 1;
    }
    return fresh_stock;
}

fn findTotalSizeOfRanges(allocator: Allocator, ranges: *std.ArrayList(Range(u64))) !u64 {
    var combinedRanges = try std.ArrayList(Range(u64)).initCapacity(allocator, ranges.items.len);
    defer combinedRanges.deinit(allocator);

    for (ranges.items) |range| {
        var i: usize = 0;
        var newRange = Range(u64).init(range.min, range.max);
        while (i < combinedRanges.items.len) {
            const combinedRange = combinedRanges.items[i];
            if (newRange.overlaps(combinedRange)) {
                newRange = newRange.combine(combinedRange);
                _ = combinedRanges.orderedRemove(i);
                continue;
            }
            i += 1;
        }

        try combinedRanges.append(allocator, newRange);
    }

    var totalSize: u64 = 0;
    for (combinedRanges.items) |r| {
        std.debug.print("{d}-{d}, size: {d}\n", .{ r.min, r.max, r.size() });
        totalSize += r.size();
    }
    return totalSize;
}

fn readRanges(reader: *File.Reader, gpa: Allocator) !std.ArrayList(Range(u64)) {
    var l = try reader.interface.takeDelimiter('\n') orelse "";

    var ranges = try std.ArrayList(Range(u64)).initCapacity(gpa, 1024);
    while (l.len > 0) : (l = try reader.interface.takeDelimiter('\n') orelse "") {
        var split_line = std.mem.splitScalar(u8, l, '-');
        const min_str = split_line.next() orelse "";
        const max_str = split_line.next() orelse "";
        const min = try std.fmt.parseInt(u64, min_str, 10);
        const max = try std.fmt.parseInt(u64, max_str, 10);
        const range = Range(u64).init(min, max + 1);
        try ranges.append(gpa, range);
    }

    return ranges;
}

const example_only = false;
test "Day 5 Part 1 Example" {
    const result = try findFreshIngredientIds(true, false);
    std.debug.print("Pt.1 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 3);
}
test "Day 5 Part 1" {
    if (example_only) return;
    const result = findFreshIngredientIds(false, false) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 RESULT: {d} \n", .{result});
    try expect(result == 567);
}

test "Day 5 Part 2 Example" {
    const result = findFreshIngredientIds(true, true) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 14);
}
test "Day 5 Part 2" {
    if (example_only) return;
    const result = findFreshIngredientIds(false, true) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.2 RESULT: {d} \n", .{result});
    try expect(result == 354149806372909);
}
