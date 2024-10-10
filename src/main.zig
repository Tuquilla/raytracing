//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const Circle = @import("./datatypes/circle.zig");
const Sphere = @import("./datatypes/sphere.zig");
const draw_circle = @import("./geometry/circle.zig");
const print_image = @import("./image/image.zig");
const vector_calc = @import("./helpers/vectors.zig");
const draw_sphere = @import("./geometry/sphere.zig");

pub fn main() !void {
    const CAMERA_RIGHT = [_]i64{ 1, 0, 0 };
    const CAMERA_UP = [_]i64{ 0, 1, 0 };
    const FOCAL_DISTANCE: i64 = 10;
    const CAMERA_POSITION = [_]i64{ 0, 0, -20 };
    const SPHERE_CENTRE = [_]i64{ 0, 0, 0 };
    const LENGTH: i64 = 64;
    const HEIGHT: i64 = 48;
    const RADIUS: i64 = 5;
    const COLOR_SPHERE_1: u32 = 0x00ff00;
    const HEADER_TYPE = "P6\n";
    const MAX_COLOR = "255\n";
    const circle = Circle.Circle{ .origin_x = LENGTH / 2, .origin_y = HEIGHT / 2, .radius = RADIUS };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var image_2D = try allocator.alloc([]u32, HEIGHT);
    defer allocator.free(image_2D);

    for (image_2D) |*row| {
        row.* = try allocator.alloc(u32, LENGTH);
    }
    defer {
        for (image_2D) |row| {
            allocator.free(row);
        }
    }

    // 2D, circling around
    print_image.createImage(&image_2D);
    draw_circle.drawCircle(&image_2D, circle);
    //print_image.drawImage(&image_2D);
    try print_image.drawImageAsPPM(&image_2D, LENGTH, HEIGHT, MAX_COLOR, HEADER_TYPE);

    // 3D
    // allocate memory for image
    var image_3D = try allocator.alloc([]u32, HEIGHT);
    defer allocator.free(image_3D);

    for (image_3D) |*row| {
        row.* = try allocator.alloc(u32, LENGTH);
    }
    defer {
        for (image_3D) |row| {
            allocator.free(row);
        }
    }

    // fill image with "."
    print_image.createImage(&image_3D);

    // first sphere in image
    const sphere = Sphere.Sphere{ .radius = RADIUS, .center = SPHERE_CENTRE, .color = COLOR_SPHERE_1 };
    _ = CAMERA_RIGHT;
    _ = CAMERA_UP;

    // draw sphere in image
    draw_sphere.drawSphere(&image_3D, LENGTH, HEIGHT, &sphere, &CAMERA_POSITION, FOCAL_DISTANCE);

    // print image with green color
    //print_image.drawImage(&image_3D);
    try print_image.drawImageAsPPM(&image_3D, LENGTH, HEIGHT, MAX_COLOR, HEADER_TYPE);
}
