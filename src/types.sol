// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

struct Element {
  string tag;
  Attribute[] attrs;
  Element[] children;
}

struct Attribute {
  string name;
  Part[] value;
}

struct Part {
  bytes2 kind;
  bytes data;
}
