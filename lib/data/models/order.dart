import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final int id;
  @JsonKey(name: 'total_price')
  final String totalPrice;
  @JsonKey(name: 'order_status')
  final String orderStatus;
  final String created;
  final List<Payment> payments;
  final List<Shipment> shipments;

  Order({
    required this.id,
    required this.totalPrice,
    required this.orderStatus,
    required this.created,
    required this.payments,
    required this.shipments,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class Payment {
  final String amount;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  final int order;

  Payment({
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.order,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}

@JsonSerializable()
class Shipment {
  @JsonKey(name: 'shipment_code')
  final String shipmentCode;
  @JsonKey(name: 'shipment_type')
  final String shipmentType;
  final String size;
  final int weight;
  final String note;
  @JsonKey(name: 'receiver_name')
  final String receiverName;
  @JsonKey(name: 'receiver_phone_number')
  final String receiverPhoneNumber;
  @JsonKey(name: 'receiver_address')
  final String receiverAddress;
  @JsonKey(name: 'receiver_province')
  final String receiverProvince;
  @JsonKey(name: 'receiver_district')
  final String receiverDistrict;
  @JsonKey(name: 'receiver_ward')
  final String receiverWard;
  @JsonKey(name: 'receiver_longitude')
  final String receiverLongitude;
  @JsonKey(name: 'receiver_latitude')
  final String receiverLatitude;
  @JsonKey(name: 'sender_name')
  final String senderName;
  @JsonKey(name: 'sender_address')
  final String senderAddress;
  @JsonKey(name: 'sender_province')
  final String senderProvince;
  @JsonKey(name: 'sender_district')
  final String senderDistrict;
  @JsonKey(name: 'sender_ward')
  final String senderWard;
  @JsonKey(name: 'sender_longitude')
  final String senderLongitude;
  @JsonKey(name: 'sender_latitude')
  final String senderLatitude;

  Shipment({
    required this.shipmentCode,
    required this.shipmentType,
    required this.size,
    required this.weight,
    required this.note,
    required this.receiverName,
    required this.receiverPhoneNumber,
    required this.receiverAddress,
    required this.receiverProvince,
    required this.receiverDistrict,
    required this.receiverWard,
    required this.receiverLongitude,
    required this.receiverLatitude,
    required this.senderName,
    required this.senderAddress,
    required this.senderProvince,
    required this.senderDistrict,
    required this.senderWard,
    required this.senderLongitude,
    required this.senderLatitude,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) => _$ShipmentFromJson(json);
  Map<String, dynamic> toJson() => _$ShipmentToJson(this);
}