/* {{{ https://codeforces.com/blog/entry/67391
 * vim:fdm=marker
 */
#[allow(unused_imports)]
use std::cmp::{max, min};
use std::io::{stdin, stdout, BufWriter, Write};

#[derive(Default)]
struct Scanner {
    buffer: Vec<String>,
}
impl Scanner {
    fn next<T: std::str::FromStr>(&mut self) -> T {
        loop {
            if let Some(token) = self.buffer.pop() {
                return token.parse().ok().expect("oh no failed to parse");
            }
            let mut input = String::new();
            stdin().read_line(&mut input).expect("eep i failed to read");
            self.buffer = input.split_whitespace().rev().map(String::from).collect();
        }
    }
}

#[allow(dead_code)]
fn debug<T>(value: T)
where
    T: std::fmt::Debug, // T must implement the Debug trait
{
    #[cfg(feature = "debug")]
    dbg!(value);
}
/* }}} */

#[allow(dead_code)]
fn main() {
    let mut scan = Scanner::default();
    let out = &mut BufWriter::new(stdout());

    // write your program here, e.g.
    let _: i32 = scan.next();
    writeln!(out, "{}", "The answer is 42").ok();
}
