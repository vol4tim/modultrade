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
	
	/* Card info */
    string public cardSeller;
    string public cardBuyer;
	
    uint public status;
	string public deliveryAddress;
	string public trackNum;
	
    /* Contract STATUSES */
	uint constant STATUS_NULL      = 0; // не определен
	uint constant STATUS_CREATED   = 1; // договор создан
	uint constant STATUS_SIGNED    = 2; // покупатель подписал
	uint constant STATUS_LOCKED    = 3; // средства на карте покупателя заблокированы
	uint constant STATUS_SENT      = 4; // товар отправлен
	uint constant STATUS_RECEIVED  = 5; // товар получен
	uint constant STATUS_COMPLETED = 6; // договор выполнен
	
    /* Contract events */
    event Created(address indexed sender);
    event Signed(address indexed sender);
    event Locked(address indexed sender);
    event Sent(address indexed sender, string trackNum);
    event Received(address indexed sender);
    event Completed(address indexed sender);
	
	/* Modifiers functions */
    modifier onlySeller { if (msg.sender != seller) throw; _; }
    modifier onlyBuyer { if (msg.sender != buyer) throw; _; }
    modifier onlyBank { if (msg.sender != bank) throw; _; }
    modifier onlyLogistics { if (msg.sender != logistics) throw; _; }
	modifier onlyStatus(uint current) { if (status != current) throw; _; }
	modifier fsmStatus(uint current, uint next) { if (status != current) throw; status = next; _; }
 
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
    function setProduct(string _productName, uint _productPrice, uint _productQuantity) onlySeller onlyStatus(STATUS_NULL) {
		productName = _productName;
		productPrice = _productPrice;
		productQuantity = _productQuantity;
		productTotalAmount = productPrice * productQuantity;
	}
    
	/**
     * @dev Set details for payment by seller
     * @param _cardSeller text description
     */
    function setCardSeller(string _cardSeller) onlySeller onlyStatus(STATUS_NULL) {
		cardSeller = _cardSeller;
	}
    
	/**
     * @dev Set details for locking funds
     * @param _cardBuyer text description
     */
    function setCardBuyer(string _cardBuyer) onlyBuyer onlyStatus(STATUS_CREATED) {
		cardBuyer = _cardBuyer;
	}
    
	/**
     * @dev Buyer the delivery address
     * @param _deliveryAddress delivery address
     */
    function setDeliveryAddress(string _deliveryAddress) onlyBuyer onlyStatus(STATUS_CREATED) {
		deliveryAddress = _deliveryAddress;
	}
	
    /**
     * @dev Signing of the contract by seller 
     */
    function signSeller() onlySeller fsmStatus(STATUS_NULL, STATUS_CREATED) {
		Created(seller);
	}
	
    /**
     * @dev Signing of the contract by buyer 
     */
    function signBuyer() onlyBuyer fsmStatus(STATUS_CREATED, STATUS_SIGNED) {
		Signed(buyer);
	}
	
    /**
	 * @dev Bank confirms that funds in card blocked
     * @dev Confirmation of payment by bank
     */
    function lockedFunds() onlyBank fsmStatus(STATUS_SIGNED, STATUS_LOCKED) {
		Locked(bank);
	}
    
	/**
     * @dev Set track number
     * @param _trackNum track number
     */
    function setTrackNum(string _trackNum) onlySeller fsmStatus(STATUS_LOCKED, STATUS_SENT) {
		trackNum = _trackNum;
		Sent(seller, trackNum);
	}
    
	/**
     * @dev Confirmation of receipt of parcels
     */
    function received() onlyLogistics fsmStatus(STATUS_SENT, STATUS_RECEIVED) {
		Received(logistics);
	}
	
    /**
     * @dev Contract is completed
     */
    function complete() onlyBank fsmStatus(STATUS_RECEIVED, STATUS_COMPLETED) {
		Completed(bank);
	}
}
