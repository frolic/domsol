// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

type Stream is uint256;

struct Chunk {
  bytes2 kind;
  bytes data;
}

function s(string memory str) pure returns (Stream stream) {
  Chunk[] memory chunks = new Chunk[](1);
  chunks[0] = Chunk("bs", bytes(str));
  return from(chunks);
}

function bytecode(address addr) pure returns (Stream stream) {
  return bytecode(addr, 0, 0);
}

function bytecode(address addr, uint256 start) pure returns (Stream stream) {
  return bytecode(addr, start, 0);
}

function bytecode(address addr, uint256 start, uint256 end) pure returns (Stream stream) {
  Chunk[] memory chunks = new Chunk[](1);
  chunks[0] = Chunk("bc", abi.encode(addr, start, end));
  return from(chunks);
}

function concat(Stream left, Stream right) pure returns (Stream stream) {
  Chunk[] memory a = asChunks(left);
  Chunk[] memory b = asChunks(right);

  uint256 lenA = a.length;
  uint256 lenB = b.length;
  uint256 total = lenA + lenB;

  Chunk[] memory chunks = new Chunk[](total);

  for (uint256 i = 0; i < lenA; i++) {
    chunks[i] = a[i];
  }
  for (uint256 i = 0; i < lenB; i++) {
    chunks[lenA + i] = b[i];
  }

  return from(chunks);
}

function map(Stream stream, function(bytes2, bytes memory) view returns (bytes2, bytes memory) callback)
  view
  returns (Stream)
{
  Chunk[] memory chunks = asChunks(stream);
  for (uint256 i = 0; i < chunks.length; i++) {
    (bytes2 kind, bytes memory data) = callback(chunks[i].kind, chunks[i].data);
    chunks[i].kind = kind;
    chunks[i].data = data;
  }
  return from(chunks);
}

using { concat as +, map } for Stream global;

function asChunks(Stream stream) pure returns (Chunk[] memory chunks) {
  assembly {
    chunks := stream
  }
}

function from(Chunk[] memory chunks) pure returns (Stream stream) {
  assembly {
    stream := chunks
  }
}
