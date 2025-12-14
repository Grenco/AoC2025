const expect = std.testing.expect;
const util = @import("util.zig");
const std = @import("std");
const File = std.fs.File;
const Allocator = std.mem.Allocator;
const Range = @import("range.zig").Range;

fn findAccessibleRolls(example: bool, _: bool) anyerror!u64 {
    const input_file = try util.getInputFile(5, example);
    defer input_file.close();

    const allocator = std.heap.page_allocator;

    var buffer: [1024]u8 = undefined;
    var reader = input_file.reader(&buffer);

    const ranges = try readRanges(&reader, allocator);

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

fn readRanges(reader: *File.Reader, gpa: Allocator) !std.ArrayList(Range(u64)) {
    var l = try reader.interface.takeDelimiter('\n') orelse "";

    var ranges = try std.ArrayList(Range(u64)).initCapacity(gpa, 1024);
    while (l.len > 0) : (l = try reader.interface.takeDelimiter('\n') orelse "") {
        var split_line = std.mem.splitScalar(u8, l, '-');
        const min_str = split_line.next() orelse "";
        const max_str = split_line.next() orelse "";
        const min = try std.fmt.parseInt(u64, min_str, 10);
        const max = try std.fmt.parseInt(u64, max_str, 10);
        var range = Range(u64).set(min, max);
        range.max_inclusive = true;
        try ranges.append(gpa, range);
    }

    return ranges;
}

const example_only = false;
test "Day 5 Part 1 Example" {
    const result = try findAccessibleRolls(true, false);
    std.debug.print("Pt.1 EXAMPLE RESULT: {d} \n", .{result});
    try expect(result == 3);
}
test "Day 5 Part 1" {
    if (example_only) return;
    const result = findAccessibleRolls(false, false) catch |err| {
        std.debug.print("{s}\n", .{@errorName(err)});
        return;
    };
    std.debug.print("Pt.1 RESULT: {d} \n", .{result});
    try expect(result == 567);
}

// test "Day 5 Part 2 Example" {
//     const result = findAccessibleRolls(true, true) catch |err| {
//         std.debug.print("{s}\n", .{@errorName(err)});
//         return;
//     };
//     std.debug.print("Pt.2 EXAMPLE RESULT: {d} \n", .{result});
//     try expect(result == 14);
// }
// test "Day 5 Part 2" {
//     if (example_only) return;
//     const result = findAccessibleRolls(false, true) catch |err| {
//         std.debug.print("{s}\n", .{@errorName(err)});
//         return;
//     };
//     std.debug.print("Pt.2 RESULT: {d} \n", .{result});
//     try expect(result > 0);
// }
