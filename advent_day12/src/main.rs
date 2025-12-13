use std::io::Read;

fn main() {
    let mut input = String::new();
    std::io::stdin().read_to_string(&mut input).unwrap();

    let res: i32 = input
        .split_terminator("\n\n")
        .last()
        .unwrap()
        .lines()
        .map(|region| {
            let (size, reqs) = region.split_once(':').unwrap();
            let (n, m) = size.split_once('x').unwrap();
            let avail = (n.parse::<i32>().unwrap() / 3) * (m.parse::<i32>().unwrap() / 3);
            let total_presents: i32 = reqs
                .split_whitespace()
                .map(|r| r.parse::<i32>().unwrap())
                .sum();

            (total_presents <= avail) as i32
        })
        .sum();
    println!("{}", res);
}
