pragma solidity 0.4.15;

import './ERC20.sol';
import './SafeMath.sol';

contract TicketToken is ERC20 {
    
    using SafeMath for uint256;
    
    uint public constant _totalSupply = 0;

    string public constant symbol = 'CNT';
    string public constant name = 'Community Network Token';
    uint8 public constant decimals = 18;
    
    // 1 ether = 500 CNT
    uint256 public constant RATE = 500;
    
    address public owner;

    mapping(address => uint256) balances;
    // who is giving permission => (who is given permission to spend funds => how much allowed to spend)
    mapping(address => mapping(address => uint256)) approved;
    
    // callback function, so that people can directly send money to contract address
    function () payable {
        createTokens();
    }


    function TicketToken() {
        owner = msg.sender;
    }
    
    function createTokens() payable {
        require(msg.value > 0);
        
        uint256 tokens = msg.value.mul(RATE);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        
        owner.transfer(msg.value);
    }

    function totalSupply() constant returns (uint _totalSupply) {
        return _totalSupply;
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) returns (bool success) {
        // require will throw an exception if any conditions inside fail
        require(
            balances[msg.sender] >= _value &&
            _value > 0 
        );
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool success) {
        require(
            approved[_from][msg.sender] >= _value &&
            balances[msg.sender] > _value &&
            _value > 0
        );
        balances[_from] = balances[msg.sender].sub(_value);
        balances[_to] = balances[msg.sender].add(_value);
        // lower the total amount allowed to spend
        approved[_from][msg.sender] = approved[_from][msg.sender].sub(_value);
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
    
    function buyToken(uint _value) {
        //value is number of tickets        
    }

} 