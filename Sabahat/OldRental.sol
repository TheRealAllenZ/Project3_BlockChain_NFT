pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";

contract RentalToken is ERC721Full, Ownable {


    uint _listingId;
    address payable _property_owner;
    address payable _renter;
    uint _rentalWeek;
    string _contractUri;
    using Counters for Counters.Counter;
    Counters.Counter _tokenIds;

   
    constructor() ERC721Full("RentalToken", "RTT") public {
            
                        
    }

    function mint(
        uint listingId, 
        address payable owner, 
        address payable renter, 
        uint rentalWeek,
        string memory contractUri) public returns (uint256) {
            
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(renter, newItemId);
        _setTokenURI(newItemId, contractUri);

        return newItemId;
    }
}


contract ReservationToken is ERC721Full, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter _tokenIds;

    uint token_id;
    uint _listingId;
    address payable _property_owner;
    address payable _renter;
    uint _rentalWeek;
    uint _reservationFee;

       
    constructor(
        uint listingId, 
        address payable owner, 
        address payable renter, 
        uint rentalWeek, uint reservationFee)
            ERC721Full("ReservationToken", "RrT") public returns(uint) {
    
            
            listingId = _listingId;
            property_owner = _owner;
            renter = _renter;
            rentalWeek = _rentalWeek;
            reservationFee = _reservationFee;
            _tokenIds.increment();
             token_id = _tokenIds.current();
            _mint(_renter, token_id );
            //_setTokenURI(newItemId, tokenURI);
            
    }
    
    function getTokenId() public view returns (uint)
    {
         return   token_id; 
    }
}
    
     

}