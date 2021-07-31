pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; 

import "./PropertyListing.sol";
import "./PropertyToken.sol";
import "./RentalToken.sol";

contract PropertyManager {

    using SafeMath for uint;
  
   // uint constant  SERVICE_FEE = 100;
    
    // array of all tokens
    address[] public propertyTokens;
    
    // owner to index of the token in in the tokens array 
    mapping(address => uint8[]) public ownerTokens;

    //array of rentalTokens
    address[] public rentalTokens;
    
    // tenants to index of token in token array
    mapping(address => uint[]) public tenantTokens;


   /*
    // signifies the startdate and #of weeks
    struct ReservedWeek {
        uint startDate;
        uint endDate;
        uint noOfWeeks;
        bool reserved;
    }
    mapping(address => ReservedWeek[]) reservedWeeks;
    */
    // array of bookings
    BookingToken[] bookings;
    
    //mapping of property to index in array
    mapping(address => uint8[]) public propertyBookings;
    
    modifier MinFee()
    {
        require(msg.value == 100, "Please send in the exact service fee of 100 wei" );
        _;
    }
    
    modifier onlyAdmin()
    {
        require(true, "You are not authorized." );
        _;
    }
    
    function addListing(address payable owner, 
                    string calldata tokenURI,
                    string calldata ipfsAddress,
                    uint rent,
                    uint startDate, 
                    uint endDate) external payable MinFee() onlyAdmin()  {
                        
        PropertyToken token = new PropertyToken("PROPERTY", "Prop");
        token.mintNft(owner, tokenURI, ipfsAddress, rent, startDate, endDate, msg.value);
        address token_address = address(token);
        propertyTokens.push(token_address);
        ownerTokens[owner].push(uint8(propertyTokens.length.sub(1)));
    
                        
    }
   
     // NEED TO ADD MORE CHECKS
    /*function _isAvailable(address propertyAddress, uint startDate ) private view returns (bool)
    {
        bool isAvialable = true;
        for (uint j = 0; j < reservedWeeks[propertyAddress].length; j++ )
        {
            if (startDate >= reservedWeeks[propertyAddress][j].startDate &&  startDate < reservedWeeks[propertyAddress][j].endDate)
            
               isAvialable =  isAvialable && false;
        }       
        return isAvialable;
    }
    */
    
    function reserve(address propertyAddress, uint startDate, uint noOfWeeks, address payable tenant) 
            public payable returns (uint)
    {
        
        require(noOfWeeks > 0, "Book for alteast one week");
        PropertyToken pToken = PropertyToken(propertyAddress);
        uint tempEndDate = startDate +  (noOfWeeks.mul(7).mul(24).mul(60).mul(60));

        require(msg.value == pToken.nonRefundableFee(), "Invalid Non Refundable fee");
        require(startDate >= pToken.startAvailability() &&  tempEndDate <= pToken.endAvailability(), "Property Not Avialable");
      //  require(_isAvailable(propertyAddress, startDate /*, tempEndDate*/ ), "Already reserved!");

        BookingToken bToken = new BookingToken(pToken.ifpsAddress(),
                address(pToken),
                pToken.propertyOwner(),
                tenant, 
                startDate, 
                noOfWeeks, 
                pToken.rentFee(), 
                pToken.depositFee(), 
                pToken.nonRefundableFee());
        //bToken._propertyToken;
        
        
        bookings.push(bToken);
        
        propertyBookings[propertyAddress].push(uint8(bookings.length -1));    
        //reservedWeeks[propertyAddress].push(ReservedWeek(startDate, tempEndDate, noOfWeeks, true));
       
        return bookings.length -1;
    }
    
    function deposit(uint bookingId) public payable 
    {
        require (msg.value == bookings[bookingId]._deposit(), "Invalid deposit Fee");
        bookings[bookingId].deposit();
    }
    
    function rent(uint bookingId, string memory tokenURI) public payable 
    {
        require (msg.value != bookings[bookingId]._rent(), "Invalid rent Fee");
        bookings[bookingId]._mintNft(tokenURI);
        rentalTokens.push(address(bookings[bookingId]));
        tenantTokens[bookings[bookingId]._tenant()].push(uint8(rentalTokens.length.sub(1)));
     
    }


 // Fallback function
    function() external { } 
        
   
}
