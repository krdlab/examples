var cats = require('./cats');
import Person from './person';

console.log(cats);

class Friend extends Person {
  constructor(name) {
    super(name);
  }
  callName() {
    console.log(this.name);
  }
}

new Friend('krdlab').callName();
