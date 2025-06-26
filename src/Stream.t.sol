// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { Base64 } from "solady/utils/Base64.sol";
import { LibString } from "solady/utils/LibString.sol";
import { SSTORE2 } from "solady/utils/SSTORE2.sol";

import { Chunk, Stream, asChunks, bytecode, from, s } from "./Stream.sol";

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

function _encodeURI(bytes2 kind, bytes memory data) pure returns (bytes2, bytes memory) {
  if (kind == "bs") {
    return (kind, bytes(LibString.encodeURIComponent(string(data))));
  }
  return (kind, data);
}

function toString(Chunk memory chunk) view returns (string memory out) {
  if (chunk.kind == "bs") {
    out = string.concat(out, string(chunk.data));
  } else if (chunk.kind == "bc") {
    (address pointer, uint256 start, uint256 end) = abi.decode(chunk.data, (address, uint256, uint256));
    // TODO: swap `SSTORE2.read` with a bytecode read+slice, where SSTORE2 is a slice of (1,0)
    out = string(SSTORE2.read(pointer));
  } else {
    revert(string.concat("Unhandled chunk: ", LibString.fromSmallString(chunk.kind)));
  }
}

function toString(Stream stream) view returns (string memory out) {
  Chunk[] memory chunks = asChunks(stream);
  for (uint256 i = 0; i < chunks.length; i++) {
    out = string.concat(out, toString(chunks[i]));
  }
}
