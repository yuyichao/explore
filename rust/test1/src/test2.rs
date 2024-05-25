//

fn addself_i64(a: i64) -> i64 {
    return a + a;
}

fn addself_i32(a: i32) -> i32 {
    return a + a;
}

fn addself<T: std::ops::Add<Output = T> + Copy>(a: T) -> T {
    return a + a;
}

fn main() {
    println!("{} {}", addself_i64(23_i64), addself_i32(3_i32));
    println!("{} {}", addself(23_i64), addself(3_i32));
}
