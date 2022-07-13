// https://github.com/Geal/nom#example

use nom::{
    bytes::complete::{tag, take_while_m_n},
    combinator::map_res,
    sequence::tuple,
    IResult,
};
use try_rust_nom::json::root;

#[derive(Debug, PartialEq)]
pub struct Color {
    pub red: u8,
    pub green: u8,
    pub blue: u8,
}

fn from_hex(input: &str) -> Result<u8, std::num::ParseIntError> {
    u8::from_str_radix(input, 16)
}

fn is_hex_digit(c: char) -> bool {
    c.is_digit(16)
}

fn hex_primary(input: &str) -> IResult<&str, u8> {
    map_res(take_while_m_n(2, 2, is_hex_digit), from_hex)(input)
}

fn hex_color(input: &str) -> IResult<&str, Color> {
    let (input, _) = tag("#")(input)?;
    let (input, (red, green, blue)) = tuple((hex_primary, hex_primary, hex_primary))(input)?;
    Ok((input, Color { red, green, blue }))
}

fn main() {
    println!("{:?}", hex_color("#ffffff"));

    let data = r#"  { "a" : 42,
        "b": ["x", "y", 12] ,
        "c": { "hello" : "world"
        }
        } "#;
    println!("{:?}", root(data));
}

#[test]
fn parse_color() {
    let result = hex_color("#2f14df");
    assert_eq!(
        result,
        Ok((
            "",
            Color {
                red: 47,
                green: 20,
                blue: 223,
            }
        ))
    );
}
