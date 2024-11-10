// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./AuthenticatedProxy.sol";

contract ProxyRegistry is Ownable {
    // public으로 구성되어 있으면 인터페이스에서 함수로 구현될 수 있다
    mapping(address => bool) public contracts;

    // 유저가 등록한 컨트랙트
    mapping(address => address) public proxies;

    constructor() Ownable(msg.sender) {}

    // 특정 컨트랙트에 Proxy Contract에 대한 제어권 부여
    // Contract Owner만 호출 가능
    function grantAuthentication(address addr) external onlyOwner {
        // 등록이 안되어 있을 때 가능
        require(!contracts[addr], "Already registered");
        contracts[addr] = true;
    }

    // 특정 컨트랙트에 대한 Proxy Contract에 대한 제어권 부여되 것을 해제함
    // Contract Owner만 호출 가능
    function revokeAuthentication(address addr) external onlyOwner {
        // 이미 등록이 되어 있을 때 가능
        require(contracts[addr], "Not registered");
        delete contracts[addr];
    }

    // 유저는 이 함수를 통해 각 지갑마다 하나의 Proxy Contract 생성 가능
    function registerProxy() external returns (AuthenticatedProxy) {
        // 각 지갑당 하나의 proxy 생성 가능
        require(proxies[msg.sender] == address(0), "Already registered");
        AuthenticatedProxy proxy = new AuthenticatedProxy(msg.sender);
        proxies[msg.sender] = address(proxy);
        return proxy;
    }
}
