const std = @import("std");

pub fn createImage(image: *[][]u8) void {
    for (image.*) |row| {
        for (row) |*pixel| {
            pixel.* = '.';
        }
    }
}

pub fn drawImage(image: *[][]u8) void {
    for (image.*) |row| {
        for (row) |*pixel| {
            std.debug.print("{c}", .{pixel.*});
        }
        std.debug.print("\n", .{});
    }
}

pub fn drawImageAsPPM(image: *[][]u8, length: i64, height: i64, max_color: *const [4:0]u8, header: *const [3:0]u8) !void {
    const file = try std.fs.cwd().createFile(
        "./files/image_circle.ppm",
        .{ .read = true },
    );
    defer file.close();

    try file.writeAll(header);

    var buf: [20]u8 = undefined;
    const numAsString = try std.fmt.bufPrint(&buf, "{} {}\n", .{ length, height });
    try file.writeAll(numAsString);
    try file.writeAll(max_color);
    for (image.*) |row| {
        for (row) |*pixel| {
            if (pixel.* == 'x') {
                const bytes: [3]u8 = .{ 0, 255, 0 };
                try file.writeAll(&bytes);
            } else {
                const bytes: [3]u8 = .{ 255, 255, 255 };
                try file.writeAll(&bytes);
            }
        }
    }
}

pub fn drawImageAsPPMTest() !void {
    const header = "P3\n3 2\n";
    const max_color = "255\n";
    const image =
        \\255   0   0     0 255   0     0   0 255
        \\255 255   0   255 255 255     0   0   0
    ;

    const file = try std.fs.cwd().createFile(
        "./files/test_image.ppm",
        .{ .read = true },
    );
    defer file.close();

    try file.writeAll(header);
    try file.writeAll(max_color);
    try file.writeAll(image);
}
