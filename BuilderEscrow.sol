pragma solidity ^0.4.4;
import 'builder/Builder.sol';
import './Escrow.sol';

/**
 * @title BuilderEscrow contract
 */
contract BuilderEscrow is Builder {
    /**
     * @dev Run script creation contract
     * @param _seller is Seller address
     * @param _buyer is Buyer address
     * @param _bank is a Bank address
     * @param _logistics is Logistics address
     * @param _client is a contract destination address (zero for sender)
     * @return address new contract
     */
    function create(address _seller, address _buyer, address _bank, address _logistics, address _client) payable returns (address) {
        if (buildingCostWei > 0 && beneficiary != 0) {
            // Too low value
            if (msg.value < buildingCostWei) throw;
            // Beneficiary send
            if (!beneficiary.send(buildingCostWei)) throw;
            // Refund
            if (msg.value > buildingCostWei) {
                if (!msg.sender.send(msg.value - buildingCostWei)) throw;
            }
        } else {
            // Refund all
            if (msg.value > 0) {
                if (!msg.sender.send(msg.value)) throw;
            }
        }

        if (_client == 0)
            _client = msg.sender;
 
		var inst = new Escrow(_seller, _buyer, _bank, _logistics);
        getContractsOf[_client].push(inst);
        Builded(_client, inst);
        inst.delegate(_client);
        return inst;
    }
}
