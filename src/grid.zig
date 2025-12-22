const std = @import("std");
const Allocator = std.mem.Allocator;

const OutOfBoundsError = error{
    XOutOfBounds,
    YOutOfBounds,
};

pub const CellRef = struct {
    x: usize,
    y: usize,
};

pub fn Grid(comptime T: type) type {
    return struct {
        const Self = @This();
        array: []T,
        allocator: Allocator,
        x_capacity: usize,
        y_capacity: usize,

        pub fn init(allocator: Allocator, x_size: usize, y_size: usize) !Self {
            return Self{
                .array = try allocator.alloc(T, x_size * y_size),
                .x_capacity = x_size,
                .y_capacity = y_size,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self, allocator: Allocator) void {
            allocator.free(self.array);
        }

        pub fn get(self: Self, x: usize, y: usize) !T {
            try self.checkBounds(x, y);
            return self.array[self.getCellRef(x, y)];
        }

        pub fn set(self: Self, x: usize, y: usize, value: T) !void {
            try self.checkBounds(x, y);
            self.array[self.getCellRef(x, y)] = value;
        }

        fn getCellRef(self: Self, x: usize, y: usize) usize {
            return y * self.x_capacity + x;
        }

        fn checkBounds(self: Self, x: usize, y: usize) !void {
            if (x >= self.x_capacity) return OutOfBoundsError.XOutOfBounds;
            if (y >= self.y_capacity) return OutOfBoundsError.YOutOfBounds;
        }

        pub fn getAllCellNeighbours(self: Self, x: usize, y: usize, default: T) [8]T {
            var neighbours = [_]T{default} ** 8;
            var i: u8 = 0;
            for (0..3) |delta_x| {
                for (0..3) |delta_y| {
                    if (delta_x == 1 and delta_y == 1) continue;

                    if ((x == 0 and delta_x == 0) or (y == 0 and delta_y == 0)) {
                        i += 1;
                        continue;
                    }
                    const neighbour_x = x + delta_x - 1;
                    const neighbour_y = y + delta_y - 1;
                    const v = self.get(neighbour_x, neighbour_y) catch default;
                    neighbours[i] = v;
                    i += 1;
                }
            }
            return neighbours; // is this ok? I thought this would be cleared from memory on exit of this function but it seems to work for some reason...
        }
    };
}
