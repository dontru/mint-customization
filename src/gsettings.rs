use std::env;
use std::fs;

const PATH: &str = "/usr/share/glib-2.0/schemas/mint-artwork.gschema.override";

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 5 {
        panic!("usage: ./gsettings set SCHEMA KEY VALUE");
    }

    let schema = format!("[{}]", args[2]);
    let key = format!("{}=", args[3]);
    let value = args[4].clone();

    let mut contents = fs::read_to_string(PATH).unwrap();
    if let Some(start) = contents.find(&schema) {
        let end = match contents[start..].find("\n\n[") {
            Some(idx) => start + idx,
            None => contents.len() - 1,
        };

        let mut substring = String::from(&contents[start..end]);
        if let Some(substart) = substring.find(&key) {
            let subend = match substring[substart..].find("\n") {
                Some(idx) => substart + idx,
                None => substring.len(),
            };

            substring.replace_range(substart..subend, &format!("{}{}", key, value));
        } else {
            substring += &format!("\n{}{}", key, value);
        }

        contents.replace_range(start..end, &substring);
    } else {
        contents += &format!("\n{}\n{}{}\n", schema, key, value);
    }

    fs::write(PATH, contents).unwrap();
}
