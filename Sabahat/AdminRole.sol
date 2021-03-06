pragma solidity ^0.5.0;

//https://github.com/kohshiba/ERC-X/blob/master/contracts/ERCX/Contract/MinterRole.sol

import './Roles.sol';

contract Admin {
  using Roles for Roles.Role;

  event AdminAdded(address indexed account);
  event AdminRemoved(address indexed account);


  Roles.Role private admins;

  constructor() public {
    admins.add(msg.sender);
  }

  modifier onlyAdmin() {
    require(isAdmin(msg.sender));
    _;
  }

  function isAdmin(address account) public view returns (bool) {
    return admins.has(account);
  }

  function addAdmin(address account) public onlyAdmin {
    admins.add(account);
    emit AdminAdded(account);
  }

  function renounceAdmin() public {
    admins.remove(msg.sender);
  }

  function _removeAdmin(address account) internal {
    admins.remove(account);
    emit AdminRemoved(account);
  }
}