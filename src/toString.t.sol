// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { Base64 } from "solady/utils/Base64.sol";
import { LibString } from "solady/utils/LibString.sol";
import { SSTORE2 } from "solady/utils/SSTORE2.sol";

import { builder } from "./builder.sol";
import { concat } from "./concat.sol";
import { Element, Part, el, html, part, parts, pointer, text } from "./dsl.sol";
import { map } from "./map.sol";
import { push } from "./push.sol";
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

  function testPointer() public {
    address source = SSTORE2.write(bytes(LibString.encodeURIComponent('alert("hello world")')));

    Part[] memory out = toParts(el("script").attr("src", parts(part("data:text/javascript,"), pointer(source))));
    assertEq(toString(out), '<script src="data:text/javascript,alert(%22hello%20world%22)"></script>');
  }

  function testTokenURI() public {
    address source = SSTORE2.write(bytes(Base64.encode('alert("hello world")')));
    Part[] memory _html =
      toParts(el("script").attr("src", parts(part("data:text/javascript;base64,"), pointer(source))));
    Part[] memory tokenURI = concat(
      parts(part("data:application/json,")),
      map(
        push(
          concat(
            parts(part('{"name":"Example Token","animation_url":"data:text/html,')), map(_html, encodeURIComponent)
          ),
          part('"}')
        ),
        encodeURIComponent
      )
    );

    assertEq(
      toString(tokenURI),
      "data:application/json,%7B%22name%22%3A%22Example%20Token%22%2C%22animation_url%22%3A%22data%3Atext%2Fhtml%2C%253Cscript%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252CYWxlcnQoImhlbGxvIHdvcmxkIik=%2522%253E%253C%252Fscript%253E%22%7D"
    );
  }
}

function encodeURIComponent(Part memory _part) view returns (Part memory) {
  if (_part.kind == "by") {
    _part.data = bytes(LibString.encodeURIComponent(string(_part.data)));
  }
  return _part;
}

function escapeJSON(Part memory _part) view returns (Part memory) {
  if (_part.kind == "by") {
    _part.data = bytes(LibString.escapeJSON(string(_part.data)));
  }
  return _part;
}
