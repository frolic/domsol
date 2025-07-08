// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { LibString } from "strand~solady/utils/LibString.sol";

import { Strand } from "./Strand.sol";
import { buildString, map } from "./utils.sol";

function encodeURI(Strand strand) view returns (Strand) {
  return map(strand, _encodeURI);
}

function toString(Strand strand) view returns (string memory) {
  return buildString(strand, _toString);
}

//--------------------//  INTERNAL  //--------------------//

function _encodeURI(bytes2 kind, uint256 length, bytes memory data) pure returns (bytes2, uint256, bytes memory) {
  if (kind == "by") {
    bytes memory encoded = bytes(LibString.encodeURIComponent(string(data)));
    return (kind, encoded.length, encoded);
  }
  return (kind, length, data);
}

function _toString(bytes2 kind, uint256 length, bytes memory data) view returns (string memory out) {
  if (kind == "by") {
    return string(data);
  }
  if (kind == "bc") {
    (address pointer, uint256 start, uint256 end) = abi.decode(data, (address, uint256, uint256));
    return string(_codeSlice(pointer, start, end));
  }

  revert(string.concat("Unhandled chunk kind: ", LibString.fromSmallString(kind)));
}

function _codeSlice(address pointer, uint256 start, uint256 end) view returns (bytes memory out) {
  assembly {
    let size := extcodesize(pointer)
    if iszero(end) { end := size }

    if gt(end, size) { revert(0, 0) } // optional: bounds check

    let length := sub(end, start)
    out := mload(0x40)
    mstore(out, length)
    extcodecopy(pointer, add(out, 32), start, length)
    mstore(0x40, add(add(out, 32), length))
  }
}
