
pragma solidity ^0.5.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; 


import "./PropertyListing.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";

/*
TO DO: Add more functions, this will only be completed finalized once the front end is done. 

*/

contract PropertyListing is Ownable  {
    
    using SafeMath for uint;
        
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

    
    event ListingAdded(address indexed owner, string listingURI);
    event ListingRemoved(address indexed owner, string listingURI);
    event ListingUpdated(address indexed owner, string listingURI);
      
    constructor() public {
    }

    
    // Add a new listing
    function add(address payable owner, string calldata listingIFPS, uint rent, uint fee, uint startDate, uint endDate) external onlyOwner()
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

        emit ListingAdded(owner, listingIFPS);

    }

    function update(address payable owner, string calldata listingIFPS, uint rent, Status status) external onlyOwner()
    {
        // Calculate the reservation fee and the depoist fee
        nonRefundableFee = rent.mul(2).div(7) ; // reservationFee is 2/7th of the rent for the week
        depositFee = rent; // Depoist is 7/7 of the rent, i.e. same as the rent
        rentFee = rent;
        ifpsAddress = listingIFPS;
        propertyOwner = owner;
        propertyStatus = status;

        emit ListingUpdated(propertyOwner, listingIFPS);

    }

    // Remove listing, as its expensive to delete from an array, we will just mark
    // the listing is marked as removed, HAVE TO ASK FOR BETTER WAY
    function takeOfMarket() external onlyOwner() 
    {
        propertyStatus = Status.UnAvailable;  
        emit ListingRemoved(propertyOwner, ifpsAddress);
    }
    
    

}