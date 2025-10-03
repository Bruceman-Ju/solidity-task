// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
作业 1：ERC20 代币
任务：参考 openzeppelin-contracts/contracts/token/ERC20/IERC20.sol实现一个简单的 ERC20 代币合约。要求：
合约包含以下标准 ERC20 功能：
4. 使用 event 记录转账和授权操作。
5. 提供 mint 函数，允许合约所有者增发代币。

提示：
1. 使用 mapping 存储账户余额和授权信息。
2. 使用 event 定义 Transfer 和 Approval 事件。
3. 部署到 sepolia 测试网，导入到自己的钱包
*/
contract WebToken {
    
    string name;
    string symbol;
    uint8 decimals;
    uint256 totalSupply;
    address owner;

    mapping(address account => uint256) private balances;
    mapping(address account => mapping(address spender => uint256)) private allowances;


    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
    }

    function mint(uint256 _amount) external returns (bool) {
        require(msg.sender == owner, "Only owner can add token");
        totalSupply += _amount;
        return true;
    }
    // balanceOf：查询账户余额。
    function balanceOf(address _address) external view returns (uint256) {
        return balances[_address];
    }

    // transfer：转账
    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(balances[msg.sender] > _amount, "insuffient balance");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        return true;
    }

    // 授权代币
    function approve(address _owner,address _spender,uint256 _amount) external returns(bool){

        allowances[_owner][_spender] = _amount;
        return true;

    }

    // 授权外部合约转账
    function transferFrom(address _from, address _to, uint256 _amount) external returns(bool){

        require(balances[_from] >= _amount, "insuffient balance");
        require(allowances[_from][msg.sender] >= _amount, "insufficient allowance");
        balances[_from] -= _amount;
        balances[_to] += _amount;
        allowances[_from][msg.sender] -= _amount;
        return true;

    }
}
