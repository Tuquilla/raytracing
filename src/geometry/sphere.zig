const Sphere = @import("../datatypes/sphere.zig");
const std = @import("std");
const vector_calc = @import("../helpers/vectors.zig");
const image = @import("../image/image.zig");

pub fn drawSphere2(image_3D: *[][]u32, length: f64, height: f64, spheres: *std.ArrayList(Sphere.Sphere), camera_position: *const [3]f64, focal_distance: f64, light_source: *const [3]f64) void {
    for (image_3D.*, 0..) |row, y| {
        for (row, 0..) |_, x| {
            const sphere_index = ray2(@as(f64, @floatFromInt(x)), @as(f64, @floatFromInt(y)), length, height, spheres, camera_position, focal_distance, light_source);
            if (sphere_index[0] != -1) {
                var rgb = image.hexToRgb(spheres.items[@as(usize, @intFromFloat(sphere_index[0]))].color);
                for (rgb, 0..) |_, index| {
                    const v = @as(f64, @floatFromInt(rgb[index])) * sphere_index[1];
                    rgb[index] = @as(u8, @intFromFloat(v));
                }
                const color_hex = image.rgbToHex(rgb[0], rgb[1], rgb[2]);
                image_3D.*[y][x] = color_hex;
            }
        }
    }
}

fn ray2(x: f64, y: f64, length: f64, height: f64, spheres: *std.ArrayList(Sphere.Sphere), camera_position: *const [3]f64, focal_distance: f64, light_source: *const [3]f64) [2]f64 {
    var smallest_t: f64 = std.math.floatMax(f64);
    var sphere_index: i64 = -1;
    var index: usize = 0;
    var color_intensity: f64 = 0;
    var return_values = [_]f64{ 0, 0 };
    for (spheres.items) |sphere| {
        const direction = [_]f64{ -1 * @divExact(length, 2) + x, @divExact(height, 2) - y, focal_distance };
        const a = vector_calc.scalarProduct(&direction, &direction);
        const w = vector_calc.multiplyNumber(&direction, 2);
        const vm = vector_calc.subtractVector(camera_position, &sphere.center);
        const b = vector_calc.scalarProduct(&w, &vm);
        const c = vector_calc.scalarProduct(&vm, &vm) - std.math.pow(f64, sphere.radius, 2);
        const intersection = intersect2(a, b, c);
        if (intersection < smallest_t and intersection > 0.0) {
            smallest_t = intersection;
            sphere_index = @as(i64, @intCast(index));
            const entry_coordinates = entryPointCoordinates(smallest_t, &direction, camera_position);

            const direction_p = [_]f64{ entry_coordinates[0] - light_source[0], entry_coordinates[1] - light_source[1], entry_coordinates[2] - light_source[2] };
            // Check, ob Oberfläche der Lichtquelle direkt ausgesetzt ist
            const t_upper = direction_p[0] * entry_coordinates[0] + direction_p[1] * entry_coordinates[1] + direction_p[2] * entry_coordinates[2];
            const t_lower = std.math.pow(f64, direction_p[0], 2) + std.math.pow(f64, direction_p[1], 2) + std.math.pow(f64, direction_p[2], 2);
            const intersection_p = t_upper / t_lower;
            // Fall Licht durch eine Sphäre (auch die eigene) blockiert ist, ist der Wert > 0
            if (intersection_p >= 0.0) {
                color_intensity = 0.0;
            } else {
                const normal_vector = normalVector(&sphere, &entry_coordinates);
                const light_intensity = lightIntensity(light_source, &entry_coordinates);
                color_intensity = @abs(vector_calc.scalarProduct(&light_intensity, &normal_vector));
                //std.debug.print("normal vector: {any}", .{normal_vector});
            }
        }
        index += 1;
    }
    return_values[0] = @as(f64, @floatFromInt(sphere_index));
    return_values[1] = color_intensity;
    return return_values;
}

fn intersect2(a: f64, b: f64, c: f64) f64 {
    var t1: f64 = 0;
    var t2: f64 = 0;
    const diskriminante = std.math.pow(f64, b, 2) - 4 * a * c;
    //std.debug.print("Diskriminante: {}\n", .{diskriminante});
    const t1_upper: f64 = -b - std.math.sqrt(diskriminante);
    const t2_upper: f64 = -b + std.math.sqrt(diskriminante);
    const lower: f64 = 2 * a;
    t1 = t1_upper / lower;
    t2 = t2_upper / lower;
    // smallest t is the closest entry point of a ray into the objective
    if (t1 < t2) {
        return t1;
    } else {
        return t2;
    }
}

fn entryPointCoordinates(t: f64, direction: *const [3]f64, camera_position: *const [3]f64) [3]f64 {
    var entry_coordinates = [3]f64{ 0, 0, 0 };
    for (entry_coordinates, 0..) |_, index| {
        entry_coordinates[index] = camera_position[index] + t * direction[index];
    }
    return entry_coordinates;
}

fn normalVector(sphere: *const Sphere.Sphere, entry_coordinates: *const [3]f64) [3]f64 {
    var normal_vector = [3]f64{ 0, 0, 0 };
    var sum: f64 = 0;
    for (normal_vector, 0..) |_, index| {
        normal_vector[index] = entry_coordinates[index] - sphere.center[index];
        sum += std.math.pow(f64, normal_vector[index], 2);
    }
    sum = std.math.sqrt(sum);
    for (normal_vector, 0..) |_, index| {
        normal_vector[index] = normal_vector[index] / sum;
    }
    return normal_vector;
}

fn lightIntensity(light_source: *const [3]f64, entry_coordinates: *const [3]f64) [3]f64 {
    var top = vector_calc.subtractVector(light_source, entry_coordinates);
    const bottom = vector_calc.vectorLength(&top);
    for (top, 0..) |_, index| {
        top[index] = top[index] / bottom;
    }
    return top;
}

fn straightnessOfLight(light_intensity: *const [3]f64, normal_vector: *const [3]f64) f64 {
    return vector_calc.scalarProduct(light_intensity, normal_vector);
}

test "light intensity" {
    const light_source = [_]f64{ 0, 5, 0 };
    const entry_coordinate = [_]f64{ 0, 0, 0 };
    const expect = [_]f64{ 0, 0, 0 };

    const result = lightIntensity(light_source, entry_coordinate);

    try std.testing.expectEqual(expect, result);
}

test "intersect2" {
    const a = 1;
    const b = -5;
    const c = 6;

    const result = intersect2(a, b, c);

    try std.testing.expectEqual(2.0, result);
}

test "entry point coordinates" {
    const camera_position = [_]f64{ 0, 0, 0 };
    const direction = [_]f64{ 1, 1, 1 };
    const t: f64 = 1.2;
    const result = entryPointCoordinates(t, &direction, &camera_position);
    const compare = [_]f64{ 1.2, 1.2, 1.2 };

    for (result, 0..) |_, index| {
        try std.testing.expectEqual(compare[index], result[index]);
    }
}
