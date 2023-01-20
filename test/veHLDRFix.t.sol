// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "forge-std/Test.sol";
import "../src/veHLDRFix.sol";
import "@balancer/vault/IAuthorizer.sol";
import "@balancer/liquidity-mining/IAuthorizerAdaptor.sol";
import "@balancer/liquidity-mining/IBalancerTokenAdmin.sol";
import "@balancer/liquidity-mining/IGaugeController.sol";
import "@balancer/solidity-utils/openzeppelin/IERC20.sol";

interface IAuthorizerFull is IAuthorizerAdaptor {
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function getRoleMemberCount(bytes32) external view returns (uint256);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
}

interface IGaugeControllerFull is IGaugeController {
    function get_type_weight(int128) external view returns (uint256);
}

contract veHLDRFixTest is Test {
    veHLDRFix public fixContract;

    address authorizerAdaptor = 0xF657FC1ee31F3643924b46a4BB3f939678972869;
    address balancerTokenAdmin = 0x95c3f6B1001Fc46DcA5bc4041e74a4E5bF7D580f;
    IGaugeController gaugeController = IGaugeController(0x2B69fc5903B3a9eFeBF88ff23A90B229A9791674);
    address admin = 0xC32e0d89e25222ABb4d2d68755baBF5aA6648F15;
    IAuthorizerFull authorizer = IAuthorizerFull(0x7324289860150109dD0a8ee307B875d0868CFCb4);
    IGaugeControllerFull gaugeControllerFull = IGaugeControllerFull(address(gaugeController));
    address veHLDRGauge = 0x4d2c52eEeA7fc6fb9c6BdBa073310557367a2d1e;
    address hldrTokenholder = 0xEd8846912A5750962D9c9B978EA6E36c7ab39414;
    address hldr = 0x1aaee8F00D02fcdb10cF1F0caB651dC83318c7AA;


    function setUp() public {
        fixContract = new veHLDRFix(IAuthorizerAdaptor(authorizerAdaptor), IBalancerTokenAdmin(balancerTokenAdmin), gaugeController);
    }

    // function testAdminChange() public {
    //     vm.startPrank(admin);
    //     bytes32 DEFAULT_ADMIN_ROLE = authorizer.DEFAULT_ADMIN_ROLE();
    //     console.log(authorizer.getRoleMemberCount(DEFAULT_ADMIN_ROLE));
    //     authorizer.grantRole(DEFAULT_ADMIN_ROLE, address(fixContract));
    //     console.log(authorizer.getRoleMemberCount(DEFAULT_ADMIN_ROLE));
    //     authorizer.revokeRole(DEFAULT_ADMIN_ROLE, address(fixContract));
    //     console.log(authorizer.getRoleMemberCount(DEFAULT_ADMIN_ROLE));
    // }

    function testVeHLDRFix() public {
        // Do change
        vm.startPrank(admin);
        // bytes32 DEFAULT_ADMIN_ROLE = authorizer.DEFAULT_ADMIN_ROLE();
        // authorizer.grantRole(DEFAULT_ADMIN_ROLE, address(fixContract));
        // fixContract.performFirstStage();
        // authorizer.revokeRole(DEFAULT_ADMIN_ROLE, address(fixContract));

        // Confirm change
        assertEq(gaugeControllerFull.get_type_weight(0), 0);
        assertEq(gaugeControllerFull.get_type_weight(1), 1);
        assertEq(gaugeControllerFull.get_type_weight(2), 1);

        console.log(gaugeControllerFull.gauge_relative_weight(veHLDRGauge, block.timestamp));
        vm.warp(block.timestamp + 1 weeks);
        console.log(gaugeControllerFull.gauge_relative_weight(veHLDRGauge, block.timestamp));

        // Checkpoint
        console.log(IERC20(hldr).balanceOf(hldrTokenholder));
        IAuthorizerAdaptor(authorizerAdaptor).performAction(veHLDRGauge, abi.encodePacked(bytes4(0xc2c4c5c1)));
        console.log(IERC20(hldr).balanceOf(hldrTokenholder));

        vm.warp(block.timestamp + 1 weeks);
        console.log(gaugeControllerFull.gauge_relative_weight(veHLDRGauge, block.timestamp));
        IAuthorizerAdaptor(authorizerAdaptor).performAction(veHLDRGauge, abi.encodePacked(bytes4(0xc2c4c5c1)));
        console.log(IERC20(hldr).balanceOf(hldrTokenholder));
    }
}
