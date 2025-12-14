pub fn Range(comptime T: type) type {
    return struct {
        const Self = @This();
        min: T,
        max: T,
        min_inclusive: bool,
        max_inclusive: bool,

        pub fn set(min: T, max: T) Range(T) {
            return Self{
                .min = min,
                .max = max,
                .min_inclusive = true,
                .max_inclusive = false,
            };
        }

        pub fn contains(self: Self, n: T) bool {
            return (n > self.min or (self.min_inclusive and n == self.min)) and (n < self.max or (self.max_inclusive and n == self.max));
        }
    };
}
