// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { toParts } from "./toParts.sol";
import { Element, Part, PartKind } from "./types.sol";
import { SSTORE2 } from "solady/utils/SSTORE2.sol";

function toString(Element memory elem) view returns (string memory) {
  return toString(toParts(elem));
}

function toString(Part[] memory parts) view returns (string memory) {
  string memory out = "";
  for (uint256 i = 0; i < parts.length; i++) {
    if (parts[i].kind == PartKind.Raw) {
      out = string.concat(out, string(parts[i].data));
    } else if (parts[i].kind == PartKind.Pointer) {
      (address pointer) = abi.decode(parts[i].data, (address));
      out = string.concat(out, string(SSTORE2.read(pointer)));
    }
  }
  return out;
}
