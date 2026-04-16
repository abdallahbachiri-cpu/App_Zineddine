import 'package:cuisinous/generated/l10n.dart';
import 'package:flutter/material.dart';

enum OrderStatus { pending, confirmed, cancelled, completed, ready }

extension OrderStatusExtension on OrderStatus {
  String translate(BuildContext context) {
    switch (this) {
      case OrderStatus.pending:
        return S.of(context).orderStatusPending;
      case OrderStatus.confirmed:
        return S.of(context).orderStatusConfirmed;
      case OrderStatus.cancelled:
        return S.of(context).orderStatusCancelled;
      case OrderStatus.completed:
        return S.of(context).orderStatusCompleted;
      case OrderStatus.ready:
        return S.of(context).orderStatusReady;
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

enum OrderPaymentStatus {
  pending,
  processing,
  paid,
  failed,
  refund_requested,
  refunded,
  refund_failed,
}

extension OrderPaymentStatusExtension on OrderPaymentStatus {
  String translate(BuildContext context) {
    switch (this) {
      case OrderPaymentStatus.pending:
        return S.of(context).orderStatusPending;
      case OrderPaymentStatus.processing:
        return S.of(context).orderStatusProcessing;
      case OrderPaymentStatus.paid:
        return S.of(context).orderStatusPaid;
      case OrderPaymentStatus.failed:
        return S.of(context).orderStatusFailed;
      case OrderPaymentStatus.refund_requested:
        return S.of(context).orderStatusRefundRequested;
      case OrderPaymentStatus.refunded:
        return S.of(context).orderStatusRefunded;
      case OrderPaymentStatus.refund_failed:
        return S.of(context).orderStatusRefundFailed;
    }
  }

  Color get color {
    switch (this) {
      case OrderPaymentStatus.paid:
      case OrderPaymentStatus.refunded:
        return Colors.green;
      case OrderPaymentStatus.pending:
      case OrderPaymentStatus.processing:
      case OrderPaymentStatus.refund_requested:
        return Colors.orange;
      case OrderPaymentStatus.failed:
      case OrderPaymentStatus.refund_failed:
        return Colors.red;
    }
  }
}

enum OrderDeliveryStatus { pending, transit, delivered }

extension OrderDeliveryStatusExtension on OrderDeliveryStatus {
  String translate(BuildContext context) {
    switch (this) {
      case OrderDeliveryStatus.pending:
        return S.of(context).orderStatusPending;
      case OrderDeliveryStatus.transit:
        return S.of(context).orderStatusInTransit;
      case OrderDeliveryStatus.delivered:
        return S.of(context).orderStatusDelivered;
    }
  }

  Color get color {
    switch (this) {
      case OrderDeliveryStatus.delivered:
        return Colors.green;
      case OrderDeliveryStatus.transit:
        return Colors.blue;
      case OrderDeliveryStatus.pending:
        return Colors.orange;
    }
  }
}

OrderStatus parseOrderStatus(String status) {
  final normalized = status.toLowerCase();

  if (normalized == 'delivered') {
    return OrderStatus.completed;
  }

  return OrderStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == normalized,
    orElse: () => OrderStatus.pending,
  );
}

OrderPaymentStatus parseOrderPaymentStatus(String status) {
  final normalized = status.toLowerCase();
  return OrderPaymentStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == normalized,
    orElse: () => OrderPaymentStatus.pending,
  );
}

OrderDeliveryStatus parseOrderDeliveryStatus(String status) {
  final normalized = status.toLowerCase();
  return OrderDeliveryStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == normalized,
    orElse: () => OrderDeliveryStatus.pending,
  );
}
