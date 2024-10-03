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
    const RADIUS: i64 = 5;
    const HEADER_TYPE = "P6\n";
    const MAX_COLOR = "255\n";
    const circle = Circle.Circle{ .origin_x = LENGTH / 2, .origin_y = HEIGHT / 2, .radius = RADIUS };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var image_2D = try allocator.alloc([]u8, HEIGHT);
    defer allocator.free(image_2D);

    for (image_2D) |*row| {
        row.* = try allocator.alloc(u8, LENGTH);
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
    var image_3D = try allocator.alloc([]u8, HEIGHT);
    defer allocator.free(image_3D);

    for (image_3D) |*row| {
        row.* = try allocator.alloc(u8, LENGTH);
    }
    defer {
        for (image_3D) |row| {
            allocator.free(row);
        }
    }
    print_image.createImage(&image_3D);

    const sphere = Sphere.Sphere{ .radius = RADIUS, .center = SPHERE_CENTRE };
    _ = CAMERA_RIGHT;
    _ = CAMERA_UP;

    for (image_3D, 0..) |*row, y| {
        for (row.*, 0..) |_, x| {
            if (ray(@as(i64, @intCast(x)), @as(i64, @intCast(y)), LENGTH, HEIGHT, &sphere, &CAMERA_POSITION, FOCAL_DISTANCE)) {
                image_3D[y][x] = 'x';
            }
        }
    }
    print_image.drawImage(&image_3D);
    try print_image.drawImageAsPPM(&image_3D, LENGTH, HEIGHT, MAX_COLOR, HEADER_TYPE);
    //const v = ray(64, 64, LENGTH, HEIGHT, &sphere, &CAMERA_POSITION, FOCAL_DISTANCE);
    //std.debug.print("v: {}", .{v});
}

pub fn ray(x: i64, y: i64, length: i64, height: i64, sphere: *const Sphere.Sphere, camera_position: *const [3]i64, focal_distance: i64) bool {
    const direction = [_]i64{ -1 * @divExact(length, 2) + x, @divExact(height, 2) - y, focal_distance };
    //std.debug.print("direction {any}\n", .{direction});
    const a = vector_calc.scalarProduct(&direction, &direction);
    const w = vector_calc.multiplyNumber(&direction, 2);
    const vm = vector_calc.subtractVector(camera_position, &sphere.center);
    const b = vector_calc.scalarProduct(&w, &vm);
    const c = vector_calc.scalarProduct(&vm, &vm) - std.math.pow(i64, sphere.radius, 2);
    //std.debug.print("a = {}, b = {}, c = {}", .{ a, b, c });
    if (rayCollision(a, b, c)) {
        return true;
    }
    return false;
}

pub fn rayCollision(a: i64, b: i64, c: i64) bool {
    if (intersect(a, b, c)) {
        return true;
    }
    return false;
}

pub fn intersect(a: i64, b: i64, c: i64) bool {
    if (std.math.pow(i64, b, 2) - 4 * a * c > 0) {
        return true;
    }
    return false;
}
