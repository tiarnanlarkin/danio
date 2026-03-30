/// Fun facts for each fish species in the app.
///
/// Keys are species IDs (without the `sc_` prefix used in the unlock system).
/// Each species has 4–5 fun facts shown at random when the user taps a fish
/// in the tank view (DNL-001: Globe Fish Facts Dialog).
const Map<String, List<String>> kFishFacts = {
  'zebra_danio': [
    'Zebra danios were the first vertebrate to be cloned — scientists used them to study genetics!',
    'They can regenerate their heart tissue after injury — something humans can\'t do.',
    'Their stripes run horizontally (unlike a zebra\'s vertical ones) to confuse predators.',
    'Zebra danios are shoaling fish and feel safest in groups of 6 or more.',
    'They were sent to space aboard the Space Shuttle Discovery to study bone density loss.',
  ],
  'neon_tetra': [
    'The neon tetra\'s iconic blue stripe is structural colour — it\'s created by light refraction, not pigment.',
    'In the wild, neon tetras live in dark, blackwater rivers of the Amazon basin.',
    'They school together to look like a single large creature and deter predators.',
    'Neon tetras can turn off their neon stripe at night to hide while they sleep!',
    'Over 1.8 million neon tetras are imported into the US alone every month.',
  ],
  'betta': [
    'Bettas breathe air directly using a special organ called a labyrinth — they\'d drown in oxygen-depleted water without it.',
    'Male bettas build bubble nests at the water surface when ready to breed.',
    'In Thailand, betta fighting is a centuries-old tradition (though now discouraged for welfare reasons).',
    'A betta can recognise its own reflection — and will flare its fins at it like a rival.',
    'Wild bettas live in shallow rice paddies and can survive brief periods out of water.',
  ],
  'guppy': [
    'Guppies give birth to live young — up to 200 fry at a time!',
    'Female guppies can store sperm for months and produce multiple batches of fry from a single mating.',
    'They were used in mosquito control programmes worldwide — they eat larvae voraciously.',
    'Guppies have been observed mourning dead companions in laboratory studies.',
    'Trinidad guppies in different rivers evolved different colours depending on predator pressure.',
  ],
  'molly': [
    'Mollies are one of the few freshwater fish that can also thrive in saltwater and brackish conditions.',
    'They can eat algae, detritus, and even faeces — natural tank cleaners!',
    'Mollies give birth to live young, just like guppies.',
    'The black molly is entirely man-made — it doesn\'t exist in the wild.',
    'In saline conditions, mollies live longer and show fewer signs of disease.',
  ],
  'platy': [
    'Platies are livebearers — they give birth to fully formed free-swimming fry.',
    'They were one of the first tropical fish kept in home aquariums in the early 1900s.',
    'Platies hybridise easily with swordtails, producing fertile offspring.',
    'They\'re naturally curious and will often investigate a finger pressed against the glass.',
    'A wild platy\'s colouration is mostly silver-grey — all the vivid colours are from selective breeding.',
  ],
  'harlequin_rasbora': [
    'The harlequin rasbora\'s distinctive black triangle patch is unique among rasboras.',
    'They lay eggs on the underside of broad-leaved plants like Amazon swords.',
    'In the wild they inhabit peat-stained blackwater streams in Malaysia and Thailand.',
    'Harlequin rasboras are unusually long-lived for small fish — up to 8 years in ideal conditions.',
    'They use group synchrony — the whole shoal turns at the same instant — to evade predators.',
  ],
  'cherry_barb': [
    'Only the male cherry barb turns brilliant red — females stay a more muted peachy tone.',
    'They\'re classified as vulnerable in the wild due to habitat loss in Sri Lanka.',
    'Cherry barbs are one of the most peaceful barbs — unlike their nippy tiger barb cousins.',
    'Males perform a courtship dance, circling the female with fins flared before spawning.',
    'They eat algae, small invertebrates, and plant matter — making them flexible community fish.',
  ],
  'angelfish': [
    'Angelfish are cichlids — related to Oscar fish and discus, not to marine angelfish.',
    'They form monogamous pairs and both parents guard the eggs and fry.',
    'In the wild, their tall disc shape helps them hide among roots and reeds in the Amazon.',
    'Angelfish can grow up to 15 cm tall — their height often exceeds their length.',
    'They use their mouths to carry eggs to safety if threatened during spawning.',
  ],
  'amano_shrimp': [
    'Named after aquarist Takashi Amano, who popularised them for algae control in planted tanks.',
    'They\'re among the best algae-eating shrimp — a single Amano can consume its own body weight in algae each day.',
    'Breeding them in freshwater is nearly impossible — larvae require brackish water to survive.',
    'Amano shrimp turn a faint orange-red colour when cooked, just like larger crustaceans.',
    'They can live 5+ years in a well-maintained aquarium — unusually long for a shrimp.',
  ],
  'cherry_shrimp': [
    'The cherry shrimp\'s vivid red colour was selectively bred — wild ones are nearly transparent.',
    'Grading system: Cherry → Sakura → Fire Red → Painted Fire Red, based on colour intensity.',
    'Females carry eggs under their tail for 3–4 weeks, fanning them with their swimmerets.',
    'They moult their exoskeleton to grow — don\'t remove the shed shell; it\'s calcium they\'ll eat!',
    'Cherry shrimp are sensitive to copper — even trace amounts in tap water can be fatal.',
  ],
  'nerite_snail': [
    'Nerite snails lay eggs that can only hatch in brackish or saltwater — no accidental infestations!',
    'They\'re considered the best algae-eating snail for aquariums — they ignore plants entirely.',
    'There are over 200 species of nerite snail, each with unique patterns.',
    'Despite no formal hearing, they respond to vibrations and will hide when disturbed.',
    'They can climb out of tanks — always use a lid with nerites around!',
  ],
  'otocinclus': [
    'Otocinclus — or "otos" — are tiny armoured catfish that sucker onto glass to graze algae.',
    'They\'re schooling fish: a lone oto will be stressed; keep at least 4–6 together.',
    'In the wild they graze in large groups across river rocks in South America.',
    'They\'re very sensitive to water quality — they\'re often called the "canary in the coal mine" for tank conditions.',
    'Otos can eat their body weight in algae every day, making them elite algae controllers.',
  ],
  'bristlenose_pleco': [
    'The bristles on a male bristlenose pleco are actually sensory tentacles, used to detect rivals.',
    'Unlike common plecos, bristlenose stay small — under 15 cm — making them perfect for home tanks.',
    'They\'re nocturnal and spend most of the day hiding; a cave or driftwood hide is essential.',
    'Bristlenose plecos eat wood as part of their diet — driftwood in their tank aids digestion.',
    'Males guard the eggs, fanning them with their fins until they hatch.',
  ],
  'bronze_corydoras': [
    'Cory catfish breathe through their intestines — they gulp air at the surface when oxygen is low.',
    'They\'re social fish that feel safest in groups of 6 or more, often resting in a heap.',
    'Cories "wink" by rotating their eyes — it\'s a startle response, not a sign of illness.',
    'Their barbels are used to root through the substrate looking for food — keep sand, not gravel, to protect them.',
    'Bronze corydoras are one of the hardiest and most beginner-friendly catfish in the hobby.',
  ],
};

/// Returns a random fun fact for the given [speciesId].
///
/// If the species is not found, returns a generic fallback fact.
String getRandomFishFact(String speciesId) {
  final facts = kFishFacts[speciesId];
  if (facts == null || facts.isEmpty) {
    return 'Every fish has its own personality — spend time watching yours and you\'ll see it!';
  }
  // Use DateTime microseconds as cheap random seed
  final index = DateTime.now().microsecondsSinceEpoch % facts.length;
  return facts[index];
}

/// Returns the display name for a species ID.
///
/// Converts snake_case to Title Case (e.g. 'neon_tetra' → 'Neon Tetra').
String speciesDisplayName(String speciesId) {
  return speciesId
      .split('_')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
