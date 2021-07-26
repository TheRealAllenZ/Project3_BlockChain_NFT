pragma solidity ^0.5.0;


pragma experimental ABIEncoderV2;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";

//import "openzeppelin-solidity/contracts/access/Roles.sol";

import "./Listings.sol";
import "./AdminRole.sol";
import "./RentalToken.sol";



contract ManageRentals  {

    //constructor() ERC721Full("RentalManager","DQAS") public {}
    using SafeMath for uint;
    //using Counters for Counters.Counter;

    
    address listingAddr;
    Listings listingAgent;
 
    Admin admins;
    
    uint constant WEEK0 = 1627241925;

    enum WorkflowStatus { Available, NonRefundableFeePayed, DepositPayed, Rented}
    
    struct Rental { 
      uint listingId;
      uint tokenId;
      uint nonRefundableTokenId;
      uint depositTokenId;
      uint weekOf;
      address payable owner;
      address payable renter;
      uint rent;
      uint deposit;
      WorkflowStatus status;
      bool exists; 
   }
   // mapping listingid => week of => rental
   mapping(uint => mapping(uint => Rental) ) public _propertyRentals;
   //mapping(uint => mapping(uint => Rental[]) ) public _propertyReservations;
   
   // listingid => weekof => renter => depoist
   mapping( uint => mapping(uint => mapping(address => uint))) public _depositsFee;
   
   // listingid => weekof => owner => rent
   mapping( uint => mapping(uint => mapping(address => uint))) public _rents;
   
   // listingid => weekof => nonRefundableFee, this is the contract service fee
   mapping( uint => mapping(uint => uint)) public _nonRefundableFee;
   
   // renter => tokens
   mapping( address => address[]) public _nonRefundableTokens;
   
   // renter => tokens
   mapping( address => address[]) public _depositTokens;
   
   // renter => tokens
   mapping( address => address[]) public _rentalTokens;
   

   // Set the Address of the listing Contract to interact with
   constructor(address _listingAddr) public {
       listingAddr = _listingAddr;
       listingAgent = Listings(listingAddr);
       //admins.addAdmin(msg.sender);
   }
   
   
   modifier onlyAdmin()
   {
       require(admins.isAdmin(msg.sender));
       _;
   }
   
   //TO DO add require statements and roles
   
   // can only be performed by admin
   function updateListingContract(address _listingContract) public  onlyAdmin {
 
       listingAddr = _listingContract;
       listingAgent = Listings(_listingContract);
   }
   
   /// Calculate the WeekOfRegistration from the WEEK0
   function calculateWeekof(uint start) public view returns (uint)
   {
       uint time = now;
       // Divide by 60 secs, 60 min, 24 hrs and 7 days to get the weekof
       //return ((((time.sub(start)).div(60)).div(60)).div(24)).div(7);
       return ((start - WEEK0) /  60 / 60 / 24 / 7);
   }
   
   
   modifier onlyOwner(address _owner, uint _listingId) {
       require(listingAgent.getOwner(_listingId) ==  _owner, "Owner does not match listing");
       _;
   }
   
   // Pay the non refundable fee and reserve the rental
   function nonRefundable(uint32 listingId, address payable renter, uint startDate ) public payable
   {
       address payable owner = listingAgent.getOwner(listingId);
       uint weekOf = calculateWeekof(startDate);
       _nonRefundable(listingId, renter, owner, weekOf, msg.value);
       
   }
   //Test function to see how to check if a rental exists
   function test(uint listingId, uint weekOf) public view returns (bool)
   {
        return _propertyRentals[listingId][weekOf].exists;
   }
   
   modifier BookingExists(uint listingId, uint weekOf) {
       require(!_propertyRentals[listingId][weekOf].exists , "Rental Already Exists");
       _;
   }
 
   modifier RentalAvialable(uint listingId, uint weekOf) {
       require(_propertyRentals[listingId][weekOf].status != WorkflowStatus.Available , "Property Already Booked");
       _;
   }
   
   modifier ValidNonRefundableFee(uint listingId, uint value) {
       require(listingAgent.getById(listingId).reservation == value, "Invalid nonRefundable Fee");
       _;
   }
   
   /// @dev reserves the object for any given time depending money sent and price of object   
   function _nonRefundable(uint listingId, address payable renter, address payable owner, uint weekOf, uint value) private
    ValidNonRefundableFee(listingId, value) BookingExists(listingId, weekOf)
   {
       Rental memory newRental;
       
       newRental.listingId = listingId;
       newRental.owner =  owner ;
       newRental.renter = renter;
       newRental.weekOf = weekOf;
       newRental.status = WorkflowStatus.NonRefundableFeePayed;
       newRental.exists = true;
        // create the Reservation token
        ReservationToken token = new ReservationToken();
        uint token_id = token.mintReservation(listingId, owner, renter, weekOf,  value);
        address token_address = address(token);
        _nonRefundableTokens[renter].push(token_address);
        newRental.nonRefundableTokenId = token_id;
        
       _propertyRentals[listingId][weekOf] = newRental;
       _nonRefundableFee[listingId][weekOf] = value; 

        
   }

}


/*
/*   
   /// @dev reserves the object for any given time depending money sent and price of object   
   function rental(uint reservationId ) public payable
   {
       Rental memory newRental = _reservations[reservationId];

       require((newRental.rent + newRental.deposit)  == msg.value, "Please Pay the rent + deposit");

       
       newRental.status = WorkflowStatus.Rented;
   
        // create the Reservation token
        RentalToken token = new RentalToken();
        uint token_id = token.mintRental(newRental.listingId, newRental.owner, newRental.renter, newRental.weekOf,  msg.value);
        address token_address = address(token);
        _rentalTokens[newRental.renter].push(token_address);
        newRental.tokenId = token_id;
        
       _propertyRentals[newRental.listingId][newRental.weekOf].push(newRental);
       _depositsFee[newRental.listingId][newRental.weekOf][newRental.renter] = newRental.deposit; 
       _rents[newRental.listingId][newRental.weekOf][newRental.owner] = newRental.rent;  
        
   }
   //only owner or an approved person TO DO
   /*function withdrawRent(uint listingId, uint weekof) public 
   {
    Rental storage tempRental = _propertyRentals[listingId][weekof];
       uint rent = _propertyRentals[listingId][weekof].rent;
       assert(rent == _rents[listingId][weekof][msg.sender]);
       _propertyRentals[listingId][weekof].rent = 0;
       msg.sender.Transfer(rent);
       
   }
   
   function refund(uint listingId, uint weekof) public
   {
       Rental storage tempRental = _propertyRentals[listingId][weekof];
       uint rent = tempRental.rent;
       assert(tempRental.deposit == _rents[listingId][weekof][msg.sender]);
       _propertyRentals[listingId][weekof].deposit = 0;

       msg.sender.Transfer(tempRental.deposit);
       
   }
   
   function checkAvailability(uint32 _listingId) public view returns(bool) 
      {
          //uint status =   listingAgent.getListingById(_listingId).status ;
         
          //if (status  == 0 )
         // {
              return true;
          //}
      }
   

*/