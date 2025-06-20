// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { builder } from "./builder.sol";
import { escape } from "./escape.sol";
import { push } from "./push.sol";
import { Attribute, Element, Part, PartKind } from "./types.sol";

using builder for Element;

function el(string memory tag) pure returns (Element memory) {
  Attribute[] memory attrs = new Attribute[](0);
  Element[] memory children = new Element[](0);
  return Element({ tag: tag, attrs: attrs, children: children });
}

function attr(string memory name, string memory value) pure returns (Attribute memory) {
  Part[] memory parts = new Part[](1);
  parts[0] = part(value);
  return Attribute({ name: name, value: parts });
}

function text(string memory value) pure returns (Element memory) {
  return el("").attr("", escape(value));
}

function html(string memory value) pure returns (Element memory) {
  return el("").attr("", value);
}

function part(string memory data) pure returns (Part memory) {
  return Part({ kind: PartKind.Raw, data: bytes(data) });
}

function pointer(address data) pure returns (Part memory) {
  return Part({ kind: PartKind.Raw, data: abi.encode(data) });
}
