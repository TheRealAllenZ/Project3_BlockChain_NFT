
pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; 

/*
    @dev Token for rental Access of a property 
*/

contract BookingToken is ERC165, ERC721Full, Ownable {

    using SafeMath for uint;
    
    // workflow Status of the contract untill it is minted
    // NonRefundableFee Required => Deposit Required => Rent Required => Rented
    enum WorkflowStatus {NonRefundableFeeRequired, DepositRequired, RentRequired, Rented}
        
    // All properties of the rental
    // booking/tokenId
    uint public tokenId;
    // Address of the property
    address public propertyToken;
    // Owner of the property
    address payable public propertyOwner;
    // tenant that wants to rent
    address payable public tenant;
    // Start of rental
    uint public startDate;
    // Nof of weeeks to rent
    uint public noOfWeeks;
    // rent of the rental
    uint public  rent;
    // deposit of the rental
    uint public  deposit;
    // nonrefundable fee of the rental
    uint public  nonRefundable;
    // status in workflow
    WorkflowStatus public status;
    
    // Construct the token
    constructor(uint Id,  string memory propURI,
        address propToken, 
        address payable propOwner, 
        address payable propTenant, 
        uint startRentedDate, 
        uint noOfWeeksRented, 
        uint rentFee, 
        uint depositFee, 
        uint nonRefundableFee) 
        ERC721Full("Booking Token", "BKT") public  {
            tokenId = Id;
            propertyToken = propToken;
            propertyOwner = propOwner;
            tenant = propTenant;
            startDate = startRentedDate;
            noOfWeeks = noOfWeeksRented;
            rent = rentFee;
            deposit = depositFee;
            nonRefundable = nonRefundableFee;
            status = WorkflowStatus.DepositRequired;
        _setBaseURI(propURI);
    }

    // set decimals to 0, as each token is unqiue and one of a kind, as this pops up in metamask
    function decimals() external pure returns(uint) {
        return 0;
    }

    //@ dev get detials of the token
    function getDetails() external view returns (
                                        uint,
                                        address , 
                                        address , 
                                        address , 
                                        uint , 
                                        uint , 
                                        uint , 
                                        uint , 
                                        uint , WorkflowStatus)  {
                                            return (tokenId, propertyToken, 
            propertyOwner,
            tenant,
            startDate,
            noOfWeeks,
            rent,
            deposit,
            nonRefundable,
            status);
        }
    
    // @dev change status to deposit
    function depositRequest() external onlyOwner() {
            status = WorkflowStatus.RentRequired;
        }
    // mint the nft for rental access
    function _mintNft(string calldata URI, uint Id) external onlyOwner() returns (uint)
        {
            // make sure token id does not exists
            require(!_exists(Id), "Token Already Exists");
            tokenId = Id;
            // set status to rented
            status = WorkflowStatus.Rented;
            // mint the token to the tenant
            _mint(tenant, Id );
            // set URI
            _setTokenURI(Id, URI);
            return tokenId;
        
        }
    // @dev burn the token 
    function burn(address propTenant) external onlyOwner() {
        require(propTenant == tenant, "Not your token");
        _burn(tokenId);
    }
    
     

}