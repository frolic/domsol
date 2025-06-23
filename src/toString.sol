// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { toParts } from "./toParts.sol";
import { Element, Part } from "./types.sol";

import { LibString } from "solady/utils/LibString.sol";
import { SSTORE2 } from "solady/utils/SSTORE2.sol";

function toString(Element memory elem) view returns (string memory) {
  return toString(toParts(elem));
}

function toString(Part[] memory parts) view returns (string memory) {
  return toString(parts, partToString);
}

// TODO: optimize with DynamicBuffer
function toString(Part[] memory parts, function(Part memory) view returns (string memory) _toString)
  view
  returns (string memory)
{
  string memory out = "";
  for (uint256 i = 0; i < parts.length; i++) {
    out = string.concat(out, _toString(parts[i]));
  }
  return out;
}

function partToString(Part memory part) view returns (string memory out) {
  if (part.kind == "by") {
    return string(part.data);
  } else if (part.kind == "bc") {
    (address pointer) = abi.decode(part.data, (address));
    return string(SSTORE2.read(pointer));
  } else {
    revert(string.concat("Unhandled part kind: ", LibString.fromSmallString(part.kind)));
  }
}
