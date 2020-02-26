pragma solidity ^0.6.1;


contract Escrow {
    uint balance;
    address payable public buyer;
    address payable public seller;
    address payable private arbiter;
    uint private start;
    bool buyerOk;
    bool sellerOk;

    function escrower(address payable buyer_address, address payable seller_address) public {
        buyer = payable (buyer_address);
        seller = seller_address;
        arbiter = msg.sender;
        start = now;
    }
    
    function accept() public {
        if (msg.sender == buyer) {
            buyerOk = true;
        } else if (msg.sender == seller) {
            sellerOk = true;
        }

        if (buyerOk && sellerOk) {
            payBalance();
        } else if (buyerOk && !sellerOk && now > start + 30 days) {
            selfdestruct(buyer);
        }
    }

    function deposit () public payable {
        if (msg.sender == buyer) {
            balance += msg.value;
        }
    }

    function cancel() public {
        if (msg.sender == buyer) {
            buyerOk = false;
        } else if (msg.sender == seller) {
            sellerOk = false;
        }
        
        if (!buyerOk && !sellerOk) {
            selfdestruct(buyer);
        }
    }
    
    function kill() public {
        if (msg.sender == arbiter) {
            selfdestruct(buyer);
        }
    }

    function payBalance() private {
        arbiter.transfer(balance / 100);
        if (seller.transfer(balance)) {
            balance = 0;
        } else {
            revert();
        }
    }
}