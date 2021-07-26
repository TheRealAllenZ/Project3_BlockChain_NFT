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

    using Counters for Counters.Counter;
    Counters.Counter tokenIds;

    Counters.Counter reservationIds;

    Counters.Counter depoistIds;
    
    
    address listingAddr;
    Listings listingAgent;

    /*    
    address rentalTokenAdrr;
    address reservationTokenAddr;
    address depositTokenAddr;
    */
    
    Admin admins;
    
    uint constant WEEK0 = 1627241925;

    enum WorkflowStatus {Available, ReservationFeePayed, DepositPayed, Rented}
    
    struct Rental { 
      uint listingId;
      uint tokenId;
      uint reservationId;
      uint depositId;
      uint weekOf;
      address payable owner;
      address payable renter;
      uint rent;
      uint deposit;
      WorkflowStatus status;
      
   }
   // mapping listingid => week of => rental
   mapping(uint => mapping(uint => Rental[]) ) public _propertyRentals;
   mapping(uint => mapping(uint => Rental[]) ) public _propertyReservations;
   
   // listingid => weekof => renter => depoist
   mapping( uint => mapping(uint => mapping(address => uint))) public _depositsFee;
   
   // listingid => weekof => owner => depoist
   mapping( uint => mapping(uint => mapping(address => uint))) public _rents;
   mapping( uint => mapping(uint => mapping(address => uint))) public _reservationFee;
   
   
mapping( address => address[]) public _reservationTokens;
   mapping( address => address[]) public _rentalTokens;
   
   mapping(uint => Rental) _reservations;
   mapping(uint => Rental) _rentals;
   
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
   
   function calculateWeekof(uint start) public view returns (uint32)
   {
       uint time = now;
       return uint32((time - start) /  60 / 60 / 24 / 7);
   }
   
   
   modifier onlyOwner(address _owner, uint _listingId) {
       require(listingAgent.getListingOwner(_listingId) ==  _owner, "Owner does not match listing");
       _;
   }
   
   
   /// @dev reserves the object for any given time depending money sent and price of object   
   function reservation(uint32 listingId, address payable renter, uint startDate ) public payable
   {
       address payable owner = listingAgent.getListingOwner(listingId);
       uint32 weekOf = calculateWeekof(WEEK0 - startDate);
       
       require(listingAgent.getListingById(uint32(listingId)).reservation == msg.value, "Invalid reservation fee, please pay the correct reservation fee");
       //require(checkAvailability(listingId), "The Property is not available for the week"  );
        
       Rental memory newRental;
       
       //reservationIds.increment();
       //uint32 id = uint32(reservationIds.current());
       
       
       
       newRental.listingId = listingId;
       newRental.owner =  owner ;
       newRental.renter = renter;
       newRental.weekOf = weekOf;
       newRental.status = WorkflowStatus.ReservationFeePayed;
       
       
        // create the Reservation token
        ReservationToken token = new ReservationToken();
        uint token_id = token.mintReservation(listingId, owner, renter, weekOf,  msg.value);
        address token_address = address(token);
        _reservationTokens[renter].push(token_address);
        newRental.reservationId = token_id;
        
       _propertyReservations[listingId][weekOf].push(newRental);
       _reservationFee[listingId][weekOf][owner] = msg.value; 
        _reservations[token_id] =  newRental;   
        
   }

}
