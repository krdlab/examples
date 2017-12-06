
export function add(l, r) {
  return l + r;
}

export class Person {
  constructor(id, name) {
    this._id = id;
    this._name = name;
  }
  get id() {
    return this._id;
  }
  get name() {
    return this._name;
  }
}