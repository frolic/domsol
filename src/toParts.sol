// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { concat } from "./concat.sol";
import { part } from "./dsl.sol";
import { push } from "./push.sol";
import { Element, Part } from "./types.sol";

function toParts(Element memory elem) pure returns (Part[] memory out) {
  Part[] memory parts = new Part[](0);

  if (bytes(elem.tag).length == 0) {
    for (uint256 i = 0; i < elem.attrs.length; i++) {
      parts = concat(parts, elem.attrs[i].value);
    }
    return parts;
  }

  parts = push(parts, part(string.concat("<", elem.tag)));

  for (uint256 i = 0; i < elem.attrs.length; i++) {
    if (bytes(elem.attrs[i].name).length > 0) {
      parts = push(parts, part(string.concat(" ", elem.attrs[i].name, '="')));
      parts = concat(parts, elem.attrs[i].value);
      parts = push(parts, part('"'));
    }
  }

  if (isTagSelfClosing(elem.tag)) {
    parts = push(parts, part(" />"));
    return parts;
  }

  parts = push(parts, part(">"));

  for (uint256 i = 0; i < elem.children.length; i++) {
    parts = concat(parts, toParts(elem.children[i]));
  }

  parts = push(parts, part(string.concat("</", elem.tag, ">")));

  return parts;
}

function isTagSelfClosing(string memory tag) pure returns (bool) {
  bytes32 hash = keccak256(bytes(tag));
  return hash == keccak256("area") || hash == keccak256("base") || hash == keccak256("br") || hash == keccak256("col")
    || hash == keccak256("embed") || hash == keccak256("hr") || hash == keccak256("img") || hash == keccak256("input")
    || hash == keccak256("link") || hash == keccak256("meta") || hash == keccak256("source") || hash == keccak256("track")
    || hash == keccak256("wbr");
}
