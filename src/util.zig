const std = @import("std");

pub fn getInputFile(day: u8, example: bool) !std.fs.File {
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
