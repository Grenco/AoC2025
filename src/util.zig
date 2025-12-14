const std = @import("std");
const File = std.fs.File;
const Allocator = std.mem.Allocator;
const Grid = @import("grid.zig").Grid;

pub fn getInputFile(day: u8, example: bool) !File {
    var buf: [20]u8 = undefined;
    const dayAsString = try std.fmt.bufPrint(&buf, "{}", .{day});
    const exampleText = if (example) "_example" else "";
    const parts = [_][]const u8{ "src/input/day", dayAsString, exampleText, ".txt" };

    const allocator = std.heap.page_allocator;
    const full_path = std.mem.concat(allocator, u8, &parts) catch unreachable;
    defer allocator.free(full_path);

    const input_file = try std.fs.cwd().openFile(full_path, .{});
    return input_file;
}

pub fn getGridFromReader(comptime T: type, allocator: Allocator, reader: *File.Reader, converter: *const fn (char: u8) T) !Grid(T) {
    var lineCount: usize = 0;
    var charCount: usize = 0;

    var l = try reader.interface.takeDelimiter('\n') orelse "";
    while (l.len > 0) : (l = try reader.interface.takeDelimiter('\n') orelse "") {
        lineCount += 1;
        charCount = @max(charCount, l.len);
    }

    const grid = try Grid(T).init(allocator, charCount, lineCount);

    try reader.seekTo(0);

    l = try reader.interface.takeDelimiter('\n') orelse "";
    var y: usize = 0;
    while (l.len > 0) : (l = try reader.interface.takeDelimiter('\n') orelse "") {
        for (l, 0..) |char, x| {
            const v = converter(char);
            try grid.set(x, y, v);
        }
        y += 1;
    }

    return grid;
}
