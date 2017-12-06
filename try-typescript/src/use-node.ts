import * as util from "util";
import * as fs from "fs";

const readFile = util.promisify(fs.readFile);

async function readAll(path: string): Promise<string> {
  const data = await readFile(path);
  return `content size: ${data.length}\ncontent:\n${data.toString()}`;
}

readAll("./dest/use-node.js")
  .then(console.log)
  .catch(console.error);