import '../models/client_models.dart';

const offers = <FlashOffer>[
  FlashOffer(
    id: 'boulangerie',
    name: 'Panier surprise boulangerie',
    category: 'Boulangerie',
    shop: 'Boulangerie du Pont',
    address: '18 rue du Pont',
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff',
    originalPrice: 18,
    price: 6.90,
    discount: 62,
    distance: 0.4,
    available: 5,
    description:
        'Pain de campagne, viennoiseries et douceurs du jour préparés dans notre boulangerie.',
  ),
  FlashOffer(
    id: 'bio',
    name: 'Panier fruits & légumes',
    category: 'Bio',
    shop: 'Marché Bio Central',
    address: '4 place du Marché',
    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
    originalPrice: 24,
    price: 8.50,
    discount: 65,
    distance: 0.8,
    available: 3,
    description:
        'Un assortiment de fruits et légumes de saison, sélectionnés le matin même.',
  ),
  FlashOffer(
    id: 'epicerie',
    name: 'Box douceurs & boissons',
    category: 'Épicerie',
    shop: 'Épicerie Les Délices',
    address: '31 avenue des Lilas',
    imageUrl: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a',
    originalPrice: 20,
    price: 7.20,
    discount: 64,
    distance: 1.2,
    available: 8,
    description:
        'Biscuits artisanaux, confitures et boissons fraîches dans une box surprise.',
  ),
  FlashOffer(
    id: 'restaurant',
    name: 'Menu du soir',
    category: 'Restaurant',
    shop: 'La Table du Coin',
    address: '9 rue des Cordiers',
    imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554',
    originalPrice: 21,
    price: 9.90,
    discount: 53,
    distance: 1.6,
    available: 4,
    description:
        'Une entrée et un plat du jour proposés par notre cuisine locale.',
  ),
];

const shops = <LocalShop>[
  LocalShop(
    name: 'Boulangerie du Pont',
    category: 'Boulangerie',
    address: '18 rue du Pont, Paris',
    hours: 'Lundi - samedi : 7h - 20h',
    distance: 0.4,
    description:
        'Une boulangerie de quartier qui fabrique ses pains et viennoiseries chaque matin.',
  ),
  LocalShop(
    name: 'Marché Bio Central',
    category: 'Bio',
    address: '4 place du Marché, Paris',
    hours: 'Tous les jours : 8h - 19h',
    distance: 0.8,
    description:
        'Des fruits et légumes frais issus de producteurs partenaires locaux.',
  ),
  LocalShop(
    name: 'Épicerie Les Délices',
    category: 'Épicerie',
    address: '31 avenue des Lilas, Paris',
    hours: 'Du mardi au dimanche : 9h - 20h',
    distance: 1.2,
    description:
        'Épicerie conviviale proposant des produits locaux et gourmands.',
  ),
];

const orders = <ClientOrder>[
  ClientOrder(
    id: 'LD-2048',
    offerName: 'Panier surprise boulangerie',
    shop: 'Boulangerie du Pont',
    date: '23 novembre 2026',
    amount: 6.90,
    status: 'À retirer',
    pickup: 'Aujourd’hui, 18h00 - 19h30',
  ),
  ClientOrder(
    id: 'LD-1991',
    offerName: 'Panier fruits & légumes',
    shop: 'Marché Bio Central',
    date: '16 novembre 2026',
    amount: 8.50,
    status: 'Terminée',
    pickup: 'Retrait effectué à 17h20',
  ),
];

const notifications = <ClientNotification>[
  ClientNotification(
    id: 'n1',
    title: 'Nouvelle vente près de vous',
    message: 'Il reste 5 paniers chez Boulangerie du Pont.',
    time: 'À l’instant',
    offerId: 'boulangerie',
  ),
  ClientNotification(
    id: 'n2',
    title: 'Votre retrait approche',
    message: 'Retirez votre panier avant 19h30 aujourd’hui.',
    time: 'Il y a 25 min',
    offerId: null,
  ),
];
