const std = @import("std");

pub fn createImage(image: *[][]u32) void {
    for (image.*) |row| {
        for (row) |*pixel| {
            pixel.* = 0xffffff;
        }
    }
}

pub fn drawImage(image: *[][]u32) void {
    for (image.*) |row| {
        for (row) |*pixel| {
            std.debug.print("{c}", .{pixel.*});
        }
        std.debug.print("\n", .{});
    }
}

pub fn drawImageAsPPM(image: *[][]u32, length: i64, height: i64, max_color: *const [4:0]u8, header: *const [3:0]u8) !void {
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
            try file.writeAll(hexToRgb(pixel.*));
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

pub fn hexToRgb(hex: u32) *[3]u8 {
    const r = @as(u8, @intCast((hex >> 16) & 0xFF));
    const g = @as(u8, @intCast((hex >> 8) & 0xFF));
    const b = @as(u8, @intCast(hex & 0xFF));

    var rgb = [_]u8{ r, g, b };
    return &rgb;
}

pub fn rgbToHex(r: u8, g: u8, b: u8) u32 {
    return (@as(u32, r) << 16) | (@as(u32, g) << 8) | @as(u32, b);
}
