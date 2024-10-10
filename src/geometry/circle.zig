const Circle = @import("../datatypes/circle.zig");
const std = @import("std");

pub fn drawCircle(image: *[][]u32, circle: Circle.Circle) void {
    for (image.*, 0..) |row, index_column| {
        for (row, 0..) |_, index_row| {
            if (IsInsideCircle(circle, @as(i64, @intCast(index_column)), @as(i64, @intCast(index_row)))) {
                image.*[index_row][index_column] = 'x';
            }
        }
    }
}

fn IsInsideCircle(circle: Circle.Circle, x: i64, y: i64) bool {
    const r_square = circle.radius * circle.radius;
    const a: i64 = x - circle.origin_x;
    const b: i64 = y - circle.origin_y;
    if (((a * a) + (b * b)) <= r_square) {
        return true;
    }
    return false;
}
