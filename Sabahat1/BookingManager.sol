pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; 

//import "./PropertyListing.sol";
import "./PropertyToken.sol";
import "./RentalToken.sol";
import "./PropertyManager.sol";

contract BookingManager is Ownable {
    
    using SafeMath for uint;
 
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
   
    // signifies the startdate and #of weeks
    struct ReservedWeek {
        uint startDate;
        uint endDate;
        bool reserved;
    }
    mapping(address => ReservedWeek[]) reservedWeeks;

    
    // array of bookings (until it converts to token)
    BookingToken[] bookings;

    // array of index in  Bookings
    uint[] public rentalTokens;
    
    //mapping of property to index in array
    mapping(address => uint[]) public propertyBookings;


    // tenant => index in BookingToken
    mapping(address => uint[]) public tenantTokens;

    //bookingid to depoist
    mapping(uint => uint) deposits;
    
    // rentalID to rent
    mapping(uint => uint) rents;
  
    // map of tokenid to index
    mapping(uint => uint ) tokenIndex;
    
    uint _fakenow = now;
    
    function reserve(address propertyAddress, uint startDate, uint noOfWeeks, address payable tenant) 
    public payable returns (uint)
    {
        // booking for more than a week
        require(noOfWeeks > 0, "Book for alteast one week");
        // calculate the end date
        uint tempEndDate = startDate +  (noOfWeeks.mul(7).mul(24).mul(60).mul(60));
        
        PropertyToken pToken = PropertyToken(propertyAddress);
        require(address(pToken) != address(0), "Invalid Property");
        require(msg.value == pToken.nonRefundableFee(), "Invalid Non Refundable fee");
        // check if its not already rented
        require(_isAvailable(propertyAddress, startDate, tempEndDate), "Already Rented"); 
        
        _tokenIds.increment();
        uint tokenId = _tokenIds.current();
    
        BookingToken bToken = new BookingToken(tokenId, pToken.ifpsAddress(),
                address(pToken),
                pToken.propertyOwner(),
                tenant, 
                startDate, 
                noOfWeeks, 
                pToken.rentFee(), 
                pToken.depositFee(), 
                pToken.nonRefundableFee());
        bookings.push(bToken);
        uint index = bookings.length.sub(1);
        propertyBookings[propertyAddress].push(index);    
        reservedWeeks[propertyAddress].push(ReservedWeek(startDate, tempEndDate, true));
        tokenIndex[tokenId] =  index;
        
        return tokenId;
    }
    
    function deposit(uint bookingId) public payable 
    {
        uint index = tokenIndex[bookingId];
        require(bookings[index]._status() == BookingToken.WorkflowStatus.DepositRequired, "Must Pay non refunadable first ");
        require (msg.value == bookings[index]._deposit(), "Invalid deposit Fee");
        deposits[bookingId] = msg.value;
        bookings[index].deposit();
        
    }
    function rent(uint bookingId, string memory tokenURI) public payable 
    {
        uint index = tokenIndex[bookingId];
        require(bookings[index]._status() == BookingToken.WorkflowStatus.RentRequired, "Must deposit first ");
        require (msg.value == bookings[index]._rent(), "Invalid rent Fee");
        bookings[index]._mintNft(tokenURI, bookingId);
        rentalTokens.push(index);
        tenantTokens[bookings[index]._tenant()].push(index);
        rents[bookingId] = msg.value;
    
    }

 // Fallback function
    function getTokenAddress(uint index) public view  returns (address) {
        return address(bookings[index]);
    }
    
    function withdraw(uint rentalId) public 
    {
        uint index = tokenIndex[rentalId];
        BookingToken bToken = bookings[index];
        require (address(bToken) != address(0), "Invalid Booking" );
        require (msg.sender == bToken._propertyOwner(), "Unauthorized" );
        require(bToken._status() == BookingToken.WorkflowStatus.Rented, "Not yet Rented");
     
        uint withDate = bToken._startDate().add(bToken._noOfWeeks().mul(3600).mul(24).div(7).add(5 days));
        require ( _fakenow > withDate, "Too Early" );
      
        uint amount = rents[rentalId];
        rents[rentalId] = 0;
        bToken._propertyOwner().transfer(amount);
        
    }

    function fastForward(uint startDate, uint noOFWeek, uint day) public {
        uint temp = 7 days + day;
        _fakenow = startDate + (noOFWeek.mul(3600).mul(24).mul(temp ));
    }
    function refund(uint rentalId) public
    {
        uint index = tokenIndex[rentalId];
        BookingToken bToken = bookings[index];
        
        require (address(bToken) != address(0), "Invalid Booking" );
        require (msg.sender == bToken._tenant(), "Unauthorized" );
        require(bToken._status() == BookingToken.WorkflowStatus.Rented, "Not yet Rented");
        uint withDate = bToken._startDate().add(bToken._noOfWeeks().mul(3600).mul(24).div(7).add(5 days));
        require (_fakenow > withDate, "Too Early" );
    
        uint amount = deposits[rentalId];
        deposits[rentalId] = 0;
        bToken._tenant().transfer(amount);

    }


 // NEED TO ADD MORE CHECKS
    function _isAvailable(address propertyAddress, uint startDate, uint endDate ) private view returns (bool)
    {
        bool isAvialable = true;
        for (uint j = 0; j < reservedWeeks[propertyAddress].length; j++ )
        {
            if ((startDate >= reservedWeeks[propertyAddress][j].startDate
                &&  startDate < reservedWeeks[propertyAddress][j].endDate) ||
                (endDate >= reservedWeeks[propertyAddress][j].startDate
                &&  endDate < reservedWeeks[propertyAddress][j].endDate) )
            
               isAvialable =  isAvialable && false;
        }       
        return isAvialable;
    
  
    }

    function getDetails(uint i) public view returns (address propertyToken, 
        address owner, 
        address  tenant, 
        uint startDate, 
        uint noOfWeeks, 
        uint _rent, 
        uint _deposit, 
        uint nonRefundable, BookingToken.WorkflowStatus _status)  {
         
            return bookings[i].getDetails(i);
        }
        
    function contractBreached(uint rentalId, address tenant)  public 
    {
        uint index = tokenIndex[rentalId];
        BookingToken bToken = bookings[index];
        
        require(bookings[index]._status() == BookingToken.WorkflowStatus.Rented, "Must renred");
        //require(msg.sender == bToken.propertyOwner(), "Unauthorized");
        
        //rentalTokens[]   check if the rentalToken is in the rentalTokens
        
        //uint fee = BookingToken.rent.div(2);
        //?delete propertyBookings[msg.sender][]
        //?tenantTokens[msg.sender]
        
        // refund before it burns        

        delete bookings[index];
 /*
     // array of bookings (until it converts to token)
    BookingToken[] bookings;

    // array of index in  Bookings
    uint[] public rentalTokens;
    
    //mapping of property to index in array
    mapping(address => uint[]) public propertyBookings;


    // tenant => index in BookingToken
    mapping(address => uint[]) public tenantTokens;

    //bookingid to depoist
    mapping(uint => uint) deposits;
    
    // rentalID to rent
    mapping(uint => uint) rents;
  
    // map of tokenid to index
    mapping(uint => uint ) tokenIndex;

 */
        //bToken.burn(rentalId);

    
    }

    function() external payable { } 
    
    
}