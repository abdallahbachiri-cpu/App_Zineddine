<?php

namespace App\Service\Order;

use App\DTO\OrderDetailDTO;
use App\DTO\OrderDTO;
use App\Entity\Order;
use App\Service\FoodStore\FoodStoreMapper;
use App\Service\Location\LocationMapper;
use App\Service\Order\OrderDish\OrderDishMapper;
use App\Service\User\UserMapper;

class OrderMapper
{
    public function __construct(
        private UserMapper $userMapper,
        private FoodStoreMapper $foodStoreMapper,
        private LocationMapper $locationMapper,
        private OrderDishMapper $orderDishMapper,
    ) {}

    public function mapToDTO(Order $order, bool $isSeller = false): OrderDTO
    {
        return new OrderDTO(
            id: $order->getId(),
            cartId: $order->getCart()->getId(),
            buyerId: $order->getBuyer()->getId(),
            buyerFullName: $order->getBuyer()->getFullName(),
            storeId: $order->getStore()->getId(),
            storeName: $order->getStore()->getName(),
            orderNumber: $order->getOrderNumber(),
            confirmationCode: $isSeller ? null : $order->getConfirmationCode(),
            status: $order->getStatus()->value,
            paymentStatus: $order->getPaymentStatus()->value,
            deliveryStatus: $order->getDeliveryStatus()->value,
            deliveryMethod: $order->getDeliveryMethod()->value,
            totalPrice: $order->getTotalPrice(),
            taxTotal: $order->getTaxTotal(),
            grossTotal: $order->getGrossTotal(),
            appliedTaxes: $order->getAppliedTaxes(),
            tipAmount: $order->getTipAmount(),
            tipPaymentStatus: $order->getTipPaymentStatus()?->value,
            createdAt: $order->getCreatedAt(),
            updatedAt: $order->getUpdatedAt()
        );
    }

    public function mapToDetailDTO(Order $order, bool $isSeller = false): OrderDetailDTO
    {
        return new OrderDetailDTO(
            id: $order->getId(),
            cartId: $order->getCart()->getId(),
            buyer: $this->userMapper->mapToDTO($order->getBuyer()),
            store: $this->foodStoreMapper->mapToDTO($order->getStore()),
            location: $this->locationMapper->mapToDTO($order->getLocation()),
            orderNumber: $order->getOrderNumber(),
            confirmationCode: $isSeller ? null : $order->getConfirmationCode(),
            status: $order->getStatus()->value,
            paymentStatus: $order->getPaymentStatus()->value,
            tipPaymentStatus: $order->getTipPaymentStatus()?->value,
            deliveryStatus: $order->getDeliveryStatus()->value,
            deliveryMethod: $order->getDeliveryMethod()->value,
            totalPrice: $order->getTotalPrice(),
            taxTotal: $order->getTaxTotal(),
            grossTotal: $order->getGrossTotal(),
            appliedTaxes: $order->getAppliedTaxes(),
            tipAmount: $order->getTipAmount(),
            createdAt: $order->getCreatedAt(),
            updatedAt: $order->getUpdatedAt(),
            dishes: $this->orderDishMapper->mapToDTOs($order->getDishes()->toArray()),
            buyerNote: $order->getBuyerNote()
        );
    }

    public function mapToDTOs(array $orders, bool $isSeller = false): array
    {
        return array_map(
            fn(Order $order) => $this->mapToDTO($order, $isSeller),
            $orders
        );
    }

    public function mapToDetailDTOs(array $orders, bool $isSeller = false): array
    {
        return array_map(
            fn(Order $order) => $this->mapToDetailDTO($order, $isSeller),
            $orders
        );
    }
}
