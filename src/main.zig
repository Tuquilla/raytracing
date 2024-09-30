//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const Circle = @import("./datatypes/circle.zig");
const Sphere = @import("./datatypes/sphere.zig");
const draw_circle = @import("./circle/circle.zig");
const print_image = @import("./image/image.zig");

// image parameters

pub fn main() !void {
    const CAMERA_RIGHT = [_]i64{ 1, 0, 0 };
    const CAMERA_UP = [_]i64{ 0, 1, 0 };
    const FOCAL_DISTANCE = 10;
    const CAMERA_POSITION = [_]i64{ 0, 0, -20 };
    const SPHERE_CENTRE = [_]i64{ 0, 0, 0 };
    const LENGTH: i64 = 64;
    const HEIGHT: i64 = 48;
    const HEADER_TYPE = "P6\n";
    const MAX_COLOR = "255\n";
    const RADIUS: i64 = 5;
    const circle = Circle.Circle{ .origin_x = LENGTH / 2, .origin_y = HEIGHT / 2, .radius = RADIUS };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var image_heap = try allocator.alloc([]u8, HEIGHT);
    defer allocator.free(image_heap);

    for (image_heap) |*row| {
        row.* = try allocator.alloc(u8, LENGTH);
    }
    defer {
        for (image_heap) |row| {
            allocator.free(row);
        }
    }

    // 2D, circling around
    print_image.createImage(&image_heap);
    draw_circle.drawCircle(&image_heap, circle);
    print_image.drawImage(&image_heap);
    try print_image.drawImageAsPPM(&image_heap, LENGTH, HEIGHT, MAX_COLOR, HEADER_TYPE);

    // 3D
    const sphere = Sphere.Sphere{ .radius = RADIUS, .center = SPHERE_CENTRE };
    _ = sphere;
    _ = FOCAL_DISTANCE;
    _ = CAMERA_POSITION;
    _ = CAMERA_RIGHT;
    _ = CAMERA_UP;
}

pub fn calculateRay(image: *[][]u8, sphere: Sphere, camera_position: [3]u8, focal_distance: comptime_int) void {}
