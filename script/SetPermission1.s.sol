// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "forge-std/Script.sol";
import "../src/SetPermission1.sol";
import "@balancer/vault/IAuthorizer.sol";
import "@balancer/liquidity-mining/IAuthorizerAdaptor.sol";
import "@balancer/liquidity-mining/IBalancerTokenAdmin.sol";
import "@balancer/liquidity-mining/IGaugeController.sol";

interface IAuthorizerFull is IAuthorizerAdaptor {
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function getRoleMemberCount(bytes32) external view returns (uint256);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
}

contract SetPermission1Script is Script {
    IAuthorizerFull authorizer = IAuthorizerFull(0x7324289860150109dD0a8ee307B875d0868CFCb4);

    IAuthorizerAdaptor authorizerAdaptor = IAuthorizerAdaptor(0xF657FC1ee31F3643924b46a4BB3f939678972869);
    IBalancerTokenAdmin balancerTokenAdmin = IBalancerTokenAdmin(0x95c3f6B1001Fc46DcA5bc4041e74a4E5bF7D580f);
    IGaugeController gaugeController = IGaugeController(0x2B69fc5903B3a9eFeBF88ff23A90B229A9791674);

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        SetPermission1 fixContract = new SetPermission1(authorizerAdaptor, balancerTokenAdmin, gaugeController);
        bytes32 DEFAULT_ADMIN_ROLE = authorizer.DEFAULT_ADMIN_ROLE();
        authorizer.grantRole(DEFAULT_ADMIN_ROLE, address(fixContract));
        fixContract.setPermission();
        authorizer.revokeRole(DEFAULT_ADMIN_ROLE, address(fixContract));
        vm.stopBroadcast();
    }
}
