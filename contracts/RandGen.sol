pragma solidity ^0.4.18;

contract RandGen {
  function randomIndex(uint64 count) public constant returns (uint64) {
    return uint64(uint256(keccak256(block.timestamp, block.difficulty)) % count + 1);
  }
}