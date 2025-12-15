pub fn Range(comptime T: type) type {
    return struct {
        const Self = @This();
        min: T,
        max: T,

        pub fn init(min: T, max: T) Range(T) {
            return Self{
                .min = min,
                .max = max,
            };
        }

        pub fn contains(self: Self, n: T) bool {
            return self.min <= n and n < self.max;
        }

        pub fn overlaps(self: Self, other: Range(T)) bool {
            return self.contains(other.min) or self.contains(other.max) or other.contains(self.min) or other.contains(self.max);
        }

        pub fn combine(self: Self, other: Range(T)) Range(T) {
            const min = @min(self.min, other.min);
            const max = @max(self.max, other.max);
            return Range(T).init(min, max);
        }

        pub fn size(self: Self) T {
            return self.max - self.min;
        }
    };
}
