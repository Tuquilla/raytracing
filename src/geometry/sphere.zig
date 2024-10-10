const Sphere = @import("../datatypes/sphere.zig");
const std = @import("std");
const vector_calc = @import("../helpers/vectors.zig");

pub fn drawSphere(image_3D: *[][]u32, length: i64, height: i64, sphere: *const Sphere.Sphere, camera_position: *const [3]i64, focal_distance: i64) void {
    for (image_3D.*, 0..) |row, y| {
        for (row, 0..) |_, x| {
            if (ray(@as(i64, @intCast(x)), @as(i64, @intCast(y)), length, height, sphere, camera_position, focal_distance)) {
                image_3D.*[y][x] = sphere.color;
            }
        }
    }
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

fn rayCollision(a: i64, b: i64, c: i64) bool {
    if (intersect(a, b, c)) {
        return true;
    }
    return false;
}

fn intersect(a: i64, b: i64, c: i64) bool {
    if (std.math.pow(i64, b, 2) - 4 * a * c > 0) {
        return true;
    }
    return false;
}
