// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Strand, _Strand, _unwrap, _wrap } from "./Strand.sol";
import { DynamicBufferLib } from "strand~solady/utils/DynamicBufferLib.sol";

using DynamicBufferLib for DynamicBufferLib.DynamicBuffer;

function map(
  Strand strand,
  function(bytes2, uint256, bytes memory) view returns (bytes2, uint256, bytes memory) transform
) view returns (Strand) {
  _Strand memory _strand = _unwrap(strand);
  for (uint256 i = 0; i < _strand.parts.length; i++) {
    (bytes2 kind, uint256 length, bytes memory data) =
      transform(_strand.parts[i].kind, _strand.parts[i].length, _strand.parts[i].data);
    _strand.parts[i].kind = kind;
    _strand.parts[i].length = length;
    _strand.parts[i].data = data;
  }
  return _wrap(_strand);
}

function buildString(Strand strand, function(bytes2, uint256, bytes memory) view returns (string memory) transform)
  view
  returns (string memory)
{
  DynamicBufferLib.DynamicBuffer memory buffer;
  _Strand memory _strand = _unwrap(strand);
  buffer.reserve(_strand.length);
  for (uint256 i = 0; i < _strand.parts.length; i++) {
    buffer.p(bytes(transform(_strand.parts[i].kind, _strand.parts[i].length, _strand.parts[i].data)));
  }
  return buffer.s();
}
