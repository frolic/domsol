// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Attribute, Element, Part } from "./types.sol";

function push(Attribute[] memory arr, Attribute memory val) pure returns (Attribute[] memory) {
  Attribute[] memory out = new Attribute[](arr.length + 1);
  for (uint256 i = 0; i < arr.length; i++) {
    out[i] = arr[i];
  }
  out[arr.length] = val;
  return out;
}

function push(Element[] memory arr, Element memory val) pure returns (Element[] memory) {
  Element[] memory out = new Element[](arr.length + 1);
  for (uint256 i = 0; i < arr.length; i++) {
    out[i] = arr[i];
  }
  out[arr.length] = val;
  return out;
}

function push(Part[] memory arr, Part memory val) pure returns (Part[] memory) {
  Part[] memory out = new Part[](arr.length + 1);
  for (uint256 i = 0; i < arr.length; i++) {
    out[i] = arr[i];
  }
  out[arr.length] = val;
  return out;
}
