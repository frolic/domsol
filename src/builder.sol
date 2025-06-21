// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { attr as _attr } from "./dsl.sol";
import { push } from "./push.sol";
import { Attribute, Element, Part } from "./types.sol";

library builder {
  function attr(Element memory elem, string memory name, string memory value) internal pure returns (Element memory) {
    elem.attrs = push(elem.attrs, _attr(name, value));
    return elem;
  }

  function attr(Element memory elem, string memory name, Part[] memory value) internal pure returns (Element memory) {
    elem.attrs = push(elem.attrs, _attr(name, value));
    return elem;
  }

  function attr(Element memory elem, Attribute memory a) internal pure returns (Element memory) {
    elem.attrs = push(elem.attrs, a);
    return elem;
  }

  function child(Element memory elem, Element memory c) internal pure returns (Element memory) {
    elem.children = push(elem.children, c);
    return elem;
  }
}
