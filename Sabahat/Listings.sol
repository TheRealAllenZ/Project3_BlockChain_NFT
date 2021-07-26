
pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";


contract Listings  {
    using Counters for Counters.Counter;

    //bytes32 public constant ADMIN = keccak256("Admin");
    //bytes32 public constant LISTING_OWNER = keccak256("LISTING_OWNER");
    //bytes32 public constant RENTER = keccak256("RENTER");
    
    enum  ListStatus { Available, Reserved, Rented, UnAvailable } 
    ListStatus public status ;
    struct Listing {
        uint id;
        address payable owner;
        string Url;
        uint rent;
        uint reservation;
        uint deposit;
        ListStatus status;
        bool exists;
    }
    
    Counters.Counter listingsId;
    mapping(address => uint[]) public ownerListings;
    address[] public owners;
    Listing[] allListings;
    
    /*/// Listing does not exist
    error ListingDoesNotExist;
    */
    constructor() public {
        //grantRole(ADMIN, msg.sender);   
        
        
    }
    
    
    function addListing(string calldata _url, uint rent, uint reservation, uint deposit) external returns(uint id)
    {

        listingsId.increment();
        uint listId = uint(listingsId.current());
        Listing memory newListing;
        newListing.id = listId;
        newListing.Url = _url;
        newListing.rent = rent;
        newListing.reservation = reservation;
        newListing.deposit = deposit;
        newListing.owner = msg.sender;
        newListing.status = ListStatus.Available;
        newListing.exists = true;
        //ownerListings[msg.sender].push(newListing);
        //grantRole(LISTING_OWNER, msg.sender);
        allListings.push(newListing);
        ownerListings[msg.sender].push(listId);
        return id;

    }
    
    modifier listingExists(uint _listingId)
    {
        require(_listingId <= listingsId.current(), "No listings");
        _;
    }
    
    function getListingOwner(uint _listingId) public view listingExists(_listingId) returns (address payable)
    {
        return allListings[_listingId - 1].owner;
    }

    function getListingStatus(uint _listingId) public view listingExists(_listingId) returns (uint)
    {
        return uint(allListings[_listingId - 1].status);
    }
    
    function getListingByOwner(address owner) public view returns (Listing[] memory)
    {
        uint count = ownerListings[owner].length;
        Listing[] memory tempListing = new Listing[](count);
        for (uint i =0; i <= count; i++)
        {
            tempListing[i] = allListings[ownerListings[owner][i] -1];
        }
        return tempListing;
    }
    
    function getListingById(uint _listingId) public view listingExists(_listingId)  returns (Listing memory _listing)
    {
        return allListings[_listingId - 1];
    }
    
    function getListingsByStatus(ListStatus _status) public view returns (Listing[] memory _listing)
    {
        uint count;
        uint i;
        for (i=0; i< allListings.length; i++ )
        {
            if (allListings[i].status == _status)
            {
                count++;
            }
            
        }
        uint k;
        Listing[] memory tempListings = new Listing[](count);
        for (i=0; i< allListings.length; i++ )
        {
            if (allListings[i].status == _status)
            {
                tempListings[k] = allListings[i];
                k++;
            }
            
        }
        return tempListings;
    }
    
    
    function addRemove(uint _listingId) external listingExists(_listingId)
    {
        
        allListings[_listingId].status = ListStatus.UnAvailable;
           
    }
    
    function getAllListings() public view returns (Listing[] memory) 
    {
        require(listingsId.current() > 0, "No listings");
        return allListings;
    }
    
    
   
}