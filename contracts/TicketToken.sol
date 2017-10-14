pragma solidity 0.4.15;

import './ERC20.sol';

contract TicketToken is ERC20 {

    address owner; 
    string public constant symbol = 'CNT';
    string public constant name = 'Community Network Token';
    uint8 public constant decimals = 18;

    uint public constant __totalSupply = 100000;

    mapping(address => uint256) balances;
    
    // who is giving permission => (who is given permission to spend funds => how much allowed to spend)
    mapping(address => mapping(address => uint256)) approved;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        } else {
            _;
        }
    }

    function TicketToken() {
        uint256 _initial;
        balances[msg.sender] = __totalSupply;
    }

    function totalSupply() constant returns (uint _totalSupply) {
        return __totalSupply;
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) returns (bool success) {
        // require will throw an exception if any conditions inside fail
        require(
            balances[msg.sender] <= _value &&
            _value > 0 
        );
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool success) {
        require(
            approved[_from][msg.sender] >= _value &&
            balances[msg.sender] > _value &&
            _value > 0
        );
        balances[_from] -= _value;
        balances[_to] += _value;
        // lower the total amount allowed to spend
        approved[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) returns (bool success) {
        approved[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return approved[_owner][_spender];
    }

} 