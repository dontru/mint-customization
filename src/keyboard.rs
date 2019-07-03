use std::env;
use std::fs;

const PATH: &str = "/etc/default/keyboard";

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        panic!("Not enough arguments");
    }

    let layout = &args[1];
    let contents = fs::read_to_string(PATH).unwrap();

    let result: String = contents.lines()
        .map(|line| {
            let mut line = String::from(line);

            if line.contains("XKBLAYOUT") {
                line = String::from("XKBLAYOUT=\"");
                line.push_str(layout);
                line.push('"');
            }

            line.push('\n');
            line
        }).collect();

    fs::write(PATH, result).unwrap();
}
