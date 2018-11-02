pragma solidity ^0.4.24;
//import "/home/loyal/work/git/qtum-test-suite/s5__contract-call-contract/cicalljs-cli/cicall-solidity/ContractB.sol";
import "./ContractB.sol";

contract ContractA{

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

        address _from = msg.sender;
        address _to = address(this);
        uint _value = msg.value;

        //do not need it; msg.value transfer to address(this) by program 
        //address(this).transfer(msg.value);
        
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

    //caller -> CT -> CT; need amount for msg.value
    function transferCCC(address _addr1, address _addr2, address _walletAddr, uint _value1, uint _value2, uint _refundValue) public payable returns (uint){
        address _this = address(this);
        address _from = msg.sender;

        _addr1.transfer(_value1); 

        emit Transfer(_this, _addr1, _value1, "@transferCCC , CTA -> CTB  ");

        //1:
        //_addr1.call(bytes4(sha3("setValue(address, uint, uint)")), _addr2, _value2, _refundValue);
        //2.
        //bytes memory payload = abi.encodeWithSignature("setValue(address, uint, uint)", _addr2, _value2, _refundValue);
        //address(_addr1).call(payload);
        //3.
        ContractB contractB;
        contractB = ContractB(_addr1);
        contractB.setValue.value(1000000)(_addr2, _walletAddr, _value2, _refundValue);
        //4.
        //_addr1.call(bytes4(keccak256("setValue(address, uint, uint)")), _addr2, _value2, _refundValue);
        
        stepIdx = 2;
        return(stepIdx);

    }

    function checkDebug() public view returns (uint){
        return stepIdx;
    }


    function f_d1_1(address _b) public view returns (uint) {
        stepIdx = 10;

        address _this = address(this);
        address _from = msg.sender;


        ContractB ctB = ContractB(_b);
        stepIdx = ctB.f1.gas(100000)();
        //stepIdx = ctB.f1.(); //works too

        emit Transfer(_from, _this, stepIdx, "@contractA f_d1_1, stepIdx = 10");

        return stepIdx;
    }

    function f_d1_2(address _b) public {
        stepIdx = 20;

        address _this = address(this);
        address _from = msg.sender;

        ContractB ctB = ContractB(_b);
        ctB.f2.gas(100000)();
        //ctB.f2.(); //works too

        emit Transfer(_from, _this, stepIdx, "@contractA f_d1_2, stepIdx = 20");
    }

    function f_d1_3(address _b, address _walletAddr, uint _value, uint _refundValue) public payable {
        stepIdx = 30;

        address _this = address(this);
        address _from = msg.sender;

        _b.transfer(_value); 

        emit Transfer(_from, _this, _value, "@contractA f_d1_3, stepIdx = 30, CTA - CTB");

        ContractB contractB;
        contractB = ContractB(_b);
        contractB.f3.value(11223)(_walletAddr, _refundValue);
    }

    ///////////////////////////////////////////////////////

    function f_d2_1(address _b, address _c) public view returns (uint) {
        stepIdx = 100;

        address _this = address(this);
        address _from = msg.sender;

        ContractB ctB = ContractB(_b);
        stepIdx = ctB.f_d1_1.gas(100000)(_c);

        emit Transfer(_from, _this, stepIdx, "@contractA f_d2_1, stepIdx = 100, CTA - CTB");

        return stepIdx;
    }

    function f_d2_2(address _b, address _c) public {
        stepIdx = 200;

        address _this = address(this);
        address _from = msg.sender;

        ContractB ctB = ContractB(_b);
        ctB.f_d1_2.gas(100000)(_c);

        emit Transfer(_from, _this, stepIdx, "@contractA f_d2_2, stepIdx = 200, CTA - CTB");
    }

    function f_d2_3(address _b, address _c, address _walletAddr, uint _value1, uint _value2, uint _refundValue) public payable returns (uint){
        stepIdx = 300;

        address _this = address(this);
        address _from = msg.sender;

        _b.transfer(_value1); 

        emit Transfer(_from, _this, _value1, "@contractA f_d2_3, stepIdx = 300, CTA - CTB");

        ContractB contractB;
        contractB = ContractB(_b);
        contractB.setValue.value(1000000)(_c, _walletAddr, _value2, _refundValue);
        
        stepIdx = 2;
        return(stepIdx);

    }
}

