//

fn identity_bool(a: bool) -> bool {
    return a;
}

fn identity_i32(a: i32) -> i32 {
    return a;
}

fn identity<T>(a: T) -> T {
    return a;
}

fn main() {
    println!("{} {}", identity_bool(true), identity_i32(3));
    println!("{} {}", identity(true), identity(3));
}
