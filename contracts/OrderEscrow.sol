// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.12 <0.9.0;

contract OrderEscrow {

  enum OrderStatus {
    Created,
    Paid
  }

  struct Order {
    address buyer;
    address seller;
    uint256 amount;
    OrderStatus status;
  }

  Order[] orders;

  event OrderCreated (uint256 indexed key, uint256 amount);

  function createOrder (address _buyer, address _seller, uint256 _amount) external {
    Order memory order = Order(_buyer, _seller, _amount, OrderStatus.Created);
    orders.push(order);
    emit OrderCreated(orders.length - 1, 1 ether);
  }

  function makePayement (uint256 key) external payable {
    Order storage order = orders[key];
    require(order.buyer == msg.sender);
    require(order.amount == msg.value);
    require(order.status == OrderStatus.Created);

    order.status = OrderStatus.Paid;
  }

}