// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { toParts } from "./toParts.sol";
import { Element, Part, PartKind } from "./types.sol";

function toString(Element memory elem) pure returns (string memory) {
  Part[] memory parts = toParts(elem);
  string memory out = "";
  for (uint256 i = 0; i < parts.length; i++) {
    if (parts[i].kind == PartKind.Raw) {
      out = string.concat(out, string(parts[i].data));
    }
    // TODO: handle SSTORE2 pointer
  }
  return out;
}
