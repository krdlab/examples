// https://github.com/Geal/nom/blob/main/examples/json.rs

use nom::{
    branch::alt,
    bytes::complete::{escaped, tag, take_while},
    character::complete::{alphanumeric1, char, one_of},
    combinator::{cut, map, opt, value},
    error::context,
    multi::separated_list0,
    number::complete::double,
    sequence::{delimited, preceded, separated_pair, terminated},
    IResult,
};
use std::collections::HashMap;

#[derive(Debug, PartialEq)]
pub enum JsonValue {
    Null,
    Str(String),
    Boolean(bool),
    Num(f64),
    Array(Vec<JsonValue>),
    Object(HashMap<String, JsonValue>),
}

fn sp(i: &str) -> IResult<&str, &str> {
    let chars = " \t\r\n";
    take_while(|c| chars.contains(c))(i)
}

fn parse_str(i: &str) -> IResult<&str, &str> {
    escaped(alphanumeric1, '\\', one_of("\"n\\"))(i)
}

fn boolean(input: &str) -> IResult<&str, bool> {
    let parse_true = value(true, tag("true"));
    let parse_false = value(false, tag("false"));
    alt((parse_true, parse_false))(input)
}

fn null(i: &str) -> IResult<&str, ()> {
    value((), tag("null"))(i)
}

fn string(i: &str) -> IResult<&str, &str> {
    context(
        "string",
        preceded(char('\"'), cut(terminated(parse_str, char('\"')))),
    )(i)
}

fn array(i: &str) -> IResult<&str, Vec<JsonValue>> {
    context(
        "array",
        preceded(
            char('['),
            cut(terminated(
                separated_list0(preceded(sp, char(',')), json_value),
                preceded(sp, char(']')),
            )),
        ),
    )(i)
}

fn key_value(i: &str) -> IResult<&str, (&str, JsonValue)> {
    separated_pair(
        preceded(sp, string),
        cut(preceded(sp, char(':'))),
        json_value,
    )(i)
}

fn hash(i: &str) -> IResult<&str, HashMap<String, JsonValue>> {
    context(
        "map",
        preceded(
            char('{'),
            cut(terminated(
                map(
                    separated_list0(preceded(sp, char(',')), key_value),
                    |tuple_vec| {
                        tuple_vec
                            .into_iter()
                            .map(|(k, v)| (String::from(k), v))
                            .collect()
                    },
                ),
                preceded(sp, char('}')),
            )),
        ),
    )(i)
}

fn json_value(i: &str) -> IResult<&str, JsonValue> {
    preceded(
        sp,
        alt((
            map(hash, JsonValue::Object),
            map(array, JsonValue::Array),
            map(string, |s| JsonValue::Str(String::from(s))),
            map(double, JsonValue::Num),
            map(boolean, JsonValue::Boolean),
            map(null, |_| JsonValue::Null),
        )),
    )(i)
}

pub fn root(i: &str) -> IResult<&str, JsonValue> {
    delimited(
        sp,
        alt((
            map(hash, JsonValue::Object),
            map(array, JsonValue::Array),
            map(null, |_| JsonValue::Null),
        )),
        opt(sp),
    )(i)
}
