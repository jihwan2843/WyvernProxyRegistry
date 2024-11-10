// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 <0.9.0;

import "./interfaces/IProxyRegistry.sol";

contract AuthenticatedProxy {
    address public userAddress;
    address proxyRegistryAddress;
    bool public revoked;

    constructor(address _userAddress) {
        userAddress = _userAddress;
        proxyRegistryAddress = msg.sender;
    }

    // 유저 지갑만 호출할 수 있는 modifier
    modifier onlyUser() {
        require(msg.sender == userAddress);
        _;
    }

    function setRevoke() external onlyUser {
        require(!revoked);
        revoked = true;
    }

    function proxy(
        address dest,
        bytes calldata _calldata
    ) external returns (bool) {
        require(
            msg.sender == userAddress ||
                ((!revoked) &&
                    IProxyRegistry(proxyRegistryAddress).contracts(msg.sender))
        );
        bool result;
        (result, ) = dest.call(_calldata);
        return result;
    }
}
