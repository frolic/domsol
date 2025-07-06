// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Stream, _Stream, _unwrap, _wrap } from "./Stream.sol";

function map(
  Stream stream,
  function(bytes2, uint256, bytes memory) view returns (bytes2, uint256, bytes memory) transform
) view returns (Stream) {
  _Stream memory _stream = _unwrap(stream);
  for (uint256 i = 0; i < _stream.chunks.length; i++) {
    (bytes2 kind, uint256 length, bytes memory data) =
      transform(_stream.chunks[i].kind, _stream.chunks[i].length, _stream.chunks[i].data);
    _stream.chunks[i].kind = kind;
    _stream.chunks[i].length = length;
    _stream.chunks[i].data = data;
  }
  return _wrap(_stream);
}

function buildString(Stream stream, function(bytes2, uint256, bytes memory) view returns (string memory) transform)
  view
  returns (string memory out)
{
  _Stream memory _stream = _unwrap(stream);
  for (uint256 i = 0; i < _stream.chunks.length; i++) {
    out = string.concat(out, transform(_stream.chunks[i].kind, _stream.chunks[i].length, _stream.chunks[i].data));
  }
}
