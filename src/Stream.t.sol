// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { Base64 } from "solady/utils/Base64.sol";
import { LibString } from "solady/utils/LibString.sol";
import { SSTORE2 } from "solady/utils/SSTORE2.sol";

import { Stream, _Chunk, bytecode, s } from "./Stream.sol";

contract StreamTest is Test {
  function testString() public view {
    Stream out = s("hello");
    assertEq(toString(out), "hello");
  }

  function testConcat() public view {
    Stream out = (s("hello") + s("world"));
    assertEq(toString(out), "helloworld");
  }

  function testTokenURI() public {
    address script = SSTORE2.write(bytes(Base64.encode('alert("hello world")')));

    Stream page = s('<script src="data:text/javascript;base64,') + bytecode(script) + s('"></script>');
    Stream metadata = s('{"name":"Token","animation_url":"data:text/html,') + encodeURI(page) + s('"}');
    Stream uri = s("data:application/json,") + encodeURI(metadata);

    assertEq(
      toString(uri),
      "data:application/json,%7B%22name%22%3A%22Token%22%2C%22animation_url%22%3A%22data%3Atext%2Fhtml%2C%253Cscript%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252CYWxlcnQoImhlbGxvIHdvcmxkIik=%2522%253E%253C%252Fscript%253E%22%7D"
    );
  }
}

function encodeURI(Stream stream) view returns (Stream) {
  return stream.map(_encodeURI);
}

function _encodeURI(bytes2 kind, uint256 length, bytes memory data) pure returns (bytes2, uint256, bytes memory) {
  if (kind == "by") {
    bytes memory encoded = bytes(LibString.encodeURIComponent(string(data)));
    return (kind, encoded.length, encoded);
  }
  return (kind, length, data);
}

function toString(Stream stream) view returns (string memory) {
  return stream.toString(_toString);
}

function _toString(bytes2 kind, uint256 length, bytes memory data) view returns (string memory out) {
  if (kind == "by") {
    return string(data);
  }
  if (kind == "bc") {
    (address pointer, uint256 start, uint256 end) = abi.decode(data, (address, uint256, uint256));
    // TODO: swap `SSTORE2.read` with a bytecode read+slice, where SSTORE2 is a slice of (1,0)
    return string(SSTORE2.read(pointer));
  }

  revert(string.concat("Unhandled chunk kind: ", LibString.fromSmallString(kind)));
}
