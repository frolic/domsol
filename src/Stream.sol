// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

type Stream is uint256;

using { concat as +, map, toString } for Stream global;

function s(string memory contents) pure returns (Stream stream) {
  _Stream memory _stream;
  _stream.chunks = new _Chunk[](1);
  _stream.chunks[0] = _Chunk("by", bytes(contents).length, bytes(contents));
  _stream.length = _stream.chunks[0].length;
  return _wrap(_stream);
}

function bytecode(address location) pure returns (Stream stream) {
  return bytecode(location, 0, 0);
}

function bytecode(address location, uint256 start) pure returns (Stream stream) {
  return bytecode(location, start, 0);
}

function bytecode(address location, uint256 start, uint256 end) pure returns (Stream stream) {
  _Stream memory _stream;
  _stream.chunks = new _Chunk[](1);
  _stream.chunks[0] = _Chunk("bc", end > start ? end - start : 0, abi.encode(location, start, end));
  _stream.length = _stream.chunks[0].length;
  return _wrap(_stream);
}

function concat(Stream left, Stream right) pure returns (Stream stream) {
  _Stream memory a = _unwrap(left);
  _Stream memory b = _unwrap(right);

  _Chunk[] memory chunks = new _Chunk[](a.chunks.length + b.chunks.length);

  for (uint256 i = 0; i < a.chunks.length; i++) {
    chunks[i] = a.chunks[i];
  }
  for (uint256 i = 0; i < b.chunks.length; i++) {
    chunks[a.chunks.length + i] = b.chunks[i];
  }

  return _wrap(_Stream(a.length + b.length, chunks));
}

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

function toString(Stream stream, function(bytes2, uint256, bytes memory) view returns (string memory) transform)
  view
  returns (string memory out)
{
  _Stream memory _stream = _unwrap(stream);
  for (uint256 i = 0; i < _stream.chunks.length; i++) {
    out = string.concat(out, transform(_stream.chunks[i].kind, _stream.chunks[i].length, _stream.chunks[i].data));
  }
}

//--------------------//  INTERNAL  //--------------------//

struct _Stream {
  uint256 length;
  _Chunk[] chunks;
}

struct _Chunk {
  bytes2 kind;
  uint256 length;
  bytes data;
}

function _unwrap(Stream stream) pure returns (_Stream memory _stream) {
  assembly {
    _stream := stream
  }
}

function _wrap(_Stream memory _stream) pure returns (Stream stream) {
  assembly {
    stream := _stream
  }
}
