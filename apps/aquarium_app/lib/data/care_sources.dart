class CareSource {
  final String title;
  final String publisher;
  final String url;
  final String note;

  const CareSource({
    required this.title,
    required this.publisher,
    required this.url,
    required this.note,
  });
}

const fishCareSources = <CareSource>[
  CareSource(
    title: 'FishBase',
    publisher: 'FishBase Consortium',
    url: 'https://www.fishbase.se/',
    note: 'Taxonomy, biology, size, and species context.',
  ),
  CareSource(
    title: 'Merck Veterinary Manual',
    publisher: 'Merck & Co.',
    url:
        'https://www.merckvetmanual.com/exotic-and-laboratory-animals/aquatic-systems/environmental-diseases-of-aquatic-animals-in-aquatic-systems',
    note: 'Water quality risk context and aquatic health principles.',
  ),
  CareSource(
    title: 'RSPCA fish welfare advice',
    publisher: 'RSPCA',
    url: 'https://www.rspca.org.uk/adviceandwelfare/pets/fish',
    note: 'General companion fish welfare and care checks.',
  ),
];

const plantCareSources = <CareSource>[
  CareSource(
    title: 'Tropica plant database',
    publisher: 'Tropica Aquarium Plants',
    url: 'https://tropica.com/en/plants/',
    note: 'Plant difficulty, light, CO2, and aquarium placement context.',
  ),
  CareSource(
    title: 'INJAF planted aquarium guide',
    publisher: 'INJAF',
    url:
        'https://injaf.org/articles-guides/beginners-guides/beginners-guide-to-aquarium-plants/',
    note: 'Beginner-friendly planted tank care and plant selection guidance.',
  ),
];
