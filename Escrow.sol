pragma solidity ^0.4.4;
import 'common/Owned.sol';

contract Escrow is Owned {
	
	/* Parties to a contract */
    address public seller;
    address public buyer;
    address public bank;
    address public logistics;
	
	/* Product info */
    string public productName;
    uint public productPrice;
    uint public productQuantity;
    uint public productTotalAmount;
	
    uint public status;
	string public deliveryAddress;
	string public trackNum;
    string public instructionPay;
	
    /* Contract events */
    event Created(address indexed sender);   // 1 - договор создан
    event Signed(address indexed sender);    // 2 - покупатель подписал
    event Payed(address indexed sender);     // 3 - товар оплачен
    event Sent(address indexed sender, string trackNum); // 4 - товар отправлен
    event Received(address indexed sender);  // 5 - товар получен
    event Completed(address indexed sender); // 6 - договор выполнен
	
	/* Modifiers functions */
    modifier onlySeller { if (msg.sender != seller) throw; _; }
    modifier onlyBuyer { if (msg.sender != buyer) throw; _; }
    modifier onlyBank { if (msg.sender != bank) throw; _; }
    modifier onlyLogistics { if (msg.sender != logistics) throw; _; }
 
    /**
     * @dev contract constructor
     * @param _seller is Seller address
     * @param _buyer is Buyer address
     * @param _bank is a Bank address
     * @param _logistics is Logistics address
     */
    function Escrow(address _seller, address _buyer, address _bank, address _logistics) {
        seller = _seller;
        buyer = _buyer;
        bank = _bank;
        logistics = _logistics;
    }
    
	/**
     * @dev Set the product info
     * @param _productName is name
     * @param _productPrice is price
     * @param _productQuantity is quantity
     */
    function setProduct(string _productName, uint _productPrice, uint _productQuantity) onlySeller {
        if (status != 0) throw;
		productName = _productName;
		productPrice = _productPrice;
		productQuantity = _productQuantity;
		productTotalAmount = productPrice * productQuantity;
		status = 1;
		Created(seller);
	}
    
	/**
     * @dev Set instruction pay
     * @param _instruction text description
     */
    function setInstructionPay(string _instruction) onlyBank {
		instructionPay = _instruction;
	}
	
    /**
     * @dev Signing of the contract by buyer 
     * @param _deliveryAddress delivery address
     */
    function sign(string _deliveryAddress) onlyBuyer {
		deliveryAddress = _deliveryAddress;
		status = 2;
		Signed(buyer);
	}
	
    /**
     * @dev Confirmation of payment by bank
     */
    function payment() onlyBank {
        if (status != 2) throw;
		status = 3;
		Payed(bank);
	}
    
	/**
     * @dev Set track number
     * @param _trackNum track number
     */
    function setTrackNum(string _trackNum) onlySeller {
        if (status != 3) throw;
		trackNum = _trackNum;
		status = 4;
		Sent(seller, trackNum);
	}
    
	/**
     * @dev Confirmation of receipt of parcels
     */
    function received() onlyLogistics {
        if (status != 4) throw;
		status = 5;
		Received(logistics);
	}
	
    /**
     * @dev Contract is completed
     */
    function complete() onlyBank {
        if (status != 5) throw;
		status = 6;
		Completed(bank);
	}
}
