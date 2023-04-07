const std = @import("std");
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

pub fn isValidIsbn10(s2: []const u8) bool {
    return isValidIsbn10WithErr(s2) catch |err| {
        std.debug.panic("{}", .{err});
    };
}

pub fn isValidIsbn10WithErr(s2: []const u8) !bool {
    var list = ArrayList(u8).init(test_allocator);
    var it = std.mem.tokenize(u8, s2, "-");

    while (it.next()) |t| {
        try list.appendSlice(t);
    }

    // TODO: change to `const s: []const u8 = try list.toOwnedSlice();` in zig 0.11
    const s: []const u8 = list.toOwnedSlice();

    // [gpa] (err): memory address leaked
    // Because you called toOwnedSlice() you technically manage to avoid a leak [with knowledge of the implementation of ArrayList] but it's still something you should be doing unless you intend to return the ArrayList and can do so in a guaranteed fashion.
    // https://www.reddit.com/r/Zig/comments/mea1ks/comment/gshwigb/
    defer std.testing.allocator.free(s);

    if (s.len != 10) return false;
    // std.debug.print("\ns: {s}\n", .{s});

    var sum: usize = 0;

    // TODO: change to `for (s, 0..) |c2, i| {` in zig 0.11
    for (s) |c2, i| {
        var c: u8 = undefined;
        if (c2 == 'X') {
            if (i != 9) return false;
            c = ':';
        } else c = c2;

        if (c < '0' or c > ':') return false;
        const num = c - 48;
        const segment = num * (10 - i);
        // std.debug.print("{c} {} {} {}\n", .{ c2, c, num, segment });
        sum += segment;
    }
    return sum % 11 == 0;
}
