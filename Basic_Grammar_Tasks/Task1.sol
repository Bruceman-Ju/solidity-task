// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
创建一个名为Voting的合约，包含以下功能：
一个mapping来存储候选人的得票数
一个vote函数，允许用户投票给某个候选人
一个getVotes函数，返回某个候选人的得票数
一个resetVotes函数，重置所有候选人的得票数
*/

contract Voting {
    mapping(string => uint) private votes;

    string[] private candidates;

    constructor() {
        votes[unicode"张学友"] = 0;
        candidates.push(unicode"张学友");

        votes[unicode"黎明"] = 0;
        candidates.push(unicode"黎明");

        votes[unicode"郭富城"] = 0;
        candidates.push(unicode"郭富城");

        votes[unicode"刘德华"] = 0;
        candidates.push(unicode"刘德华");
    }

    function vote(string memory candidate) external returns (bool) {
        // 检查候选人是否存在
        require(_isValidCandidate(candidate), unicode"候选人不存在");
        // 投票
        votes[candidate] += 1;
        return true;
    }

    function getVotes(string memory candidate) external view returns (uint) {
        // 检查候选人是否存在
        require(_isValidCandidate(candidate), unicode"候选人不存在");
        return votes[candidate];
    }

    function resetVotes() external {
        for (uint i = 0; i < candidates.length; i++) {
            votes[candidates[i]] = 0;
        }
    }

    function _isValidCandidate(
        string memory candidate
    ) private view returns (bool) {
        for (uint i = 0; i < candidates.length; i++) {
            if (
                keccak256(bytes(candidates[i])) == keccak256(bytes(candidate))
            ) {
                return true;
            }
        }
        return false;
    }
}
