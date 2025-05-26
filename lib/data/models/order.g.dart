// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: (json['id'] as num).toInt(),
      totalPrice: json['total_price'] as String,
      orderStatus: json['order_status'] as String,
      created: json['created'] as String,
      payments: (json['payments'] as List<dynamic>)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
      shipments: (json['shipments'] as List<dynamic>)
          .map((e) => Shipment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'total_price': instance.totalPrice,
      'order_status': instance.orderStatus,
      'created': instance.created,
      'payments': instance.payments,
      'shipments': instance.shipments,
    };

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      amount: json['amount'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'amount': instance.amount,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'order': instance.order,
    };

Shipment _$ShipmentFromJson(Map<String, dynamic> json) => Shipment(
      shipmentCode: json['shipment_code'] as String,
      shipmentType: json['shipment_type'] as String,
      size: json['size'] as String,
      weight: (json['weight'] as num).toInt(),
      note: json['note'] as String,
      receiverName: json['receiver_name'] as String,
      receiverPhoneNumber: json['receiver_phone_number'] as String,
      receiverAddress: json['receiver_address'] as String,
      receiverProvince: json['receiver_province'] as String,
      receiverDistrict: json['receiver_district'] as String,
      receiverWard: json['receiver_ward'] as String,
      receiverLongitude: json['receiver_longitude'] as String,
      receiverLatitude: json['receiver_latitude'] as String,
      senderName: json['sender_name'] as String,
      senderAddress: json['sender_address'] as String,
      senderProvince: json['sender_province'] as String,
      senderDistrict: json['sender_district'] as String,
      senderWard: json['sender_ward'] as String,
      senderLongitude: json['sender_longitude'] as String,
      senderLatitude: json['sender_latitude'] as String,
    );

Map<String, dynamic> _$ShipmentToJson(Shipment instance) => <String, dynamic>{
      'shipment_code': instance.shipmentCode,
      'shipment_type': instance.shipmentType,
      'size': instance.size,
      'weight': instance.weight,
      'note': instance.note,
      'receiver_name': instance.receiverName,
      'receiver_phone_number': instance.receiverPhoneNumber,
      'receiver_address': instance.receiverAddress,
      'receiver_province': instance.receiverProvince,
      'receiver_district': instance.receiverDistrict,
      'receiver_ward': instance.receiverWard,
      'receiver_longitude': instance.receiverLongitude,
      'receiver_latitude': instance.receiverLatitude,
      'sender_name': instance.senderName,
      'sender_address': instance.senderAddress,
      'sender_province': instance.senderProvince,
      'sender_district': instance.senderDistrict,
      'sender_ward': instance.senderWard,
      'sender_longitude': instance.senderLongitude,
      'sender_latitude': instance.senderLatitude,
    };
