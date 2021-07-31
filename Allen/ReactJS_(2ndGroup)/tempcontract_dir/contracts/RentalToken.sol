
pragma solidity ^0.5.0;

import "@openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin-contracts/contracts/access/Ownable.sol";
import "@openzeppelin-contracts/contracts/utils/math/SafeMath.sol"; 



contract BookingToken is ERC721Full, Ownable {

    using SafeMath for uint;
    using Counters for Counters.Counter;
        
    enum WorkflowStatus {NonRefundableFeeRequired, DepositRequired, RentRequired, Rented}
    
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
    
    
    constructor(uint tokenId, string memory propertyURI, 
        address propertyToken, 
        address payable owner, 
        address payable tenant, 
        uint startDate, 
        uint noOfWeeks, 
        uint rent, 
        uint deposit, 
        uint nonRefundable) 
        ERC721Full("Booking Token", "BKT") public {
            _token_id = tokenId;
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
    
    function getDetails(uint index) public view returns (address , 
        address , 
        address , 
        uint , 
        uint , 
        uint , 
        uint , 
        uint , WorkflowStatus)  {
            return (_propertyToken, 
            _propertyOwner,
            _tenant,
            _startDate,
            _noOfWeeks,
            _rent,
            _deposit,
            _nonRefundable,
            _status);
        }

    function deposit() public {
            _status = WorkflowStatus.RentRequired;
        }

    function _mintNft(string memory tokenURI, uint tokenId) public returns (uint)
        {
            require(!_exists(tokenId), "Token Already Exists");
            _status = WorkflowStatus.Rented;
            _mint(_tenant, tokenId );
            _setTokenURI(tokenId, tokenURI);
            _token_id = tokenId;
            return _token_id;
        
        }
    
    function burn() public {
        require(msg.sender == _propertyOwner);
        _burn(_token_id);
    }
    
     

}