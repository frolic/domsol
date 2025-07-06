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
    Stream metadata = s('{"name":"Token","animation_url":"data:text/html,') + page.encodeURI() + s('"}');
    Stream uri = s("data:application/json,") + metadata.encodeURI();

    assertEq(bytes(uri.toString()).length, 810588);
  }
}
