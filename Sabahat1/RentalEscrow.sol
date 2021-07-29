pragma solidity ^0.5.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; 

import 'openzeppelin-solidity/contracts/payment/escrow/Escrow.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

/**
 * @title Payment gateway using OpenZeppelin Escrow
 * @author Will Shahda
 */
contract PaymentGateway is Ownable {
    using SafeMath for uint256;

    Escrow escrow;
    address payable wallet;

    /**
     * @param _wallet receives funds from the payment gateway
     */
    constructor(address payable _wallet) public {
        escrow = new Escrow();
        wallet = _wallet;
    }

    /**
     * Receives payments from customers
     */
    function sendPayment() external payable {
        escrow.deposit.value(msg.value)(wallet);
    }

    /**
     * Withdraw funds to wallet
     */
    function withdraw() external onlyOwner {
        escrow.withdraw(wallet);
    }

    /**
     * Checks balance available to withdraw
     * @return the balance
     */
    function balance() external view onlyOwner returns (uint256) {
        return escrow.depositsOf(wallet);
    }
}