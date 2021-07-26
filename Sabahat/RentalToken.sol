pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";


contract ReservationToken is ERC721Full, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter _tokenIds;

    uint _token_id;
    uint _listingId;
    address payable _property_owner;
    address payable _renter;
    uint _rentalWeek;
    uint _reservationFee;
    mapping (uint => address) public propertyRenter;
    mapping (address => uint) propertyRenterCount;

       
    constructor() ERC721Full("ReservationToken", "RvT") public {
    }
    
    function mintReservation(        
        uint listingId, 
        address payable owner, 
        address payable renter, 
        uint rentalWeek, uint reservationFee) public returns (uint)
        {
            _listingId = _listingId;
            _property_owner = owner;
            _renter = _renter;
            _rentalWeek = _rentalWeek;
            _reservationFee = _reservationFee;
            _tokenIds.increment();
            _token_id = _tokenIds.current();
            _mint(renter, _token_id );
            //_setTokenURI(newItemId, tokenURI);
            //propertyRenter[_token_id] = renter;
            //propertyRenterCount[renter] +=1;
            return _token_id;
        
        }
    
    
     

}


contract RentalToken is ERC721Full, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter _tokenIds;

    uint _token_id;
    uint _listingId;
    address payable _property_owner;
    address payable _renter;
    uint _rentalWeek;
    uint _reservationFee;
    mapping (uint => address) public propertyRenter;
    mapping (address => uint) propertyRenterCount;

       
    constructor() ERC721Full("ReservationToken", "RvT") public {
    }
    
    function mintRental(        
        uint listingId, 
        address payable owner, 
        address payable renter, 
        uint rentalWeek, uint reservationFee) public returns (uint)
        {
            _listingId = _listingId;
            _property_owner = owner;
            _renter = _renter;
            _rentalWeek = _rentalWeek;
            _reservationFee = _reservationFee;
            _tokenIds.increment();
            _token_id = _tokenIds.current();
            _mint(renter, _token_id );
            //_setTokenURI(newItemId, tokenURI);
            //propertyRenter[_token_id] = renter;
            //propertyRenterCount[renter] +=1;
            return _token_id;
        
        }
    
    
     

}