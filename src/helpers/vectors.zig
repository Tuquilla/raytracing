const std = @import("std");

pub fn scalarProduct(left_vector: *const [3]f64, right_vector: *const [3]f64) f64 {
    var sum: f64 = 0;
    for (left_vector.*, 0..) |_, index| {
        sum += left_vector[index] * right_vector[index];
    }
    return sum;
}

pub fn subtractVector(left_vector: *const [3]f64, right_vector: *const [3]f64) [3]f64 {
    var result = [_]f64{ undefined, undefined, undefined };
    for (left_vector.*, 0..) |_, index| {
        result[index] = left_vector[index] - right_vector[index];
    }
    return result;
}

pub fn addVector(left_vector: *const [3]f64, right_vector: *const [3]f64) [3]f64 {
    var result = [_]f64{ undefined, undefined, undefined };
    for (left_vector.*, 0..) |_, index| {
        result[index] = left_vector[index] + right_vector[index];
    }
    return result;
}

pub fn multiplyNumber(left_vector: *const [3]f64, multiplier: f64) [3]f64 {
    var result = [_]f64{ undefined, undefined, undefined };
    for (left_vector.*, 0..) |_, index| {
        result[index] = left_vector[index] * multiplier;
    }
    return result;
}

pub fn vectorLength(vector: *const [3]f64) f64 {
    const expos = std.math.pow(f64, vector[0], 2) + std.math.pow(f64, vector[1], 2) + std.math.pow(f64, vector[2], 2);
    return std.math.sqrt(expos);
}

test "vector length" {
    const vector = [_]f64{ 3, 4, 0 };
    const length = vectorLength(&vector);

    try std.testing.expectEqual(5, length);
}

test "scalar product" {
    // 44 -24 -90
    const left_vector = [_]f64{ 4, 6, -9 };
    const right_vector = [_]f64{ 11, -4, 10 };

    const sum = scalarProduct(&left_vector, &right_vector);
    const sum2 = scalarProduct(&left_vector, &left_vector);

    try std.testing.expectEqual(-70, sum);
    try std.testing.expectEqual(133, sum2);
}

test "subtraction" {
    const left_vector = [_]f64{ 4, 6, -9 };
    const right_vector = [_]f64{ 11, -4, 10 };

    const result = subtractVector(&left_vector, &right_vector);

    try std.testing.expectEqual(result, [_]f64{ -7, 10, -19 });
}

test "addition" {
    const left_vector = [_]f64{ 4, 6, -9 };
    const right_vector = [_]f64{ 11, -4, 10 };

    const result = addVector(&left_vector, &right_vector);

    try std.testing.expectEqual(result, [_]f64{ 15, 2, 1 });
}

test "multiplication" {
    const left_vector = [_]f64{ 4, 6, -9 };
    const multiplier: f64 = 10;

    const result = multiplyNumber(&left_vector, multiplier);

    try std.testing.expectEqual(result, [_]f64{ 40, 60, -90 });
}
