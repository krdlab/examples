import * as js from "./lib/js";
import * as ts from "./lib/ts";

// function (js)
const res0 = js.add("1", "2"); // any
console.log(res0);

const res1 = js.add(1, 2); // any
console.log(res1);

// function (ts)
const res2 = ts.add(1, 2); // number
console.log(res2);

// class (js)
const p1 = new js.Person(1, "hoge"); // (id: any, name: any) -> js.Person
console.log(p1.name);

// class (ts)
const p2 = new ts.Person(1, "hoge");
console.log(p2.name);