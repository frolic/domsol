// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { Base64 } from "domsol-solady/utils/Base64.sol";
import { LibString } from "domsol-solady/utils/LibString.sol";
import { SSTORE2 } from "domsol-solady/utils/SSTORE2.sol";

import { File } from "ethfs/src/File.sol";
import { FileStore } from "ethfs/src/FileStore.sol";
import { SAFE_SINGLETON_FACTORY, SAFE_SINGLETON_FACTORY_BYTECODE } from "ethfs/test/safeSingletonFactory.sol";

import { Stream, bytecode, s } from "../src/Stream.sol";
import { ethfs, fileStore } from "./ethfs.sol";

contract ethfsTest is Test {
  function setUp() public {
    vm.etch(SAFE_SINGLETON_FACTORY, SAFE_SINGLETON_FACTORY_BYTECODE);
    vm.etch(address(fileStore), address(new FileStore(SAFE_SINGLETON_FACTORY)).code);
    fileStore.createFile("three.min.js", Base64.encode(bytes(vm.readFile("test/data/three.min.js"))));
  }

  function testFile() public view {
    Stream page = s('<script src="data:text/javascript;base64,') + ethfs("three.min.js") + s('"></script>');
    Stream metadata = s('{"name":"Token","animation_url":"data:text/html,') + encodeURI(page) + s('"}');
    Stream uri = s("data:application/json,") + encodeURI(metadata);

    assertEq(bytes(toString(uri)).length, 810588);
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
