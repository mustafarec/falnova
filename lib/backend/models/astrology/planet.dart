enum Planet {
  sun('Güneş'),
  moon('Ay'),
  mercury('Merkür'),
  venus('Venüs'),
  mars('Mars'),
  jupiter('Jüpiter'),
  saturn('Satürn'),
  uranus('Uranüs'),
  neptune('Neptün'),
  pluto('Plüton');

  final String name;
  const Planet(this.name);

  @override
  String toString() => name;

  static Planet fromName(String name) {
    return Planet.values.firstWhere(
      (planet) => planet.name.toLowerCase() == name.toLowerCase(),
      orElse: () => throw ArgumentError('Geçersiz gezegen ismi: $name'),
    );
  }
}
