//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const Circle = @import("./datatypes/circle.zig");
const Sphere = @import("./datatypes/sphere.zig");
const draw_circle = @import("./circle/circle.zig");
const print_image = @import("./image/image.zig");
const vector_calc = @import("./helpers/vectors.zig");

// image parameters

pub fn main() !void {
    const CAMERA_RIGHT = [_]i64{ 1, 0, 0 };
    const CAMERA_UP = [_]i64{ 0, 1, 0 };
    const FOCAL_DISTANCE: i64 = 10;
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
    _ = CAMERA_RIGHT;
    _ = CAMERA_UP;

    rayCollision(0, 0, LENGTH, HEIGHT, &sphere, &CAMERA_POSITION, FOCAL_DISTANCE);
}

pub fn rayCollision(x: i64, y: i64, length: i64, height: i64, sphere: *const Sphere.Sphere, camera_position: *const [3]i64, focal_distance: i64) void {
    const direction = [_]i64{ -1 * @divExact(length, 2) + x, @divExact(height, 2) - y, focal_distance };
    std.debug.print("direction {any}\n", .{direction});
    const a = vector_calc.scalarProduct(&direction, &direction);
    const w = vector_calc.multiplyNumber(&direction, 2);
    const vm = vector_calc.subtractVector(camera_position, &sphere.center);
    const b = vector_calc.scalarProduct(&w, &vm);
    const c = vector_calc.scalarProduct(&vm, &vm) - sphere.radius * sphere.radius;
    std.debug.print("a = {}, b = {}, c = {}", .{ a, b, c });
}
