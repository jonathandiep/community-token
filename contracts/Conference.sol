pragma solidity ^0.4.4;

contract Conference {
  address public organizer;
  mapping (address => uint) public registrantsPaid;
  uint public numRegistrants;
  uint public quota;
  uint public ticketCost;

  // events can be logged/watched
  event Deposit(address _from, uint _amount);
  event Refund(address _to, uint _amount);

  // Constructor
  function Conference() {
    organizer = msg.sender;
    quota = 500;
    numRegistrants = 0;
    ticketCost = 1 ether;
  }

  // NOTE: payable functions to the contract explicitly needs "payable" after the name
  function buyTicket() payable public {
    if (numRegistrants >= quota) {
      revert();
    }

    if (msg.value < 1 ether) {
      revert();
    }

    registrantsPaid[msg.sender] = msg.value;
    numRegistrants++;
    Deposit(msg.sender, msg.value);
  }

  modifier onlyOwner() {
    if (msg.sender != organizer) {
      revert();
    } else {
      _;
    }
  }

  function changeQuota (uint newquota) onlyOwner public {
    quota = newquota;
  }

  function refundTicket(address recipient, uint amount) onlyOwner public {
    if (registrantsPaid[recipient] == amount) {
      address myAddress = this;
      if (myAddress.balance >= amount) {
        recipient.transfer(amount);
        registrantsPaid[recipient] = 0;
        numRegistrants--;
        Refund(recipient, amount);
      }
    }
  }

  // so funds not locked in contract forever
  function destroy() {
    if (msg.sender == organizer) {

      // send funds to organizer
      selfdestruct(organizer);
    }
  }
}
