pragma solidity >=0.5.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Allowance is Ownable{
    
    using SafeMath for uint;
    
    event AllowanceChanged(address _forwho, address indexed _forwhom,uint _oldamount,uint _newamount);
    
    mapping(address => uint) public allowance;
    
    function setAllowance(address _who , uint _amount) public onlyOwner {
        emit AllowanceChanged (_who,msg.sender,allowance[_who],_amount);
        allowance[_who] = _amount;
    }
    
    modifier ownerOrAllowed(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount , "You are not allowed !");
        _;
    }
    
    function reduceAllowance(address _who,uint _amount) internal {
        emit AllowanceChanged(_who,msg.sender,allowance[_who],allowance[_who].sub(_amount));
        allowance[_who]  = allowance[_who].sub(_amount);
    }
}

contract Wallet is Allowance {
    
    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);
    
    function withdrawMoney (address payable _to , uint _amount) public ownerOrAllowed(_amount) {
        if(!isOwner()){
            reduceAllowance(msg.sender,_amount);
        }
        emit MoneySent(_to,_amount);
        _to.transfer(_amount);
    }
    
    receive() external payable  {
        emit MoneyReceived(msg.sender,msg.value);
    }
    
}