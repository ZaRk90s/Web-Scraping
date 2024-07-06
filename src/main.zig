const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    var html_content = std.ArrayList(u8).init(allocator);
    defer html_content.deinit();

    _ = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = "https://google.es" },
        .response_storage = .{ .dynamic = &html_content },
    });

    const start_target: []const u8 = "<title>";
    const finall_target: []const u8 = "</title>";

    const start_position = std.mem.indexOf(u8, html_content.items, start_target);
    const end_position = std.mem.indexOf(u8, html_content.items, finall_target);

    if (start_position == null or end_position == null) {
        print("There is no {s} etiquete in the code\n\n", .{start_target});
    }

    const start_index = start_position.?;
    const end_index = end_position.?;

    var inside_tag = false;
    for (html_content.items[start_index..end_index]) |content| {
        if (content == '<') {
            inside_tag = true;
        } else if (content == '>') {
            inside_tag = true;
        } else if (!inside_tag) {
            print("\n[+] The tag is: {c}\n", .{content});
        }
    }
}
