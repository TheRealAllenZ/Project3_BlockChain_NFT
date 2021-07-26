
pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; 
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";

/*
TO DO: Add more functions, this will only be completed finalized once the front end is done. 

*/

//import "./AdminRole.sol";

///Listing Contract
contract Listings  {
    
    // using counters and safemath
    using Counters for Counters.Counter;
    using SafeMath for uint;

    // Status of the listing, Available/UnAvailable - ?? Need more status?
    enum  ListStatus { Available, UnAvailable, Removed } 
    
    //ListStatus public status ;
    
    // A struct of the listing
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
    
    // Listing Id
    Counters.Counter _listingsId;
    
    // mapping of owner to listing Id array 
    mapping(address => uint[]) public _ownerListings;
    
    // All owners??? Need to see if needed
    address[] public _owners;
    
    // Array of listings
    Listing[] _allListings;
    
    // Admin role
    //Admin admins;
    
    // events for listing Added, Updated and Removed    
    event ListingAdded(uint indexed listingsId, address indexed owner, string listingURI);
    event ListingRemoved(uint indexed listingsId, address indexed owner, string listingURI);
    event ListingUpdated(uint indexed listingsId, address indexed owner, string listingURI);
    
    ///Listings  
    constructor() public {
        // Set Admin role to the deployer ??
        //admins.addAdmin(msg.sender);
    }

    // modifier for OnlyIfListingIdExists
    modifier OnlyIfListingIdExists(uint listingId)
    {
        require(listingId <= _listingsId.current(), "Invalid List Id");
        _;
    }
    
    // modifier for OnlyIfListingsNotEmpty
    modifier OnlyIfListingsNotEmpty()
    {
        require( _listingsId.current() >0, "Listings are empty");
        _;
    }
    
    // modifier for OnlyIfListingIdExists
    modifier OnlyIfOwnerHasListings(address owner)
    {
        require(_ownerListings[owner].length > 0, "Invalid List Id");
        _;
    }
    
    
    ///Add a new listing
    function add(string calldata listingURI, uint rent) external returns(uint id)
    {
        // Calculate the reservation fee and the depoist fee
        uint reservation = rent.mul(2).div(7) ; // reservationFee is 2/7th of the rent for the week
        uint deposit = rent; // Depoist is 7/7 of the rent, i.e. same as the rent
    
        _listingsId.increment();
        uint listId = _listingsId.current();
        
        // Instantiate a new listing and fill it up 
        Listing memory newListing;
        newListing.id = listId;
        newListing.Url = listingURI;
        newListing.rent = rent;
        newListing.reservation = reservation;
        newListing.deposit = deposit;
        newListing.owner = msg.sender;
        newListing.status = ListStatus.Available;
        newListing.exists = true;
    
        //Add to all listings
        _allListings.push(newListing);
        // Push listingId on the owner's array of lists
        _ownerListings[msg.sender].push(listId);
     
        emit ListingAdded(listId, msg.sender, listingURI);
        
        return listId;
    
    }
    function getIndexOfOwnerListingId(uint listingId, address owner) private view returns(uint)
    {
        
        uint index;
        //Search for the index of the listId in ownerList
        for (uint i=0; i< _ownerListings[owner].length; i.add(1) )
        {
            if (listingId == _ownerListings[owner][i])
            {
                // index found
                index = i;
                continue;
            }
            
        }
        return index;

    }
    // Update a new listing
    // things that can be updated are as follows
    // URI, rent, owner, status
    function update(
        uint listingId,
        string calldata listingURI, 
        uint rent,
        address payable  owner,
        ListStatus status
        ) external 
    {
        // If  rent has changed, update reservation and deposit as well
        if (rent != _allListings[listingId.sub(1)].rent)
        {
            // Calculate the reservation fee and the depoist fee
            uint reservation = rent.mul(2).div(7) ; // reservationFee is 2/7th of the rent for the week
            uint deposit = rent; // Depoist is 7/7 of the rent, i.e. same as the rent
            _allListings[listingId.sub(1)].rent = rent;
            _allListings[listingId.sub(1)].reservation = reservation;
            _allListings[listingId.sub(1)].deposit = deposit;
        
        }
        // Save old owner
        address payable oldOwner = _allListings[listingId.sub(1)].owner;
        
        // Update all fields
        _allListings[listingId.sub(1)].Url = listingURI;
        _allListings[listingId.sub(1)].owner = owner;
        _allListings[listingId.sub(1)].Url = listingURI;
        _allListings[listingId.sub(1)].status = status;        

        
        // To Think how to remove listing from ownerlisting??
        // This will cost too much gas
        // Have to research more
        
         //Get Index of the listingId in ownerListings
        uint index;
        index = getIndexOfOwnerListingId(listingId, oldOwner);
        
        // remove the listing from old owner 
        delete _ownerListings[oldOwner][index];
         
         // Add the new owner
        _ownerListings[owner].push(listingId);
     
        // emit event
        emit ListingUpdated(listingId, owner, listingURI);

    }
    
    // Get the owner of the listing for the listingId
    function getOwner(uint listingId) public view OnlyIfListingIdExists(listingId) returns (address payable)
    {
        return _allListings[listingId - 1].owner;
    }
    
    // Get the status of the listing for the listingId
    function getStatus(uint listingId) public view OnlyIfListingIdExists(listingId) returns (ListStatus)
    {
        return _allListings[listingId.sub(1)].status;
    }
    
    // Get the listings for the owner
    function getByOwner(address owner) public view OnlyIfOwnerHasListings(owner) returns (Listing[] memory)
    {
        uint count = _ownerListings[owner].length;
        Listing[] memory tempListing = new Listing[](count);
        for (uint i =0; i <= count; i++)
        {
            tempListing[i] = _allListings[_ownerListings[owner][i].sub(1)];
        }
        return tempListing;
    }
    // Get Listing by Id
    function getById(uint listingId) public view OnlyIfListingIdExists(listingId)  returns (Listing memory)
    {
        return _allListings[listingId.sub(1)];
    }
    
    // Get Listing by Status
    function getByStatus(ListStatus _status) public view  returns (Listing[] memory )
    {
        uint count;
        uint i;
        for (i=0; i< _allListings.length; i.add(1) )
        {
            if (_allListings[i].status == _status)
            {
                count.add(1);
            }
            
        }
        uint k;
        Listing[] memory tempListings = new Listing[](count);
        for (i=0; i< _allListings.length;  i.add(1) )
        {
            if (_allListings[i].status == _status)
            {
                tempListings[k] = _allListings[i];
                k.add(1);
            }
            
        }
        return tempListings;
    }
    
    // Remove listing, as its expensive to delete from an array, we will just mark
    // the listing is marked as removed, HAVE TO ASK FOR BETTER WAY
    function remove(uint listingId) external OnlyIfListingIdExists(listingId)
    {
        
        _allListings[listingId.sub(1)].status = ListStatus.Removed;
        address oldOwner = _allListings[listingId.sub(1)].owner;
         //Get Index of the listingId in ownerListings
        uint index = getIndexOfOwnerListingId(listingId, oldOwner);
        
        // remove the listing from old owner 
        delete _ownerListings[oldOwner][index];
        
        emit ListingRemoved(listingId, oldOwner, _allListings[listingId -1].Url);
           
    }
    
    // Get all listings
    function getAll() public view OnlyIfListingsNotEmpty() returns (Listing[] memory) 
    {
        return _allListings;
    }
    
    // Get all listings
    function getCount() public view OnlyIfListingsNotEmpty() returns (uint) 
    {
        return _allListings.length;
    }
    

}