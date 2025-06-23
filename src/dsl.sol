// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { LibString } from "solady/utils/LibString.sol";

import { builder } from "./builder.sol";
import { push } from "./push.sol";
import { Attribute, Element, Part } from "./types.sol";

using builder for Element;

function el(string memory tag) pure returns (Element memory) {
  Attribute[] memory attrs = new Attribute[](0);
  Element[] memory children = new Element[](0);
  return Element({ tag: tag, attrs: attrs, children: children });
}

function attr(string memory name, string memory value) pure returns (Attribute memory) {
  Part[] memory _parts = new Part[](1);
  _parts[0] = part(value);
  return Attribute({ name: name, value: _parts });
}

function attr(string memory name, Part[] memory value) pure returns (Attribute memory) {
  return Attribute({ name: name, value: value });
}

function text(string memory value) pure returns (Element memory) {
  return el("").attr("", LibString.escapeHTML(value));
}

function html(string memory value) pure returns (Element memory) {
  return el("").attr("", value);
}

function part(string memory data) pure returns (Part memory) {
  return Part({ kind: "by", data: bytes(data) });
}

function pointer(address data) pure returns (Part memory) {
  return Part({ kind: "bc", data: abi.encode(data) });
}

function parts(Part memory p0) pure returns (Part[] memory _parts) {
  _parts = new Part[](1);
  _parts[0] = p0;
}

function parts(Part memory p0, Part memory p1) pure returns (Part[] memory _parts) {
  _parts = new Part[](2);
  _parts[0] = p0;
  _parts[1] = p1;
}

function parts(Part memory p0, Part memory p1, Part memory p2) pure returns (Part[] memory _parts) {
  _parts = new Part[](3);
  _parts[0] = p0;
  _parts[1] = p1;
  _parts[2] = p2;
}

function parts(Part memory p0, Part memory p1, Part memory p2, Part memory p3) pure returns (Part[] memory _parts) {
  _parts = new Part[](4);
  _parts[0] = p0;
  _parts[1] = p1;
  _parts[2] = p2;
  _parts[3] = p3;
}
