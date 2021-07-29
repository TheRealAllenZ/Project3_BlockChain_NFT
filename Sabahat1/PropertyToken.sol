pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; 


contract PropertyToken is ERC165, ERC721Full, Ownable  {

    using SafeMath for uint;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    
    // one to one mapping of token to listing
    uint tokenId;
    
    //PropertyListing public tokenListings;
    
    // Status of the listing, Available/UnAvailable - ?? Need more status?
    enum  Status { Available, UnAvailable, Removed } 
    
    //ListStatus public status ;
    address payable public propertyOwner;
    string public ifpsAddress;
    uint public rentFee;
    uint public nonRefundableFee;
    uint public depositFee;
    Status public propertyStatus;
    uint public listingFee;
    uint public startAvailability;
    uint public endAvailability;

    uint[] weeksAvailable;
    
    event ListingAdded(address indexed owner, string listingURI);
    
    
    constructor(string memory name, string memory symbol) ERC721Full(name, symbol)  public {
    }
    
    function decimals() public pure returns(uint) {
        return 0;
    }
    

    function mintNft(address payable receiver, 
                    string calldata tokenURI,
                    string calldata ipfsAddress,
                    uint rent,
                    uint startDate, 
                    uint endDate, 
                    uint fee)  external onlyOwner returns (uint) {
        
        
        
        _tokenIds.increment();
        tokenId = _tokenIds.current();
        
        _mint(receiver, tokenId);
        
        _setTokenURI(tokenId, tokenURI);

        //PropertyListing listing = new PropertyListing();
        
        _add(receiver, ipfsAddress, rent, fee, startDate, endDate);

        return tokenId;
    }

  function _add(address payable owner, string memory listingIFPS, uint rent, uint fee, uint startDate, uint endDate) private onlyOwner()
    {
        // Calculate the reservation fee and the depoist fee
        nonRefundableFee = rent.mul(2).div(7) ; // reservationFee is 2/7th of the rent for the week
        depositFee = rent; // Deposit is 7/7 of the rent, i.e. same as the rent
        rentFee = rent;
        ifpsAddress = listingIFPS;
        propertyOwner = owner;
        listingFee = fee;
        startAvailability =startDate;
        endAvailability = endDate;
        propertyStatus = Status.Available;
        generateWeeks();
        
        emit ListingAdded(owner, listingIFPS);

    }
    
    
    function getDetails()  public view returns 
     (address payable,
        uint  ,
        uint  ,
        uint  ,
        PropertyToken.Status ,
        uint  ,
        uint  )

    
    {

         return (propertyOwner, rentFee,
                nonRefundableFee,
                depositFee,
                propertyStatus,
                startAvailability,
                endAvailability);

    }
   
    function generateWeeks() private 
    {
        uint sDate = startAvailability;
        uint endDate = endAvailability.sub(7 days);
        while (sDate <= endDate)
        {
            weeksAvailable.push(sDate);
            sDate = sDate.add(7 days);
        }
        
        
    }
    function burn() public {
        require(msg.sender == propertyOwner);
        _burn(tokenId);
    }
}