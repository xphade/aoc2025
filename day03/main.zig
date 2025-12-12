const std = @import("std");

fn getIndexOfLargestValue(arr: []const u8) usize {
    var max: u8 = 0;
    var max_index: usize = 0;
    for (arr, 0..) |i, index| {
        const num = i - '0';
        if (num > max) {
            max = num;
            max_index = index;
        }
    }
    return max_index;
}

fn calculateLargestJoltage(bank: []const u8, comptime entries: usize) [entries]u8 {
    var result: [entries]u8 = undefined;
    var start_index: usize = 0;
    for (0..entries) |i| {
        const end_index = bank.len - (entries - i) + 1;
        const best_idx = getIndexOfLargestValue(bank[start_index..end_index]);
        result[i] = bank[start_index + best_idx];
        start_index += (best_idx + 1);
    }
    return result;
}

pub fn main() !void {
    std.debug.print("Hello, Advent of Code Day 3!\n", .{});
}

test "getIndexOfLargestValue" {
    try std.testing.expectEqual(getIndexOfLargestValue("01234"), 4);
    try std.testing.expectEqual(getIndexOfLargestValue("43210"), 0);
    try std.testing.expectEqual(getIndexOfLargestValue("24301"), 1);
    try std.testing.expectEqual(getIndexOfLargestValue("00010"), 3);
    try std.testing.expectEqual(getIndexOfLargestValue("12233"), 3);
}

test "calculateLargestJoltage" {
    try std.testing.expect(std.mem.eql(
        u8,
        &calculateLargestJoltage("818181911112111", 2),
        "92",
    ));
    try std.testing.expect(std.mem.eql(
        u8,
        &calculateLargestJoltage("234234234234278", 12),
        "434234234278",
    ));
}
