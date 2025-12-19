// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import {euint32} from "@fhevm/solidity/lib/FHE.sol";

// commercial lease with encrypted terms
contract CommercialLease is ZamaEthereumConfig {
    struct Lease {
        address landlord;
        address tenant;
        string propertyId;
        euint32 monthlyRent;     // encrypted
        uint256 startDate;
        uint256 endDate;
        bool active;
    }
    
    struct Payment {
        uint256 leaseId;
        euint32 amount;          // encrypted
        uint256 dueDate;
        bool paid;
    }
    
    mapping(uint256 => Lease) public leases;
    mapping(uint256 => Payment[]) public payments;
    uint256 public leaseCounter;
    
    event LeaseCreated(uint256 indexed leaseId, address landlord, address tenant);
    event PaymentMade(uint256 indexed leaseId, uint256 paymentIndex);
    
    function createLease(
        address tenant,
        string memory propertyId,
        euint32 encryptedMonthlyRent,
        uint256 duration
    ) external returns (uint256 leaseId) {
        leaseId = leaseCounter++;
        leases[leaseId] = Lease({
            landlord: msg.sender,
            tenant: tenant,
            propertyId: propertyId,
            monthlyRent: encryptedMonthlyRent,
            startDate: block.timestamp,
            endDate: block.timestamp + duration,
            active: true
        });
        
        emit LeaseCreated(leaseId, msg.sender, tenant);
    }
    
    function recordPayment(
        uint256 leaseId,
        euint32 encryptedAmount,
        uint256 dueDate
    ) external {
        Lease storage lease = leases[leaseId];
        require(lease.landlord == msg.sender, "Not landlord");
        
        payments[leaseId].push(Payment({
            leaseId: leaseId,
            amount: encryptedAmount,
            dueDate: dueDate,
            paid: false
        }));
    }
    
    function markPaid(uint256 leaseId, uint256 paymentIndex) external {
        Lease storage lease = leases[leaseId];
        require(lease.tenant == msg.sender, "Not tenant");
        
        payments[leaseId][paymentIndex].paid = true;
        emit PaymentMade(leaseId, paymentIndex);
    }
}

