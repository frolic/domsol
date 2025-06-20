// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { builder } from "./builder.sol";
import { Element, el, html, text } from "./dsl.sol";
import { toString } from "./toString.sol";

using builder for Element;

contract toStringTest is Test {
  function testTextNodeEscapesHtml() public pure {
    string memory out = toString(text("<b>hi</b>"));
    assertEq(out, "&lt;b&gt;hi&lt;/b&gt;");
  }

  function testElementWithAttributesAndChild() public pure {
    string memory out = toString(
      el("div").attr("class", "container").child(el("a").attr("href", "https://example.com").child(text("Click here")))
    );
    assertEq(out, '<div class="container"><a href="https://example.com">Click here</a></div>');
  }

  function testSelfClosingTag() public pure {
    string memory out = toString(el("img").attr("src", "cat.png").attr("alt", "cat"));
    assertEq(out, '<img src="cat.png" alt="cat" />');
  }

  function testNestedRawHtml() public pure {
    string memory out = toString(el("pre").child(html("<code>raw & unescaped</code>")));
    assertEq(out, "<pre><code>raw & unescaped</code></pre>");
  }
}
