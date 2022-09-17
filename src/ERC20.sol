// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP712.sol";

contract ERC20 is EIP712{
    mapping (address => uint256) private balances;
    mapping (address => mapping(address=>uint256)) private allowances;
    mapping(address => uint256) internal _nonces;
    uint256 private _totalSupply;
    address public owner;
    string private _name;
    string private _symbol;
    uint8 private _decimal;
    bool public paused = false;
    uint256 private nonce;
    bytes32 internal constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory _name, string memory _symbol)EIP712(_name,_version){
        _name = "DREAM";
        _symbol = "DRM";
        _decimal = 18;
        _totalSupply = 100 ether;
        balances[msg.sender] = 100 ether;
        owner = msg.sender;
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
       return _symbol;
    }   

    function decimals() public view returns (uint8) {
       return _decimal;
    }

    function totalSupply() public view returns (uint256) {
      return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
        require(balances[msg.sender] >= _value, "value exceeds balance");
        
        if(balances[msg.sender]>= _value && _value > 0){
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            return true;
        }
        else{
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
        require(balances[_from] >= _value, "value exceeds balance");

        if(balances[_from]>= _value){
            balances[_from] -= _value; 
            balances[_to] += _value;        
            allowances[_from][_to] -= _value; 
            return true;
        }else{
            return false;
        }
    } 

    function approve(address _to, uint256 _value) public returns (bool sucess) {
        allowances[msg.sender][_to]=_value;
        return true;
    }

    function allowance(address _from, address _to) public returns (uint256 _value) {
        return allowances[_from][_to];
    }
    function _mint(address _from, uint256 _value) public { 
        require(_from != address(0), "transfer from the zero address");
        balances[_from] += _value;
        _totalSupply += _value;  
    }
    function _burn(address _from, uint256 _value) public {       
        balances[_from] -= _value;
        _totalSupply -= _value;   
    }
    function pause() public returns(bool){
       require(msg.sender == owner,"you are not the owner");
        require(paused != false, "stop");
       return paused;
    }
    function nonces(address _address) public returns (uint256 _nonce) {
        return _nonces[_address];
    }
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(owner != address(0), "INVAID_ZERO_ADDRESS");
        uint256 currentNonce = _nonces[owner];
        require(deadline == 0 || block.timestamp <= deadline, "TOO_LATE");
        bytes32 structhash=keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _nonces[owner]++, deadline));
        bytes32 _hash=_toTypedDataHash(structhash);
        address recoverdAddress = ecrecover(_hash, v, r, s);
        require(recoverdAddress == owner, "INVALID_SIGNER");
        _nonces[owner] = currentNonce + 1;
        allowances[owner][spender] = value;
    }
} 
