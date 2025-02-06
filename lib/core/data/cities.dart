import 'package:falnova/core/models/city_model.dart';

final List<City> turkishCities = [
  // Marmara Bölgesi
  const City(
      name: 'İstanbul',
      region: 'Marmara',
      latitude: '41.0082',
      longitude: '28.9784'),
  const City(
      name: 'Bursa',
      region: 'Marmara',
      latitude: '40.1885',
      longitude: '29.0610'),
  const City(
      name: 'Edirne',
      region: 'Marmara',
      latitude: '41.6771',
      longitude: '26.5557'),
  const City(
      name: 'Kırklareli',
      region: 'Marmara',
      latitude: '41.7355',
      longitude: '27.2244'),
  const City(
      name: 'Tekirdağ',
      region: 'Marmara',
      latitude: '40.9781',
      longitude: '27.5177'),
  const City(
      name: 'Balıkesir',
      region: 'Marmara',
      latitude: '39.6484',
      longitude: '27.8826'),
  const City(
      name: 'Çanakkale',
      region: 'Marmara',
      latitude: '40.1553',
      longitude: '26.4142'),
  const City(
      name: 'Kocaeli',
      region: 'Marmara',
      latitude: '40.8533',
      longitude: '29.8815'),
  const City(
      name: 'Sakarya',
      region: 'Marmara',
      latitude: '40.7569',
      longitude: '30.3783'),
  const City(
      name: 'Yalova',
      region: 'Marmara',
      latitude: '40.6550',
      longitude: '29.2769'),
  const City(
      name: 'Bilecik',
      region: 'Marmara',
      latitude: '40.1451',
      longitude: '29.9792'),

  // Ege Bölgesi
  const City(
      name: 'İzmir', region: 'Ege', latitude: '38.4237', longitude: '27.1428'),
  const City(
      name: 'Aydın', region: 'Ege', latitude: '37.8560', longitude: '27.8416'),
  const City(
      name: 'Denizli',
      region: 'Ege',
      latitude: '37.7765',
      longitude: '29.0864'),
  const City(
      name: 'Muğla', region: 'Ege', latitude: '37.2154', longitude: '28.3636'),
  const City(
      name: 'Manisa', region: 'Ege', latitude: '38.6191', longitude: '27.4289'),
  const City(
      name: 'Afyonkarahisar',
      region: 'Ege',
      latitude: '38.7507',
      longitude: '30.5567'),
  const City(
      name: 'Kütahya',
      region: 'Ege',
      latitude: '39.4199',
      longitude: '29.9857'),
  const City(
      name: 'Uşak', region: 'Ege', latitude: '38.6742', longitude: '29.4058'),

  // Akdeniz Bölgesi
  const City(
      name: 'Antalya',
      region: 'Akdeniz',
      latitude: '36.8969',
      longitude: '30.7133'),
  const City(
      name: 'Adana',
      region: 'Akdeniz',
      latitude: '37.0000',
      longitude: '35.3213'),
  const City(
      name: 'Mersin',
      region: 'Akdeniz',
      latitude: '36.8121',
      longitude: '34.6415'),
  const City(
      name: 'Burdur',
      region: 'Akdeniz',
      latitude: '37.7267',
      longitude: '30.2886'),
  const City(
      name: 'Isparta',
      region: 'Akdeniz',
      latitude: '37.7648',
      longitude: '30.5566'),
  const City(
      name: 'Hatay',
      region: 'Akdeniz',
      latitude: '36.2023',
      longitude: '36.1613'),
  const City(
      name: 'Kahramanmaraş',
      region: 'Akdeniz',
      latitude: '37.5753',
      longitude: '36.9228'),
  const City(
      name: 'Osmaniye',
      region: 'Akdeniz',
      latitude: '37.0746',
      longitude: '36.2464'),

  // İç Anadolu Bölgesi
  const City(
      name: 'Ankara',
      region: 'İç Anadolu',
      latitude: '39.9208',
      longitude: '32.8541'),
  const City(
      name: 'Konya',
      region: 'İç Anadolu',
      latitude: '37.8714',
      longitude: '32.4846'),
  const City(
      name: 'Kayseri',
      region: 'İç Anadolu',
      latitude: '38.7205',
      longitude: '35.4826'),
  const City(
      name: 'Eskişehir',
      region: 'İç Anadolu',
      latitude: '39.7767',
      longitude: '30.5206'),
  const City(
      name: 'Sivas',
      region: 'İç Anadolu',
      latitude: '39.7477',
      longitude: '37.0179'),
  const City(
      name: 'Kırşehir',
      region: 'İç Anadolu',
      latitude: '39.1425',
      longitude: '34.1709'),
  const City(
      name: 'Nevşehir',
      region: 'İç Anadolu',
      latitude: '38.6244',
      longitude: '34.7144'),
  const City(
      name: 'Niğde',
      region: 'İç Anadolu',
      latitude: '37.9697',
      longitude: '34.6764'),
  const City(
      name: 'Aksaray',
      region: 'İç Anadolu',
      latitude: '38.3687',
      longitude: '34.0370'),
  const City(
      name: 'Karaman',
      region: 'İç Anadolu',
      latitude: '37.1759',
      longitude: '33.2287'),
  const City(
      name: 'Kırıkkale',
      region: 'İç Anadolu',
      latitude: '39.8468',
      longitude: '33.5153'),
  const City(
      name: 'Yozgat',
      region: 'İç Anadolu',
      latitude: '39.8181',
      longitude: '34.8147'),
  const City(
      name: 'Çankırı',
      region: 'İç Anadolu',
      latitude: '40.6013',
      longitude: '33.6134'),

  // Karadeniz Bölgesi
  const City(
      name: 'Samsun',
      region: 'Karadeniz',
      latitude: '41.2867',
      longitude: '36.3300'),
  const City(
      name: 'Trabzon',
      region: 'Karadeniz',
      latitude: '41.0027',
      longitude: '39.7168'),
  const City(
      name: 'Rize',
      region: 'Karadeniz',
      latitude: '41.0201',
      longitude: '40.5234'),
  const City(
      name: 'Ordu',
      region: 'Karadeniz',
      latitude: '40.9862',
      longitude: '37.8797'),
  const City(
      name: 'Giresun',
      region: 'Karadeniz',
      latitude: '40.9128',
      longitude: '38.3895'),
  const City(
      name: 'Artvin',
      region: 'Karadeniz',
      latitude: '41.1828',
      longitude: '41.8183'),
  const City(
      name: 'Gümüşhane',
      region: 'Karadeniz',
      latitude: '40.4603',
      longitude: '39.4814'),
  const City(
      name: 'Bayburt',
      region: 'Karadeniz',
      latitude: '40.2552',
      longitude: '40.2249'),
  const City(
      name: 'Amasya',
      region: 'Karadeniz',
      latitude: '40.6499',
      longitude: '35.8353'),
  const City(
      name: 'Tokat',
      region: 'Karadeniz',
      latitude: '40.3167',
      longitude: '36.5500'),
  const City(
      name: 'Çorum',
      region: 'Karadeniz',
      latitude: '40.5499',
      longitude: '34.9537'),
  const City(
      name: 'Sinop',
      region: 'Karadeniz',
      latitude: '42.0231',
      longitude: '35.1531'),
  const City(
      name: 'Kastamonu',
      region: 'Karadeniz',
      latitude: '41.3887',
      longitude: '33.7827'),
  const City(
      name: 'Bartın',
      region: 'Karadeniz',
      latitude: '41.6344',
      longitude: '32.3375'),
  const City(
      name: 'Karabük',
      region: 'Karadeniz',
      latitude: '41.2061',
      longitude: '32.6204'),
  const City(
      name: 'Zonguldak',
      region: 'Karadeniz',
      latitude: '41.4564',
      longitude: '31.7987'),
  const City(
      name: 'Bolu',
      region: 'Karadeniz',
      latitude: '40.7392',
      longitude: '31.6089'),
  const City(
      name: 'Düzce',
      region: 'Karadeniz',
      latitude: '40.8438',
      longitude: '31.1565'),

  // Doğu Anadolu Bölgesi
  const City(
      name: 'Erzurum',
      region: 'Doğu Anadolu',
      latitude: '39.9055',
      longitude: '41.2658'),
  const City(
      name: 'Van',
      region: 'Doğu Anadolu',
      latitude: '38.4891',
      longitude: '43.4089'),
  const City(
      name: 'Ağrı',
      region: 'Doğu Anadolu',
      latitude: '39.7191',
      longitude: '43.0503'),
  const City(
      name: 'Malatya',
      region: 'Doğu Anadolu',
      latitude: '38.3554',
      longitude: '38.3335'),
  const City(
      name: 'Elazığ',
      region: 'Doğu Anadolu',
      latitude: '38.6810',
      longitude: '39.2264'),
  const City(
      name: 'Ardahan',
      region: 'Doğu Anadolu',
      latitude: '41.1105',
      longitude: '42.7022'),
  const City(
      name: 'Kars',
      region: 'Doğu Anadolu',
      latitude: '40.6013',
      longitude: '43.0975'),
  const City(
      name: 'Iğdır',
      region: 'Doğu Anadolu',
      latitude: '39.9167',
      longitude: '44.0333'),
  const City(
      name: 'Erzincan',
      region: 'Doğu Anadolu',
      latitude: '39.7500',
      longitude: '39.5000'),
  const City(
      name: 'Tunceli',
      region: 'Doğu Anadolu',
      latitude: '39.1079',
      longitude: '39.5401'),
  const City(
      name: 'Bingöl',
      region: 'Doğu Anadolu',
      latitude: '38.8854',
      longitude: '40.4980'),
  const City(
      name: 'Muş',
      region: 'Doğu Anadolu',
      latitude: '38.7432',
      longitude: '41.5064'),
  const City(
      name: 'Bitlis',
      region: 'Doğu Anadolu',
      latitude: '38.4006',
      longitude: '42.1095'),
  const City(
      name: 'Hakkari',
      region: 'Doğu Anadolu',
      latitude: '37.5744',
      longitude: '43.7408'),

  // Güneydoğu Anadolu Bölgesi
  const City(
      name: 'Gaziantep',
      region: 'Güneydoğu Anadolu',
      latitude: '37.0662',
      longitude: '37.3833'),
  const City(
      name: 'Diyarbakır',
      region: 'Güneydoğu Anadolu',
      latitude: '37.9144',
      longitude: '40.2306'),
  const City(
      name: 'Şanlıurfa',
      region: 'Güneydoğu Anadolu',
      latitude: '37.1674',
      longitude: '38.7955'),
  const City(
      name: 'Batman',
      region: 'Güneydoğu Anadolu',
      latitude: '37.8812',
      longitude: '41.1351'),
  const City(
      name: 'Mardin',
      region: 'Güneydoğu Anadolu',
      latitude: '37.3212',
      longitude: '40.7245'),
  const City(
      name: 'Siirt',
      region: 'Güneydoğu Anadolu',
      latitude: '37.9333',
      longitude: '41.9500'),
  const City(
      name: 'Adıyaman',
      region: 'Güneydoğu Anadolu',
      latitude: '37.7648',
      longitude: '38.2786'),
  const City(
      name: 'Kilis',
      region: 'Güneydoğu Anadolu',
      latitude: '36.7184',
      longitude: '37.1212'),
  const City(
      name: 'Şırnak',
      region: 'Güneydoğu Anadolu',
      latitude: '37.5164',
      longitude: '42.4611'),
];
