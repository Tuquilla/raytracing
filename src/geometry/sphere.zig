const Sphere = @import("../datatypes/sphere.zig");
const std = @import("std");
const vector_calc = @import("../helpers/vectors.zig");

// pub fn drawSphere(image_3D: *[][]u32, length: i64, height: i64, sphere: *const Sphere.Sphere, camera_position: *const [3]i64, focal_distance: i64) void {
//     for (image_3D.*, 0..) |row, y| {
//         for (row, 0..) |_, x| {
//             if (ray(@as(i64, @intCast(x)), @as(i64, @intCast(y)), length, height, sphere, camera_position, focal_distance)) {
//                 if (image_3D.*[y][x] == 0xffffff) {
//                     image_3D.*[y][x] = sphere.color;
//                 }
//             }
//         }
//     }
// }

pub fn drawSphere2(image_3D: *[][]u32, length: i64, height: i64, spheres: *std.ArrayList(Sphere.Sphere), camera_position: *const [3]i64, focal_distance: i64) void {
    for (image_3D.*, 0..) |row, y| {
        for (row, 0..) |_, x| {
            const sphere_index = ray2(@as(i64, @intCast(x)), @as(i64, @intCast(y)), length, height, spheres, camera_position, focal_distance);
            if (sphere_index != -1) {
                image_3D.*[y][x] = spheres.items[@as(usize, @intCast(sphere_index))].color;
            }
        }
    }
}

// fn ray(x: i64, y: i64, length: i64, height: i64, sphere: *const Sphere.Sphere, camera_position: *const [3]i64, focal_distance: i64) bool {
//     const direction = [_]i64{ -1 * @divExact(length, 2) + x, @divExact(height, 2) - y, focal_distance };
//     //std.debug.print("direction {any}\n", .{direction});
//     const a = vector_calc.scalarProduct(&direction, &direction);
//     const w = vector_calc.multiplyNumber(&direction, 2);
//     const vm = vector_calc.subtractVector(camera_position, &sphere.center);
//     const b = vector_calc.scalarProduct(&w, &vm);
//     const c = vector_calc.scalarProduct(&vm, &vm) - std.math.pow(i64, sphere.radius, 2);
//     //std.debug.print("a = {}, b = {}, c = {}", .{ a, b, c });
//     if (rayCollision(a, b, c)) {
//         return true;
//     }
//     return false;
// }

fn ray2(x: i64, y: i64, length: i64, height: i64, spheres: *std.ArrayList(Sphere.Sphere), camera_position: *const [3]i64, focal_distance: i64) i64 {
    var smallest_t: f64 = std.math.floatMax(f64);
    var sphere_index: i64 = -1;
    var index: usize = 0;
    for (spheres.items) |sphere| {
        const direction = [_]i64{ -1 * @divExact(length, 2) + x, @divExact(height, 2) - y, focal_distance };
        const a = vector_calc.scalarProduct(&direction, &direction);
        const w = vector_calc.multiplyNumber(&direction, 2);
        const vm = vector_calc.subtractVector(camera_position, &sphere.center);
        const b = vector_calc.scalarProduct(&w, &vm);
        const c = vector_calc.scalarProduct(&vm, &vm) - std.math.pow(i64, sphere.radius, 2);
        const intersection = intersect2(a, b, c);
        if (intersection < smallest_t and intersection > 0.0) {
            smallest_t = intersect2(a, b, c);
            sphere_index = @as(i64, @intCast(index));
        }
        index += 1;
    }
    return sphere_index;
}

// fn rayCollision(a: i64, b: i64, c: i64) bool {
//     if (intersect(a, b, c)) {
//         return true;
//     }
//     return false;
// }

// fn intersect(a: i64, b: i64, c: i64) bool {
//     if (std.math.pow(i64, b, 2) - 4 * a * c > 0) {
//         return true;
//     }
//     return false;
// }

fn intersect2(a: i64, b: i64, c: i64) f64 {
    var t1: f64 = 0;
    var t2: f64 = 0;
    const diskriminante = std.math.pow(i64, b, 2) - 4 * a * c;
    if (diskriminante > 0) {
        const t1_upper: f64 = @as(f64, @floatFromInt(-b - std.math.sqrt(@as((u64), @intCast(diskriminante)))));
        const t2_upper: f64 = @as(f64, @floatFromInt(-b + std.math.sqrt(@as((u64), @intCast(diskriminante)))));
        const lower: f64 = @as(f64, @floatFromInt(2 * a));
        t1 = t1_upper / lower;
        t2 = t2_upper / lower;
        // smallest t is the closest entry point of a ray into the objective
        if (t1 < t2) {
            return t1;
        } else {
            return t2;
        }
    }
    return t1;
}

test "intersect2" {
    const a = 1;
    const b = -5;
    const c = 6;

    const result = intersect2(a, b, c);

    try std.testing.expectEqual(result, 2.0);
}
