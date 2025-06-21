// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import { LibString } from "solady/utils/LibString.sol";
import { SSTORE2 } from "solady/utils/SSTORE2.sol";

import { builder } from "./builder.sol";
import { Element, Part, PartKind, el, html, part, parts, pointer, text } from "./dsl.sol";
import { toParts } from "./toParts.sol";
import { toString } from "./toString.sol";

using builder for Element;

contract toStringTest is Test {
  function testTextNodeEscapesHtml() public view {
    string memory out = toString(text("<b>hi</b>"));
    assertEq(out, "&lt;b&gt;hi&lt;/b&gt;");
  }

  function testElementWithAttributesAndChild() public view {
    string memory out = toString(
      el("div").attr("class", "container").child(el("a").attr("href", "https://example.com").child(text("Click here")))
    );
    assertEq(out, '<div class="container"><a href="https://example.com">Click here</a></div>');
  }

  function testSelfClosingTag() public view {
    string memory out = toString(el("img").attr("src", "cat.png").attr("alt", "cat"));
    assertEq(out, '<img src="cat.png" alt="cat" />');
  }

  function testNestedRawHtml() public view {
    string memory out = toString(el("pre").child(html("<code>raw & unescaped</code>")));
    assertEq(out, "<pre><code>raw & unescaped</code></pre>");
  }

  function testPointerToElementRendersCorrectly() public {
    address source = SSTORE2.write(bytes(LibString.encodeURIComponent('alert("hello world")')));

    Part[] memory out = toParts(el("script").attr("src", parts(part("data:text/javascript,"), pointer(source))));
    assertEq(toString(out), '<script src="data:text/javascript,alert(%22hello%20world%22)"></script>');
  }
}
