pragma solidity ^0.5.0;

import "@OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "@OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; 

import "./PropertyListing.sol";
import "./PropertyToken.sol";
import "./RentalToken.sol";

contract PropertyManager is Ownable {

    using SafeMath for uint;
  
    uint constant  SERVICE_FEE = 100;
    
    // array of all tokens
    PropertyToken[] public propertyTokens;
    
    // tokenid to index
    mapping(uint => uint) tokenIdToIndex;
    
    // owner to index of the token in in the tokens array 
    mapping(address => uint[]) public ownerTokens;
    
    // owner ==> count of tokens
    mapping(address => uint) public ownerCount;

    
    function addListing(address payable owner, 
                    string calldata tokenURI,
                    string calldata ipfsAddress,
                    uint rent,
                    uint startDate, 
                    uint endDate) external payable  returns(uint)  {
                        
        require(msg.value == SERVICE_FEE, "Please send in the exact service fee of 100 wei" );
        require(endDate > (startDate + 7 days), "End date should be atleast a week" );
        
        PropertyToken token = new PropertyToken("Adieu Coin", "ADIEU");
        uint token_id = token.mintNft(owner, tokenURI, ipfsAddress, rent, startDate, endDate, msg.value);
        propertyTokens.push(token);
        tokenIdToIndex[token_id] = propertyTokens.length.sub(1);
        ownerTokens[owner].push(propertyTokens.length.sub(1));
        ownerCount[owner] = ownerCount[owner].add(1);
        return token_id;
                        
    }
    
    function getTokenAddress(uint index) public view returns (address)
    {
        return address(propertyTokens[index]);  
    }

   function getDetails(uint index) public view returns 
        (address payable  propertyOwner,
        uint  rentFee,
        uint  nonRefundableFee,
        uint  depositFee,
        PropertyToken.Status  propertyStatus,
        uint  startAvailability,
        uint  endAvailability)

    {
        
        return propertyTokens[index].getDetails();
    }
  
    function removeToken(address owner, uint tokenId) onlyOwner() public 
    {
        // check to see if any tokens for woner that are still noyt fullfilled
        // if any then dont let removeToken
        //otherwise remove
        uint index = tokenIdToIndex[tokenId];
        delete ownerTokens[owner][index] ;
        ownerCount[owner] = ownerCount[owner] - 1;
        delete tokenIdToIndex[tokenId];
        delete propertyTokens[index];
        PropertyToken pToken = propertyTokens[index];
        //pToken.remove();
    }


}