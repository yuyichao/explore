//

fn print_type_i32(_: i32) {
    println!("i32")
}

fn print_type_f64(_: f64) {
    println!("f64")
}

trait PrintType {
    fn print_type(&self);
}

impl PrintType for i32 {
    fn print_type(&self) {
        println!("i32")
    }
}

impl PrintType for f64 {
    fn print_type(&self) {
        println!("f64")
    }
}

fn print_type<T: PrintType>(a: T) {
    println!("Type name:");
    a.print_type();
}

fn main() {
    print_type_i32(1i32);
    print_type_f64(1.2f64);
    print_type(1i32);
    print_type(1.2f64);
}
