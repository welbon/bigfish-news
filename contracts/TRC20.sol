pragma solidity ^0.4.18;

import "./SafeMath.sol";

contract Mortal {
  address public owner;

  modifier onlyOwner() {require (msg.sender == owner); _;}
  function kill() onlyOwner public { selfdestruct(owner); }
}

contract TRC20 is Mortal {
  string public name;
  string public symbol;
  uint8 public decimals = 8;
  uint256 public totalSupply;

  /* This creates an array with all balances */
  mapping(address => uint256) public balanceOf;
  mapping(address => uint256) public freezeOf;
  mapping(address => mapping(address => uint256)) public allowance;

  event Transfer(address indexed from, address indexed to, uint256 tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
  event Burn(address indexed from, uint256 value);
  event Freeze(address indexed from, uint256 value);
  event Unfreeze(address indexed from, uint256 value);

  constructor(
    uint256 _initialBalance,
    string _tokenName,
    string _tokenSymbol,
    address _mainHolder,
    address _teamHolder,
    address _ecoHolder,
    address _operHolder) public {
    totalSupply = _initialBalance * 10 ** uint256(decimals);
    // Give the creator all initial tokens
    name = _tokenName;
    // Set the name for display purposes
    symbol = _tokenSymbol;
    // Set the symbol for display purposes
    owner = _mainHolder;

    // Update total supply
    balanceOf[_mainHolder] = totalSupply * 51 / 100;
    balanceOf[_teamHolder] = totalSupply * 10 / 100;
    balanceOf[_ecoHolder] = totalSupply * 29 / 100;
    balanceOf[_operHolder] = totalSupply * 10 / 100;
  }

  function totalSupply() public constant returns (uint256) {
    return totalSupply;
  }

  function balanceOf(address _tokenOwner) public constant returns (uint256 balance) {
    return balanceOf[_tokenOwner];
  }


  function allowance(address _tokenOwner, address _spender) public constant returns (uint256 remaining) {
    return allowance[_tokenOwner][_spender];
  }

  /* Allow another contract to spend some tokens in your behalf */
  function approve(address _spender, uint256 _value) public returns (bool success) {
    require(_value > 0);
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }


//  /* Send coins */
  function transfer(address _to, uint256 _value) public returns (bool success){
    require(_to != 0x0);
    // Prevent transfer to 0x0 address. Use burn() instead
    require(_value > 0);
    require(balanceOf[msg.sender] >= _value);
    // Check if the sender has enough
    require(balanceOf[_to] + _value >= balanceOf[_to]);
    // Check for overflows
    balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);
    // Subtract from the sender
    balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
    // Add the same to the recipient
    emit Transfer(msg.sender, _to, _value);
    // Notify anyone listening that this transfer took place
    return true;
  }

  /* A contract attempts to get the coins */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_to != 0x0);
    require(_value > 0);
    require(balanceOf[_from] >= _value);
    require(balanceOf[_to] + _value >= balanceOf[_to]);
    require(_value <= allowance[_from][msg.sender]);
    balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);
    balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
    allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function freeze(uint256 _value) public returns (bool success) {
    require(balanceOf[msg.sender] >= _value);
    require(_value > 0);
    balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);
    freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);
    emit Freeze(msg.sender, _value);
    return true;
  }

  function unfreeze(uint256 _value) public returns (bool success) {
    require(freezeOf[msg.sender] >= _value);
    require(_value > 0);
    freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);
    balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
    emit Unfreeze(msg.sender, _value);
    return true;
  }


  function getOwner() public view returns (address) {
    return owner;
  }
}
