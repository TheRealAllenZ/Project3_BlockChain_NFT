
pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";



contract BookingToken is ERC721Full, Ownable {

    enum WorkflowStatus {NonRefundableFeeRequired, DepositRequired, RentRequired, Rented}
    
    using Counters for Counters.Counter;
    Counters.Counter _tokenIds;

    uint public _token_id;
    address public _propertyToken;
    address payable public _propertyOwner;
    address payable public _tenant;
    uint public _startDate;
    uint public _noOfWeeks;
    uint public  _rent;
    uint public  _deposit;
    uint public  _nonRefundable;
    WorkflowStatus public _status;
    
    
    constructor(string memory propertyURI, 
        address propertyToken, 
        address payable owner, 
        address payable tenant, 
        uint startDate, 
        uint noOfWeeks, 
        uint rent, 
        uint deposit, 
        uint nonRefundable) 
        ERC721Full("Booking Token", "BKT") public {
            _propertyToken = propertyToken;
            _propertyOwner = owner;
            _tenant = tenant;
            _startDate = startDate;
            _noOfWeeks = noOfWeeks;
            _rent = rent;
            _deposit = deposit;
            _nonRefundable = nonRefundable;
            _status = WorkflowStatus.DepositRequired;
        _setBaseURI(propertyURI);
    }
    
    /*function reserve(address propertyToken, 
        address payable owner, 
        address payable tenant, 
        uint startDate, uint noOfWeeks, uint rent, uint deposit, uint nonRefundable) public {
            _propertyToken = propertyToken;
            _propertyOwner = owner;
            _tenant = tenant;
            _startDate = startDate;
            _noOfWeeks = noOfWeeks;
            _rent = rent;
            _deposit = deposit;
            _nonRefundable = nonRefundable;
            _status = WorkflowStatus.DepositRequired;
        }
*/
    function deposit() public {
            _status = WorkflowStatus.RentRequired;
        }

   
    function _mintNft(string memory tokenURI) public returns (uint)
        {
            _status = WorkflowStatus.Rented;
            _token_id = _tokenIds.current();
            _tokenIds.increment();
            _mint(_tenant, _token_id );
            _setTokenURI(_token_id, tokenURI);
            
            return _token_id;
        
        }
    
    
     

}