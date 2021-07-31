pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; 

import "./PropertyToken.sol";
import "./RentalToken.sol";
import "./PropertyManager.sol";


/*
    @dev Contract that manages the rentals, its process
    
*/
contract BookingManager {
    
    using SafeMath for uint;
 
    using Counters for Counters.Counter;
    
    // counter to generate new tokenids and keep track
    Counters.Counter  _tokenIds;
   
    // signifies the startdate and #of weeks
    struct ReservedWeek {
        uint startDate;
        uint endDate;
        bool reserved;
    }
    
    // array of bookings (until it converts to token)
    BookingToken[] bookings;

    //Property Address => Reserved Week
    mapping(uint => ReservedWeek[]) reservedWeeks;

    // array of rented tokens  index in  Bookings
    uint[] public rentalTokens;
    
    //mapping of propertyId to index in array
    mapping(address => uint[]) public propertyBookings;


    // tenant => index in BookingToken
    mapping(address => uint[]) public tenantTokens;

    //bookingid to depoist
    mapping(uint => uint) deposits;
    
    // rentalID to rent
    mapping(uint => uint) rents;
  
    // map of tokenid to index
    mapping(uint => uint ) tokenIndex;

    // map of bookingindex to rental index
    mapping(uint => uint ) bookingToRental;
    
    // address of property BookingManager
    PropertyManager pManager;
    
    // dummy variable to fast forward time 
    uint _fakenow = now;

    //events
    event Withdrwal(address propOwner, uint propertyId, uint BookingId, uint amount, uint sDateOfWithWithrwawal);
    event Refund(address propTenant, uint propertyId, uint BookingId, uint amount, uint sDateOfWithWithrwawal);
    event RentWithdrawn(address propOwner,uint propertyId, uint BookingId, uint amount);
    event RefundWithdrawn(address propTenant, uint propertyId, uint BookingId, uint amount);
    
    
    //fall back function to accept eth
    function() external payable { } 
 
    //@ dev load the propertyManager at that address
    constructor(address payable managerAddr) public {
        require(managerAddr != address(0), "Invalid Address");
        // Get PropetyToken at the address
        pManager = PropertyManager(managerAddr);
        require(address(pManager) != address(0), "Invalid Address");
    }

    //@ dev Fallback function
    function getTokenAddress(uint index) external view  returns (address) {
        return address(bookings[index]);
    }
    
    //@ dev pay the non refundable fee for the property to start the process of renting
    // creates the smart contract for te booking
    // sets status to DepositRequired
    function reserve(uint propertyId,  uint startDate, uint noOfWeeks, address payable tenant) 
                                external payable returns (uint)
    {

        // booking for more than a week
        require(noOfWeeks > 0, "Book for alteast one week");
        
        // calculate the end date
        uint tempEndDate = startDate +  (noOfWeeks.mul(7).mul(24).mul(60).mul(60));
        
        // Get the index of the token in the array
        uint pIndex = pManager.tokenIdToIndex(propertyId);
        // get the property Token    
        PropertyToken pToken = pManager.propertyTokens(pIndex);
        
        // check that the token can be loaded
        require(address(pToken) != address(0), "Invalid Property");
        
        
        // check that the token can be loaded
        require(pToken.exists(), "Invalid Property");

        
        // Check if the start date and number of weeks fall in the property availaibilty range
        require((startDate >= pToken.startAvailability()) && (tempEndDate < pToken.endAvailability()), "Unavailable Property");
        
        // Check if the eth passed matches the rental amount
        require(msg.value == pToken.nonRefundable(), "Invalid Non Refundable fee");
        
        // check if its not already rented
        require(_isAvailable(propertyId, startDate, tempEndDate), "Already Rented"); 
        
        // get the nect token Id
        _tokenIds.increment();
        uint tokenId = _tokenIds.current();
    
        // Create a booking Token
        BookingToken bToken = new BookingToken(tokenId, pToken.ifpsAddress(),
                address(pToken),
                pToken.propertyOwner(),
                tenant, 
                startDate, 
                noOfWeeks, 
                pToken.rent(), 
                pToken.deposit(), 
                pToken.nonRefundable());
                
        // Push to the array of tokens        
        bookings.push(bToken);
        
        //Get the index in the array- assuimg this is the last one inserted
        // possible bug ?? 
        uint index = bookings.length.sub(1);
        
        // Push index of the property in bookings array to the property address mapping
        // This is to keep track of the of 
        propertyBookings[address(pToken)].push(index); 
        
        // reserve the weeks 
        //?? Logic needs to be looked at
        reservedWeeks[propertyId].push(ReservedWeek(startDate, tempEndDate, true));
        
        //mapping of tokenId to index
        tokenIndex[tokenId] =  index;
        
        return tokenId;
    }

   //@dev fast forward time to test the the withdrwal 
    function fastForward(uint startDate, uint noOFWeek, uint day) external {
        uint temp = 7 days + day;
        _fakenow = startDate + (noOFWeek.mul(3600).mul(24).mul(temp ));
    }
    
 
    //@dev recieves the desposit in wie for the booking id   
    // updates the status to Rented
    function deposit(uint bookingId) external payable 
    {
        // Get the index of the booking from the bookingId
        uint index = tokenIndex[bookingId];
        // Check if the sender is the tenant
        require(msg.sender == bookings[index].tenant(), "Unauthorized ");
        //Check we have the booking at the right step by checking the status
        require(bookings[index].status() == BookingToken.WorkflowStatus.DepositRequired, "Must Pay non refunadable first ");
        // Check the sender is paying the correct deposit        
        require (msg.value == bookings[index].deposit(), "Invalid deposit Fee");
        // set the bookingId to the depoist paid
        deposits[bookingId] = msg.value;
        // call the token function to update status
        bookings[index].depositRequest();
        
        uint wDate = calculateWithdralDate(bookings[index].startDate(), bookings[index].noOfWeeks());
        
        emit Refund(bookings[index].propertyOwner(), bookings[index].tokenId(), bookingId, msg.value, wDate );    
    }
    
  
    //@dev recieves the rent in wie  
    // mints the token to the tenant of the bookingId
    // updates status to rentRequired
    function rent(uint bookingId, string calldata tokenURI) external payable 
    {
        // Get the index of the booking from the bookingId
        uint index = tokenIndex[bookingId];
        // Check if the sender is the tenant
        require(msg.sender == bookings[index].tenant(), "Unauthorized ");
        //Check we have the booking at the right step by checking the status
        require(bookings[index].status() == BookingToken.WorkflowStatus.RentRequired, "Must deposit first ");
        // Check the sender is paying the correct deposit  
        require (msg.value == bookings[index].rent(), "Invalid rent Fee");
        // push the index on the rentals array
        rentalTokens.push(index);
        uint rIndex = rentalTokens.length.sub(1); 
        // push the index on the tenants booking
        tenantTokens[bookings[index].tenant()].push(index);
        // set the rent paid to the depoist paid
        rents[bookingId] = msg.value;
        //mint the token now
        bookings[index]._mintNft(tokenURI, bookingId);
        bookingToRental[index] = rIndex;
        uint wDate = calculateWithdralDate(bookings[index].startDate(), bookings[index].noOfWeeks());
        
        emit Withdrwal(bookings[index].propertyOwner(), bookings[index].tokenId(), bookingId, msg.value, wDate );    
    }

    //@dev withdraw the rent from the contract 5 days after the rental contract has ended 
    function withdraw(uint rentalId) external 
    {
        // Get the index of the booking from the bookingId
        uint index = tokenIndex[rentalId];
        // Get the booking/rental at that index
        BookingToken bToken = bookings[index];
        // Check that its a valid booking
        require (address(bToken) != address(0), "Invalid Booking" );
        require(bToken.rent() > 0, "Already Withdrawn");
        // Only the propery owner can withdraw the funds
        require (msg.sender == bToken.propertyOwner(), "Unauthorized" );
        // Check if the status is rented
        require(bToken.status() == BookingToken.WorkflowStatus.Rented, "Not yet Rented");
        // calculate the withdrawal date
        uint withDate = bToken.startDate().add(bToken.noOfWeeks().mul(3600).mul(24).div(7).add(5 days));
        require ( _fakenow > withDate, "Too Early" );
        // get the rent amount
        uint amount = rents[rentalId];
        // Set it to 0
        rents[rentalId] = 0;
        // tranfer to the amount to the property owner
        bToken.propertyOwner().transfer(amount);
        //emit RentWithdrawn(bToken.propertyOwner(),bToken.propertyToken().tokenId(), rentalId, amount);
    
    }
        
    //@dev refund the deposit to the renter 5 days after the rental contract has ended 
    function refund(uint rentalId) external
    {
        // get index from token Id
        uint index = tokenIndex[rentalId];
        //load the booking 
        BookingToken bToken = bookings[index];
        // Check valid booking
        require (address(bToken) != address(0), "Invalid Booking" );
        //check if authorized
        require (msg.sender == bToken.tenant(), "Unauthorized" );
        // Check if already refunded
        require(bToken.deposit() > 0, "Nothing to refund");
        //Check if at correct status
        require(bToken.status() == BookingToken.WorkflowStatus.Rented, "Not yet Rented");
        //calculate withdrawal date
        uint withDate = bToken.startDate().add(bToken.noOfWeeks().mul(3600).mul(24).div(7).add(5 days));
        // Check if its time to withdraw
        require (_fakenow > withDate, "Too Early" );
        // get amount to refund
        uint amount = deposits[rentalId];
        // set to 0
        deposits[rentalId] = 0;
        //refunf the amount
        bToken.tenant().transfer(amount);
        //emit RefundWithdrawn(bToken.propertyOwner(),bToken.propertyToken.tokenId(), rentalId, amount);
   

   
    }

    function getDetails(uint i) external view returns (uint tokenid, address propertyToken, 
        address owner, 
        address  tenant, 
        uint startDate, 
        uint noOfWeeks, 
        uint _rent, 
        uint _deposit, 
        uint nonRefundable, BookingToken.WorkflowStatus _status)  {
         
            return bookings[i].getDetails();
        }
        

    function contractBreached(uint rentalId, address tenant, uint breachFee)  external payable
    {
        uint index = tokenIndex[rentalId];
        BookingToken bToken = bookings[index];
        uint fee = bToken.rent().div(2);
     
        require(bToken.status() == BookingToken.WorkflowStatus.Rented, "Must rented");
        require(msg.sender == bToken.propertyOwner(), "Unauthorized");
        require(msg.value == fee, "Unauthorized");
        
        uint amount = deposits[rentalId] - breachFee;
        deposits[rentalId] = 0;
        
        // get the rental index from booking Id
        uint rIndex = bookingToRental[rentalId];
        //Delete rental
        delete rentalTokens[rIndex];
        // Delete booking to rental
        delete bookingToRental[index];
        
        delete propertyBookings[bToken.propertyToken()][index];
        delete deposits[rentalId];
        delete rents[rentalId];
        delete tenantTokens[msg.sender][index];
        delete tokenIndex[rentalId];
        delete bookings[index];
        bToken.tenant().transfer(amount);
        bToken.burn(bToken.tenant());
        
    
    }
    /*
    function getBookingCnt() external view returns (uint)
    {
        return bookings.count();
    }

    function getCntForTenant(address tenant) external view returns (uint)
    {
        return rentalTokens.count();
    }
    
    function getCntForProperty(uint propertyId) external view returns (uint)
    {
        return propertyBookings[pManager
    }
    */
    
 // NEED TO ADD MORE CHECKS
    function _isAvailable(uint propertyId, uint startDate, uint endDate ) private view returns (bool)
    {
        bool isAvialable = true;
        for (uint j = 0; j < reservedWeeks[propertyId].length; j++ )
        {
            if ((startDate >= reservedWeeks[propertyId][j].startDate
                &&  startDate < reservedWeeks[propertyId][j].endDate) ||
                (endDate >= reservedWeeks[propertyId][j].startDate
                &&  endDate < reservedWeeks[propertyId][j].endDate) )
            
               isAvialable =  isAvialable && false;
        }       
        return isAvialable;
    
  
    }
    
    function calculateWithdralDate(uint startDate, uint noOfWeeks) private pure returns (uint)
    {
        return startDate.add(noOfWeeks.mul(3600).mul(24).div(7).add(5 days));

    }
}