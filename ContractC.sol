pragma solidity ^0.4.24;

contract ContractC{

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint            _value,
        string          _remark
    );

    address owner;
    uint stepIdx = 1;

    constructor() public payable {
        owner = msg.sender;
    }

    function () public payable{}
    
    //caller -> CT; need amount for msg.value
    function deposit() public payable {
        require(msg.value > 0, "must provide amount to set msg.value");
        
        //do not need it; msg.value transfer to address(this) by program 
        //address(this).transfer(msg.value);
        
        address _from = msg.sender;
        address _to = address(this);
        uint _value = msg.value;
        emit Transfer(_from, _to, _value, "@deposit, caller -> CT");
    }
    
    //CT -> X
    function transport(address _to, uint _value) public payable {
        address _this = address(this);
        require(_this.balance >= _value, "@_value must <= _this.balance");
        
        _to.transfer(_value);
        emit Transfer(_this, _to, _value, "@transport, CT -> X");
    }

    //CT -> caller
    function refund(uint _refund_value) public payable {
        address _this = address(this);
        address _to = msg.sender;
        require(_this.balance >= _refund_value, "@_refund_value must <= _this.balance");
        _to.transfer(_refund_value);
        emit Transfer(_this, _to, _refund_value, "@refund, CT -> caller");
    }

    //any address, include the contract owner
    //return balance with unit wei
    function getbalance(address _addr) public view returns (uint) {
        return _addr.balance;
    }
    function getbalance() public view returns (uint) {
        return address(this).balance;
    }

    function setValue(address _walletAddr, uint _refundValue) public payable{
        address _this = address(this);
        address _from = msg.sender;

        _walletAddr.transfer(_refundValue);

        emit Transfer(_this, _from, _refundValue, "@contractC setValue,  CTC -> A transfer ");

    }

    function checkDebug() public view returns (uint){
        return stepIdx;
    }

    function f1() public view returns (uint) {
        stepIdx = 111;
        address _this = address(this);
        address _from = msg.sender;
        emit Transfer(_from, _this, stepIdx, "@contractC f1, stepIdx = 111 ");
        return stepIdx;
    }

    function f2() public {
        stepIdx = 222;
        address _this = address(this);
        address _from = msg.sender;
        emit Transfer(_from, _this, stepIdx, "@contractC f2, stepIdx = 222 ");
    }

    function f3(address _walletAddr, uint _refundValue) public payable {
        stepIdx = 333;
        address _this = address(this);
        address _from = msg.sender;

        _walletAddr.transfer(_refundValue);

        emit Transfer(_this, _walletAddr, _refundValue, "@contractC f3, stepIdx = 333, CTC -> A transfer ");

    }

}

