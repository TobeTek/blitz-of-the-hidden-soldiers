import { buildMimc7, buildMimcSponge } from "circomlibjs";
const ffjavascript = require("ffjavascript");
const stringifyBigInts = ffjavascript.utils.stringifyBigInts;

const F = new ffjavascript.ZqField(
  ffjavascript.Scalar.fromString(
    "21888242871839275222246405745257275088548364400416034343698204186575808495617"
  )
);

let _mimcHasher: any;
async function _getMimcHasher(): Promise<any> {
  if (_mimcHasher === undefined) {
    _mimcHasher = await buildMimcSponge();
  }
  return _mimcHasher;
}

export async function mimcHash(data: any) {
  let hasher = await _getMimcHasher();
  let h = hasher.hash(data);
  return "0x" + hasher.F.toString(h, 16);
}

export async function mimcHashMulti(data: any) {
  let hasher = await _getMimcHasher();
  let h = hasher.multiHash(data);
  return "0x" + hasher.F.toString(h, 16);
}
