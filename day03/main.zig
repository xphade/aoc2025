const std = @import("std");

/// Returns the index of the largest digit in the given array of ASCII `digits`. If the largest
/// digit appears multiple times, the index of the first occurrence is returned.
fn getIndexOfLargestValue(digits: []const u8) usize {
    var max: u8 = 0;
    var max_index: usize = 0;
    for (digits, 0..) |i, index| {
        const num = i - '0';
        if (num > max) {
            max = num;
            max_index = index;
        }
    }
    return max_index;
}

/// Calculates the largest joltage by selecting the highest digits from the `bank` string. If
/// `entries > bank.len`, it returns the bank input 0-padded to entries length.
fn calculateLargestJoltage(bank: []const u8, comptime entries: usize) [entries]u8 {
    var result = [_]u8{'0'} ** entries;
    if (bank.len <= entries) {
        const start_idx: usize = entries - bank.len;
        @memcpy(result[start_idx..], bank);
        return result;
    }

    // We always find the largest value from the longest substring that still allows us to fill all
    // entries. For example, if entries = 4:
    // 1. 234194908124
    //    ^-------^    Find the largest value in this range, to allow at least 3 more entries.
    // 2.      ^---^   '9' was the largest value, continue from there and leave room for 2 more.
    // Do this two more times and you end up with the largest joltage '9984'.
    var start_index: usize = 0;
    for (0..entries) |i| {
        const end_index = bank.len - (entries - i) + 1;
        const best_index = start_index + getIndexOfLargestValue(bank[start_index..end_index]);
        result[i] = bank[best_index];
        start_index = best_index + 1;
    }
    return result;
}

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len != 2) {
        std.debug.print("Expected exactly one argument, got {}\n", .{args.len - 1});
        std.process.exit(1);
    }

    var file = try std.fs.cwd().openFile(args[1], .{ .mode = .read_only });
    defer file.close();

    const file_size = (try file.stat()).size;
    const buffer = try alloc.alloc(u8, file_size);
    defer alloc.free(buffer);

    const read_size = try file.read(buffer);
    std.debug.assert(read_size == file_size);

    var total_joltage_p1: u64 = 0;
    var total_joltage_p2: u64 = 0;

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue; // Handle trailing newline character.

        const joltage_p1 = calculateLargestJoltage(line, 2);
        const joltage_p2 = calculateLargestJoltage(line, 12);

        total_joltage_p1 += try std.fmt.parseInt(u64, joltage_p1[0..], 10);
        total_joltage_p2 += try std.fmt.parseInt(u64, joltage_p2[0..], 10);
    }

    std.debug.print("Solution to part 1: {}\n", .{total_joltage_p1});
    std.debug.print("Solution to part 2: {}\n", .{total_joltage_p2});
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
    try std.testing.expect(std.mem.eql(
        u8,
        &calculateLargestJoltage("234194908124", 4),
        "9984",
    ));
    try std.testing.expect(std.mem.eql(
        u8,
        &calculateLargestJoltage("42", 2),
        "42",
    ));
    try std.testing.expect(std.mem.eql(
        u8,
        &calculateLargestJoltage("1234", 6),
        "001234",
    ));
}
