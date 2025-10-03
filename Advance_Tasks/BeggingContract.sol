// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
编写一个讨饭合约
任务目标
使用 Solidity 编写一个合约，允许用户向合约地址发送以太币。
记录每个捐赠者的地址和捐赠金额。
允许合约所有者提取所有捐赠的资金。
*/
contract BeggingContract {
    mapping(address => uint256) donatorToAmount;

    mapping(address => address) top3Donators;

    address owner;

    uint256 deployTimestamp;
    uint256 lockTime;

    constructor(uint256 _lockTime) {
        owner = msg.sender;
        top3Donators[msg.sender] = address(0);
        deployTimestamp = block.timestamp;
        lockTime = _lockTime;
    }

    function donate() external payable onlyNotOwner {
        require(block.timestamp < deployTimestamp + lockTime,"You can't donate because out of time.");

        if (donatorToAmount[msg.sender] == 0) {
            donatorToAmount[msg.sender] = msg.value;
        } else {
            donatorToAmount[msg.sender] += msg.value;
        }

        // todo
        // setTop3Donators();

        emit DonationEvent(msg.sender, msg.value);
    }

    function withdraw() external payable onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getDonation(address _address) external view returns (uint256) {
        return donatorToAmount[_address];
    }

    function getLinkedList(address _address) external view returns(address){
        return top3Donators[_address];
    }

    // 获取捐赠排行榜前三
    function getRangeListTop3()
        external
        view
        returns (address[3] memory _addresses, uint256[3] memory _values)
    {
        address current = top3Donators[owner];
        for (uint8 i = 0; i < 3 && current != address(0); i++) {
            _addresses[i] = current;
            _values[i] = donatorToAmount[current];
            current = top3Donators[current];
        }
    }

    /*
        捐赠的时候筛选出前三位
        以 owner 为起点，链表形式筛选出前三位
    */ 
    function setTop3Donators() private {

        if(top3Donators[owner] == address(0)){
            top3Donators[owner] = msg.sender;
            top3Donators[msg.sender] = address(0);
        }

        address preCurrent = owner;
        address current = top3Donators[preCurrent];

        // 排序
        while (current != address(0)) {
            if (donatorToAmount[current] <= msg.value) {
                top3Donators[preCurrent] = msg.sender;
                top3Donators[msg.sender] = current;
                break;
            }
            preCurrent = top3Donators[preCurrent];
        }
        // 删除多余元素
        removeSurplus();
    }

    // 删除多余元素
    function removeSurplus() private {
        address preCurrent = owner;
        address current = top3Donators[preCurrent];

        uint8 tag = 0;
        while (current != address(0)) {
            if (tag > 2) {
                current = top3Donators[current];
                delete top3Donators[current];
            }
            tag++;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can withdraw.");
        _;
    }

    modifier onlyNotOwner() {
        require(msg.sender != owner, "Contract owner can't donate");
        _;
    }

    event DonationEvent(address indexed _address, uint256 _amout);
}
