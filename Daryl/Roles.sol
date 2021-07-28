pragma solidity ^0.5.0;

import './Roles.sol';

contract RentalRoles {
  using Roles for Roles.Role;

  event OwnerContractAdded(address indexed account);
  event OwnerContractRemoved(address indexed account);
  event PropertyOwnerAdded(address indexed account);
  event RenterAdded(address indexed account);
  event PropertyOwnerRemoved(address indexed account);
  event RenterRemoved(address indexed account);
  
  Roles.Role private owner_contract;
  Roles.Role private owner_property;
  Roles.Role private renter;
  

  constructor(address payable _one, address payable _two) public {
    owner_contract.add(msg.sender);
    owner_property.add(_one);
    renter.add(_two);
    
  }

  modifier onlyContractOwner() {
    require(isOwnerContract(msg.sender));
    _;
  }

  function isOwnerContract(address account) public view returns (bool) {
    return owner_contract.has(account);
  }

  function addOwnerContract(address account) public onlyContractOwner {
    owner_contract.add(account);
    emit OwnerContractAdded(account);
  }
  
  function addPropertyOwner(address account) public payable onlyContractOwner {
      owner_property.add(account);
      emit PropertyOwnerAdded(account);
  }
  
  function addRenter(address account) public payable onlyContractOwner {
      renter.add(account);
      emit RenterAdded(account);
  }

  function renounceContractOwner() external onlyContractOwner {
    owner_contract.remove(msg.sender);
  }

  function removeContractOwner(address account) internal onlyContractOwner {
    owner_contract.remove(account);
    emit OwnerContractRemoved(account);
  }
  
  function removePropertyOwner(address account) external onlyContractOwner {
      owner_property.remove(account);
      emit PropertyOwnerRemoved(account);
  }
  
  function removeRenter(address account) external onlyContractOwner {
      renter.remove(account);
      emit RenterRemoved(account);
  }
}