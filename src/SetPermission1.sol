// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "@balancer/vault/IVault.sol";
import "@balancer/liquidity-mining/IAuthorizerAdaptor.sol";
import "@balancer/liquidity-mining/IGaugeAdder.sol";
import "@balancer/liquidity-mining/IGaugeController.sol";
import "@balancer/liquidity-mining/ILiquidityGauge.sol";
import "@balancer/liquidity-mining/IBalancerTokenAdmin.sol";
import "@balancer/liquidity-mining/IStakelessGauge.sol";
import "@balancer/standalone-utils/IBALTokenHolder.sol";

/**
 * @dev The currently deployed Authorizer has a different interface relative to the Authorizer in the monorepo
 * for granting/revoking roles(referred to as permissions in the new Authorizer) and so we require a one-off interface
 */
interface ICurrentAuthorizer is IAuthorizer {
    // solhint-disable-next-line func-name-mixedcase
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;
}

contract SetPermission1 {
    IVault private immutable _vault;
    IAuthorizerAdaptor private immutable _authorizerAdaptor;
    IGaugeController private immutable _gaugeController;
    IBalancerTokenAdmin private immutable _balancerTokenAdmin;

    enum DeploymentStage { PENDING, FIRST_STAGE_DONE }
    DeploymentStage private _currentDeploymentStage;

    constructor(
        IAuthorizerAdaptor authorizerAdaptor,
        IBalancerTokenAdmin balancerTokenAdmin,
        IGaugeController gaugeController
    ) {
        _currentDeploymentStage = DeploymentStage.PENDING;

        IVault vault = authorizerAdaptor.getVault();
        _vault = vault;
        _authorizerAdaptor = authorizerAdaptor;
        _balancerTokenAdmin = balancerTokenAdmin;
        _gaugeController = gaugeController;
    }

    /**
     * @notice Returns the Balancer Vault.
     */
    function getVault() public view returns (IVault) {
        return _vault;
    }

    /**
     * @notice Returns the Balancer Vault's current authorizer.
     */
    function getAuthorizer() public view returns (ICurrentAuthorizer) {
        return ICurrentAuthorizer(address(getVault().getAuthorizer()));
    }

    function getAuthorizerAdaptor() public view returns (IAuthorizerAdaptor) {
        return _authorizerAdaptor;
    }

    function getCurrentDeploymentStage() external view returns (DeploymentStage) {
        return _currentDeploymentStage;
    }

    function setPermission() external {
        // Check internal state
        require(_currentDeploymentStage == DeploymentStage.PENDING, "First step already performed");

        // Check external state: we need admin permission on the Authorizer
        ICurrentAuthorizer authorizer = getAuthorizer();
        require(authorizer.canPerform(bytes32(0), address(this), address(0)), "Not Authorizer admin");

        bytes32 killGaugeRole = _authorizerAdaptor.getActionId(ILiquidityGauge.killGauge.selector);
        authorizer.grantRole(killGaugeRole, 0x432Eb1f2730662AD1A9791Ed34CB2DBDf7001555);

        // Step 2: Renounce admin role over the Authorizer.
        authorizer.revokeRole(bytes32(0), address(this));
    }

    function _streq(string memory a, string memory b) private pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

}
