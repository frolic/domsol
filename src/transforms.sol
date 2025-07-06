// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { LibString } from "domsol-solady/utils/LibString.sol";
import { SSTORE2 } from "domsol-solady/utils/SSTORE2.sol";

import { Stream } from "./Stream.sol";
import { buildString, map } from "./utils.sol";

function encodeURI(Stream stream) view returns (Stream) {
  return map(stream, _encodeURI);
}

function toString(Stream stream) view returns (string memory) {
  return buildString(stream, _toString);
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
    // TODO: swap `SSTORE2.read` with a bytecode read+slice, where SSTORE2 is a slice of (1,0)
    return string(SSTORE2.read(pointer));
  }

  revert(string.concat("Unhandled chunk kind: ", LibString.fromSmallString(kind)));
}
