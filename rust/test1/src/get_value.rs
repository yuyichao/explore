//

enum Value {
    Integer(i64),
    Float(f64),
    Boolean(bool),
}

trait GetValue<T> {
    fn get_value(&self, def: T) -> T;
}

impl GetValue<bool> for Value {
    fn get_value(&self, def: bool) -> bool {
        match self {
            Value::Boolean(v) => *v,
            _ => def,
        }
    }
}

impl GetValue<i64> for Value {
    fn get_value(&self, def: i64) -> i64 {
        match self {
            Value::Integer(v) => *v,
            _ => def,
        }
    }
}

impl GetValue<f64> for Value {
    fn get_value(&self, def: f64) -> f64 {
        match self {
            Value::Float(v) => *v,
            _ => def,
        }
    }
}

fn load_var<T>(o: &Option<Value>, def: T) -> T
where
    Value: GetValue<T>
{
    let value = match o {
        Some(v) => v,
        _ => return def
    };
    return value.get_value(def);
}

fn main() {
    let vb = Value::Boolean(true);
    let vi = Value::Integer(23);
    let vf = Value::Float(3.4);

    println!("{} {} {}", vb.get_value(false), vb.get_value(0), vb.get_value(0.0));
    println!("{} {} {}", vi.get_value(false), vi.get_value(0), vi.get_value(0.0));
    println!("{} {} {}", vf.get_value(false), vf.get_value(0), vf.get_value(0.0));

    let ob = Some(Value::Boolean(true));
    let oi = Some(Value::Integer(23));
    let of = Some(Value::Float(3.4));

    println!("{} {} {}", load_var(&ob, false), load_var(&ob, 0), load_var(&ob, 0.0));
    println!("{} {} {}", load_var(&oi, false), load_var(&oi, 0), load_var(&oi, 0.0));
    println!("{} {} {}", load_var(&of, false), load_var(&of, 0), load_var(&of, 0.0));
}
