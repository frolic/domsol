// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./types.sol";

function map(Part[] memory parts, function(Part memory) view returns (Part memory) callback)
  view
  returns (Part[] memory)
{
  for (uint256 i = 0; i < parts.length; i++) {
    parts[i] = callback(parts[i]);
  }
  return parts;
}
