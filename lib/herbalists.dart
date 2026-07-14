class Herbalist {
  final String name;
  final String city;
  final String phone;
  final String? website;
  final String mapsUrl;
  final bool isOnline;
  final String? domain; // used to build herb-specific search links

  const Herbalist({
    required this.name,
    required this.city,
    required this.phone,
    required this.mapsUrl,
    this.website,
    this.isOnline = false,
    this.domain,
  });

  /// Returns a link that searches this shop's site for a specific herb.
  /// Falls back to the shop's homepage/maps link if no domain is known.
  String searchUrlForHerb(String herbName) {
    if (domain == null) {
      return website ?? mapsUrl;
    }
    final query = Uri.encodeComponent('site:$domain $herbName');
    return 'https://www.google.com/search?q=$query';
  }
}

// Physical shops — visit in person
const List<Herbalist> tunisianHerbalists = [
  Herbalist(
    name: 'Herboristerie Greenland',
    city: 'Tunis',
    phone: '+216 29 906 300',
    website: 'https://herboristerie-green-land.converty.shop/',
    mapsUrl: 'https://maps.google.com/?cid=885617907341105111',
  ),
  Herbalist(
    name: 'BIOHERBS SFAX',
    city: 'Sfax',
    phone: '+216 29 289 243',
    website: 'https://bioherbs-tunisie.com/',
    mapsUrl: 'https://maps.google.com/?cid=17743382358358459644',
  ),
  Herbalist(
    name: 'Flore Avicenne',
    city: 'Sousse',
    phone: '+216 73 333 786',
    mapsUrl: 'https://maps.google.com/?cid=14728502535294446168',
  ),
  Herbalist(
    name: 'Biomarket',
    city: 'Hammam Sousse',
    phone: '+216 73 361 308',
    website: 'http://biomarket.tn/',
    mapsUrl: 'https://maps.google.com/?cid=13897413869432794635',
  ),
  Herbalist(
    name: 'Trésors Naturels Sousse',
    city: 'Sousse',
    phone: '+216 58 959 019',
    website: 'http://www.tresorsnaturels.tn/',
    mapsUrl: 'https://maps.google.com/?cid=8671986693713288627',
  ),
];

// Online shops — order with delivery, no visit required
const List<Herbalist> onlineHerbalists = [
  Herbalist(
    name: 'MaPara Tunisie Parapharmacie',
    city: 'Ariana (ships nationwide)',
    phone: '+216 23 203 203',
    website: 'https://mapara.tn',
    mapsUrl: 'https://maps.google.com/?cid=1584441216064022550',
    isOnline: true,
    domain: 'mapara.tn',
  ),
  Herbalist(
    name: 'VivezNature',
    city: 'Mégrine (ships nationwide)',
    phone: '+216 93 759 990',
    website: 'https://viveznature.tn',
    mapsUrl: 'https://maps.google.com/?cid=2822833317365864550',
    isOnline: true,
    domain: 'viveznature.tn',
  ),
  Herbalist(
    name: 'Tunisie Bio',
    city: 'Mégrine (ships nationwide)',
    phone: '+216 24 467 822',
    website: 'https://tunisiebio.com',
    mapsUrl: 'https://maps.google.com/?cid=1591654226501244442',
    isOnline: true,
    domain: 'tunisiebio.com',
  ),
  Herbalist(
    name: 'Eden Pharma',
    city: 'Ariana (ships nationwide)',
    phone: '+216 28 372 827',
    website: 'https://edenpharma.tn',
    mapsUrl: 'https://maps.google.com/?cid=15852033350313357541',
    isOnline: true,
    domain: 'edenpharma.tn',
  ),
];

// Convenience: both lists combined
List<Herbalist> get allHerbalists => [
  ...tunisianHerbalists,
  ...onlineHerbalists,
];
