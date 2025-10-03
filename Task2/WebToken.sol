// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
作业 1：ERC20 代币
任务：参考 openzeppelin-contracts/contracts/token/ERC20/IERC20.sol实现一个简单的 ERC20 代币合约。
只有合约提供者可以增发 token
discard 中没有说明其他合约地址 token 来源，因此都从 owner 中授权转移。
*/
contract WebToken {
    string name;
    string symbol;
    uint256 public totalSupply;
    address owner;

    mapping(address account => uint256) private balances;
    mapping(address account => mapping(address spender => uint256))
        private allowances;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    function mint(uint256 _amount) external ownerMint returns (bool) {
        totalSupply += _amount;
        balances[owner] += _amount;
        return true;
    }

    // balanceOf：查询账户余额。
    function balanceOf(address _address) external view returns (uint256) {
        return balances[_address];
    }

    // transfer：转账
    function transfer(address _to, uint256 _amount) external balanceEnough(balances[msg.sender],_amount) returns (bool) {
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        return true;
    }

    // 授权代币
    function approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) external returns (bool) {
        allowances[_owner][_spender] = _amount;
        return true;
    }

    // 授权外部合约转账
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external balanceEnough(balances[_from],_amount) returns (bool) {
        if (_from == address(0)) {
            revert invalidSender(address(0));
        }
        if (_to == address(0)) {
            revert invalidReceiver(address(0));
        }
        if(allowances[_from][_to] < _amount){
            revert insuffientAllowance(_from,_to);
        }

        balances[_from] -= _amount;
        balances[_to] += _amount;

        allowances[_from][_to] -= _amount;

        return true;
    }

    event eventTransfer(address _to, uint256 _amount);
    event eventApprove(address _owner, address _spender, uint256 _amount);

    error invalidApprover(address _address);
    error invalidSpender(address _address);

    error invalidSender(address _address);
    error invalidReceiver(address _address);
    error insuffientBalance(address _sender, uint256 _balance, uint256 _needed);
    error insuffientAllowance(address _owner, address _spender);
    error onlyOwnerCanMint();

    modifier ownerMint() {
        if (msg.sender != owner) {
            revert onlyOwnerCanMint();
        }
        _;
    }

    modifier balanceEnough(uint256 balance, uint256 target) {
        if (balance < target) {
            revert insuffientBalance(msg.sender, balance, target);
        }
        _;
    }
}
