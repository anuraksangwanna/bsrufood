import 'dart:convert';

class ItemClas {
    int id;
    String shopId;
    String name;
    int price;
    int count; 
    bool status;
  ItemClas({
    this.id,
    this.shopId,
    this.name,
    this.price,
    this.count,
    this.status,
  });

  ItemClas copyWith({
    int id,
    String shopId,
    String name,
    int price,
    int count,
    bool status,
  }) {
    return ItemClas(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      price: price ?? this.price,
      count: count ?? this.count,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'shop_id': shopId,
      'name': name,
      'price': price,
      'count': count,
      'status': status ? 1 : 0,
    };
  }

  Map<String, dynamic> toMapnokey() {
    return {
      'shop_id': shopId,
      'name': name,
      'price': price,
      'count': count,
      'status': status ? 1 : 0,
    };
  }

  factory ItemClas.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return ItemClas(
      id: map['_id'],
      shopId: map['shop_id'],
      name: map['name'],
      price: map['price'],
      count: map['count'],
      status: map['status'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemClas.fromJson(String source) => ItemClas.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ItemClas(id: $id, shopId: $shopId, name: $name, price: $price, count: $count, status: $status)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is ItemClas &&
      o.id == id &&
      o.shopId == shopId &&
      o.name == name &&
      o.price == price &&
      o.count == count &&
      o.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      shopId.hashCode ^
      name.hashCode ^
      price.hashCode ^
      count.hashCode ^
      status.hashCode;
  }
}
