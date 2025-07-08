// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { Base64 } from "strand~solady/utils/Base64.sol";
import { LibString } from "strand~solady/utils/LibString.sol";
import { SSTORE2 } from "strand~solady/utils/SSTORE2.sol";

import { Strand, bytecode, s } from "./Strand.sol";

contract StrandTest is Test {
  function testString() public view {
    Strand out = s("hello");
    assertEq(out.toString(), "hello");
  }

  function testConcat() public view {
    Strand out = (s("hello") + s("world"));
    assertEq(out.toString(), "helloworld");
  }

  function testTokenURI() public {
    address script = SSTORE2.write(bytes(Base64.encode('alert("hello world")')));

    Strand page = s('<script src="data:text/javascript;base64,') + bytecode(script, 1) + s('"></script>');
    Strand metadata = s('{"name":"Token","animation_url":"data:text/html,') + page.encodeURI() + s('"}');
    Strand uri = s("data:application/json,") + metadata.encodeURI();

    assertEq(
      uri.toString(),
      "data:application/json,%7B%22name%22%3A%22Token%22%2C%22animation_url%22%3A%22data%3Atext%2Fhtml%2C%253Cscript%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252CYWxlcnQoImhlbGxvIHdvcmxkIik=%2522%253E%253C%252Fscript%253E%22%7D"
    );
  }
}
