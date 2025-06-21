// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./types.sol";

function concat(Part[] memory a, Part[] memory b) pure returns (Part[] memory out) {
  uint256 lenA = a.length;
  uint256 lenB = b.length;
  uint256 total = lenA + lenB;

  out = new Part[](total);

  for (uint256 i = 0; i < lenA; i++) {
    out[i] = a[i];
  }
  for (uint256 i = 0; i < lenB; i++) {
    out[lenA + i] = b[i];
  }
}
