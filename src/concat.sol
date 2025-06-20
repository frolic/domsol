// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./types.sol";

function concat(Part[] memory a, Part[] memory b) pure returns (Part[] memory out) {
  uint256 lenA = a.length;
  uint256 lenB = b.length;
  out = new Part[](lenA + lenB);

  assembly {
    let outPtr := add(out, 0x20)
    let aPtr := add(a, 0x20)
    let bPtr := add(b, 0x20)

    for { let i := 0 } lt(i, lenA) { i := add(i, 1) } {
      mstore(add(outPtr, mul(i, 0x20)), mload(add(aPtr, mul(i, 0x20))))
    }
    for { let i := 0 } lt(i, lenB) { i := add(i, 1) } {
      mstore(add(outPtr, mul(add(i, lenA), 0x20)), mload(add(bPtr, mul(i, 0x20))))
    }
  }
}
