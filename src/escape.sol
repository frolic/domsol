// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

function escape(string memory input) pure returns (string memory) {
  bytes memory raw = bytes(input);
  string memory out = "";
  for (uint256 i = 0; i < raw.length; i++) {
    bytes1 c = raw[i];
    if (c == "&") {
      out = string.concat(out, "&amp;");
    } else if (c == "<") {
      out = string.concat(out, "&lt;");
    } else if (c == ">") {
      out = string.concat(out, "&gt;");
    } else if (c == '"') {
      out = string.concat(out, "&quot;");
    } else if (c == "'") {
      out = string.concat(out, "&apos;");
    } else {
      out = string.concat(out, string(abi.encodePacked(c)));
    }
  }
  return out;
}
