pragma solidity ^0.4.24;
//import "/home/loyal/work/git/qtum-test-suite/s5__contract-call-contract/cicalljs-cli/cicall-solidity/ContractC.sol";
import "./ContractC.sol";
contract ContractB{

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

    function setValue(address _addr, address _addr2, uint _value, uint _refundValue) public payable{
        address _this = address(this);
        address _from = msg.sender;

        _addr.transfer(_value);

        emit Transfer(_this, _addr, _value, "@Call transferCCC, CTB -> CTC  ");

        //1.
        //_addr.call(bytes4(sha3("setValue(uint, uint)")), _value, _refundValue);
        //2.
        //bytes memory payload = abi.encodeWithSignature("setValue(uint, uint)", _value, _refundValue);
        //_addr.call(payload);
        //3.
        ContractC ctC;
        ctC = ContractC(_addr);
        ctC.setValue.value(400000)(_addr2, _refundValue);
        //4.
        //_addr.call(bytes4(keccak256("setValue(uint, uint)")), _value, _refundValue);
    }

    function checkDebug() public view returns (uint){
        return stepIdx;
    }

    function f1() public view returns (uint) {
        stepIdx = 11;

        address _this = address(this);
        address _from = msg.sender;

        emit Transfer(_from, _this, stepIdx, "@contractB f1, stepIdx = 11");

        return stepIdx;
    }

    function f2() public {
        stepIdx = 22;

        address _this = address(this);
        address _from = msg.sender;

        emit Transfer(_from, _this, stepIdx, "@contractB f2, stepIdx = 22");
    }

    function f3(address _walletAddr, uint _refundValue) public payable {
        stepIdx = 33;

        address _this = address(this);
        address _from = msg.sender;

        _walletAddr.transfer(_refundValue);

        emit Transfer(_from, _this, stepIdx, "@contractB f3, stepIdx = 33 ");

    }

    ///////////////////////

    function f_d1_1(address _c) public view returns (uint) {
        stepIdx = 110;

        address _this = address(this);
        address _from = msg.sender;

        ContractC ctC = ContractC(_c);
        stepIdx = ctC.f1.gas(100000)();

        emit Transfer(_from, _this, stepIdx, "@contractB f_d1_1, stepIdx = 110 ");

        return stepIdx;
    }

    function f_d1_2(address _c) public {
        stepIdx = 220;

        address _this = address(this);
        address _from = msg.sender;

        ContractC ctC = ContractC(_c);
        ctC.f2.gas(100000)();

        emit Transfer(_from, _this, stepIdx, "@contractB f_d1_2, stepIdx = 220  ");
    }

    function f_d1_3(address _c, address _walletAddr, uint _value, uint _refundValue) public payable{
        stepIdx = 330;

        address _this = address(this);
        address _from = msg.sender;

        _c.transfer(_value);
        emit Transfer(_this, _c, _value, "@contractB f_d1_3, stepIdx = 330, CTB -> CTC  ");

        ContractC ctC;
        ctC = ContractC(_c);
        ctC.setValue.value(40000)(_walletAddr, _refundValue);

    }
}

