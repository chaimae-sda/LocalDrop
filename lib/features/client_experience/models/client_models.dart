class FlashOffer {
  const FlashOffer({
    required this.id,
    required this.name,
    required this.category,
    required this.shop,
    required this.address,
    required this.imageUrl,
    required this.originalPrice,
    required this.price,
    required this.discount,
    required this.distance,
    required this.available,
    required this.description,
  });

  final String id;
  final String name;
  final String category;
  final String shop;
  final String address;
  final String imageUrl;
  final double originalPrice;
  final double price;
  final int discount;
  final double distance;
  final int available;
  final String description;
}

class LocalShop {
  const LocalShop({
    required this.name,
    required this.category,
    required this.address,
    required this.hours,
    required this.distance,
    required this.description,
  });

  final String name;
  final String category;
  final String address;
  final String hours;
  final double distance;
  final String description;
}

class ClientOrder {
  const ClientOrder({
    required this.id,
    required this.offerName,
    required this.shop,
    required this.date,
    required this.amount,
    required this.status,
    required this.pickup,
  });

  final String id;
  final String offerName;
  final String shop;
  final String date;
  final double amount;
  final String status;
  final String pickup;
}

class ClientNotification {
  const ClientNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.offerId,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final String? offerId;
}
