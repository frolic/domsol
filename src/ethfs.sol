// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { File } from "ethfs/src/File.sol";
import { IFileStore } from "ethfs/src/IFileStore.sol";

import { Stream, _Chunk, _Stream, _wrap } from "../src/Stream.sol";

IFileStore constant fileStore = IFileStore(0xFe1411d6864592549AdE050215482e4385dFa0FB);

function ethfs(string memory filename) view returns (Stream stream) {
  File memory file = fileStore.getFile(filename);
  _Stream memory _stream;
  _stream.length = file.size;
  _stream.chunks = new _Chunk[](file.slices.length);
  for (uint256 i = 0; i < file.slices.length; i++) {
    _stream.chunks[i] = _Chunk(
      "bc",
      file.slices[i].end - file.slices[i].start,
      abi.encode(file.slices[i].pointer, file.slices[i].start, file.slices[i].end)
    );
  }
  return _wrap(_stream);
}
