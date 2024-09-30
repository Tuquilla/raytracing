const std = @import("std");

pub fn scalar(left_vector: *const [3]i64, right_vector: *const [3]i64) i64 {
    var sum: i64 = 0;
    for (left_vector.*, 0..) |_, index| {
        sum += left_vector[index] * right_vector[index];
    }
    return sum;
}

pub fn subtractVector(left_vector: *[3]i64, right_vector: *[3]i64) [3]i64 {
    var result = [_]i64{ undefined, undefined, undefined };
    for (left_vector.*, 0..) |_, index| {
        result[index] = left_vector[index] - right_vector[index];
    }
    return result;
}

pub fn addVector(left_vector: *[3]i64, right_vector: *[3]i64) [3]i64 {
    var result = [_]i64{ undefined, undefined, undefined };
    for (left_vector.*, 0..) |_, index| {
        result[index] = left_vector[index] + right_vector[index];
    }
    return result;
}

test "scalar" {
    // 44 -24 -90
    const left_vector = [_]i64{ 4, 6, -9 };
    const right_vector = [_]i64{ 11, -4, 10 };
    var sum: i64 = 0;

    sum = scalar(&left_vector, &right_vector);

    try std.testing.expectEqual(-70, sum);
}

test "subtraction" {
    var left_vector = [_]i64{ 4, 6, -9 };
    var right_vector = [_]i64{ 11, -4, 10 };
    var result = [_]i64{ undefined, undefined, undefined };

    result = subtractVector(&left_vector, &right_vector);

    try std.testing.expectEqual(result, [_]i64{ -7, 10, -19 });
}

test "addition" {
    var left_vector = [_]i64{ 4, 6, -9 };
    var right_vector = [_]i64{ 11, -4, 10 };
    var result = [_]i64{ undefined, undefined, undefined };

    result = addVector(&left_vector, &right_vector);

    try std.testing.expectEqual(result, [_]i64{ 15, 2, 1 });
}
