pragma solidity ^0.4.4;
import 'builder/Builder.sol';
import './Escrow.sol';

/**
 * @title BuilderEscrow contract
 */
contract BuilderEscrow is Builder {
	
    address[] public contracts;
    uint public contractsLength;
	
    address public bank;
    address public logistics;

    modifier onlyBank { if (msg.sender != bank) throw; _; }
	
    function setBank(address _bank) onlyOwner
    { bank = _bank; }
	
    function setLogistics(address _logistics) onlyOwner
    { logistics = _logistics; }
	
    function addContract(address _contract) private {
		contracts.push(_contract);
		contractsLength++;
    }
	
	function removeContract(address _contract) onlyBank {
        for (uint i = 0; i < contracts.length; i++){
            if (contracts[i] == _contract) {
				for (uint i2 = i; i2 < contracts.length-1; i2++){
					contracts[i2] = contracts[i2+1];
				}
				delete contracts[contracts.length-1];
				contracts.length--;
				contractsLength--;
				break;
			}
        }
    }
	
    /**
     * @dev Run script creation contract
     * @param _seller is Seller address
     * @param _buyer is Buyer address
     * @param _client is a contract destination address (zero for sender)
     * @return address new contract
     */
    function create(address _seller, address _buyer, address _client) payable returns (address) {
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
 
		var inst = new Escrow(_seller, _buyer, bank, logistics);
        getContractsOf[_client].push(inst);
		addContract(inst);
        Builded(_client, inst);
        inst.setOwner(_client);
        inst.setHammer(_client);
        return inst;
    }
}
