// Socket - accept TCP connections
const std = @import("std");

const alloc = std.testing.allocator;
const max_msg_size = 1024;

test "Verify that listener can be created" {
    // FIXME does not work on Windows
    if (@import("builtin").os.tag == .windows) {
        return;
    }
    var listener = try localhostListener(0);
    defer listener.deinit();
}

fn printMessage(reader: *std.net.Stream.Reader) !void {
    const msg = try reader.readAllAlloc(alloc, max_msg_size);
    defer alloc.free(msg);
    std.debug.print("Got message: {s}", .{msg});
}

// Sample starts herefn localhostListener(port: u16) !std.net.StreamServer {
    const localhost = try std.net.Address.resolveIp("0.0.0.0", port);
    var listener = std.net.StreamServer.init(.{});
    try listener.listen(localhost);
    return listener;
}

pub fn main() !void {
    var listener = try localhostListener(8081);
    defer listener.deinit();

    const connection = try listener.accept();
    defer connection.stream.close();

    std.log.info("Accepted connection from {}", .{connection.address});
    try printMessage(&connection.stream.reader());
} //  Sample ends 