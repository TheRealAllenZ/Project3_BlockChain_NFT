pragma solidity ^0.5.0;

contract test {
    
    

    function getNow() public view returns (uint)
    {
        return now + 10 weeks;
    }
    
    function getWeekof(uint time) public view returns (uint) {
        return ((now - time) /  60 / 60 / 24 / 7);
        
    }
}