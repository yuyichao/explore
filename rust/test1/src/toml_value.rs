//

use toml::{Table, value::Value};

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
            Value::Integer(v) => (*v) as f64,
            Value::Float(v) => *v,
            _ => def,
        }
    }
}

impl GetValue<Vec<f64>> for Value {
    fn get_value(&self, def: Vec<f64>) -> Vec<f64> {
        match self {
            Value::Integer(v) => vec![*v as f64],
            Value::Float(v) => vec![*v],
            Value::Array(ary) => {
                let mut res: Vec<f64> = Vec::new();
                for v in ary {
                    match v {
                        Value::Integer(v) => res.push(*v as f64),
                        Value::Float(v) => res.push(*v),
                        _ => {
                            panic!();
                        }
                    }
                }
                return res;
            },
            _ => def,
        }
    }
}

fn load_var<T>(block: &Value, name: &str, def: T) -> T
where
    Value: GetValue<T>
{
    let value = match block.get(name) {
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

    let config = (r#"
[global]
b = true
i = 23
f = 3.4
a = [1, 2, 3.4, 5.9]
"#).parse::<Table>().unwrap();

    let global_config = config.get("global").unwrap();

    println!("{} {} {}",
             load_var(&global_config, "b", false),
             load_var(&global_config, "b", 0),
             load_var(&global_config, "b", 0.0));

    println!("{} {} {}",
             load_var(&global_config, "i", false),
             load_var(&global_config, "i", 0),
             load_var(&global_config, "i", 0.0));

    println!("{} {} {}",
             load_var(&global_config, "f", false),
             load_var(&global_config, "f", 0),
             load_var(&global_config, "f", 0.0));

    println!("{:?} {:?}",
             load_var(&global_config, "a", vec![0.0]),
             load_var(&global_config, "missing", vec![0.0]));
}
