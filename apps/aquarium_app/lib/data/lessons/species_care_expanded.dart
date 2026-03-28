/// Lesson content - Species Care (Expanded)
/// 7 new species care lessons added in Phase 5
library;

import '../../models/learning.dart';

final speciesCareExpandedLessons = [
  // SC-7: Corydoras Care
  Lesson(
    id: 'sc_corydoras',
    pathId: 'species_care',
    title: 'Corydoras: The Essential Cleanup Crew',
    description: 'More than just bottom-vacuum fish — social, curious, and long-lived',
    orderIndex: 6,
    xpReward: 50,
    estimatedMinutes: 7,
    prerequisites: ['ff_choosing'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Not Just a Clean-Up Crew',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Corydoras catfish have a reputation as "janitor fish" — bought to clean up the tank floor and largely ignored. In reality, cories are active, social fish with genuine personalities. They school together, "wink" by rotating one eye independently, and often zip to the surface for a gulp of air. A happy group of cories is one of the most entertaining things in a community tank.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'Cories must have fine sand. Sharp gravel and rough substrate wears down their barbels — the delicate sensory whiskers around their mouth. Damaged barbels lead to bacterial infections that shorten their lives. This is the single most important rule for corydoras care.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Social Animals — School or Suffer',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Corydoras are schooling fish. Keeping a single cory is cruel — they become stressed, hide constantly, and rarely eat well. Keep at least 6 of the same species. Mixed species groups (e.g. bronze + peppered) will coexist but won\'t school properly — they\'re not the same species and don\'t recognise each other as kin.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Bronze cory (C. aeneus) — the gold-standard beginner cory, hardy and adaptable\n• Peppered cory (C. paleatus) — tolerates cooler water (18–24°C), good UK unheated tank option\n• Sterbai cory (C. sterbai) — striking orange-spotted markings, tolerates higher temperatures (up to 29°C)\n• Panda cory (C. panda) — beautiful black-and-white markings, slightly more delicate\n• Julii cory (C. julii) — spotted leopard pattern, often confused with trilineatus',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Parameters and Tank Setup',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Temperature: 22–26°C (72–79°F) — Sterbai: up to 29°C\n• pH: 6.5–7.5\n• Hardness: soft to medium — GH 4–12\n• Tank size: 60L+ for a school of 6\n• Substrate: fine sand (mandatory)\n• Tank mates: peaceful community fish, avoid large cichlids or nippy species',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Corydoras are sensitive to medications. They have bony scutes (armour plates) rather than traditional scales, which affects how they absorb chemicals. When medicating a tank containing cories, use half the recommended dose, or better yet, remove them to a hospital tank first.',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Cories breathe air! They periodically dart to the surface for a quick gulp. This is completely normal — they have a modified intestine that can absorb atmospheric oxygen. If they\'re doing it frantically and continuously, that\'s a sign of low dissolved oxygen.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'Corydoras is one of the largest freshwater fish genera in the world — over 170 described species, with new species still being discovered and formally described from South American river systems every few years.',
      ),
    ],
    quiz: Quiz(
      id: 'sc_corydoras_quiz',
      lessonId: 'sc_corydoras',
      questions: [
        const QuizQuestion(
          id: 'sc_cory_q1',
          question:
              'Why must Corydoras be kept on fine sand rather than gravel?',
          options: [
            'Corydoras eat sand particles as part of their natural diet',
            'Gravel damages their sensitive barbels, leading to infection',
            'Gravel makes water too alkaline for corydoras',
            'Sand keeps the tank floor cooler, which cories prefer',
          ],
          correctIndex: 1,
          explanation:
              'Corydoras have delicate barbels (whiskers) they use to find food in substrate. Sharp or coarse gravel abrades these over time, creating wounds that become infected. Fine sand is non-negotiable for barbel health — it\'s the single most important aspect of corydoras care.',
        ),
        const QuizQuestion(
          id: 'sc_cory_q2',
          question: 'What is the minimum school size for Corydoras?',
          options: [
            '2 fish — they need a companion',
            '4 fish — a small group',
            '6 fish of the same species',
            '10 fish minimum for any schooling fish',
          ],
          correctIndex: 2,
          explanation:
              'Corydoras are true schooling fish and need a group to feel secure and display natural behaviour. A lone corydoras will be stressed and hide. 6 same-species fish is the accepted minimum — more is always better.',
        ),
        const QuizQuestion(
          id: 'sc_cory_q3',
          question:
              'Your corydoras are constantly dashing to the surface and gasping. What should you check first?',
          options: [
            'The substrate — they might be unhappy with the sand depth',
            'Dissolved oxygen levels and surface agitation in the tank',
            'Whether they have enough hiding spots',
            'Their food — they might be underfed',
          ],
          correctIndex: 1,
          explanation:
              'While cories occasionally surface for air (normal), frantic surface gasping indicates dangerously low dissolved oxygen. Check your filter and aeration. This is an emergency — low oxygen kills fish within hours.',
        ),
      ],
    ),
  ),

  // SC-8: Livebearers
  Lesson(
    id: 'sc_livebearers',
    pathId: 'species_care',
    title: 'Livebearers: Guppies, Platys & Mollies',
    description: 'Fish that give birth to live young — with all the complications that brings',
    orderIndex: 7,
    xpReward: 50,
    estimatedMinutes: 7,
    prerequisites: ['ff_choosing'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'They Give Birth to Live Babies',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Unlike most fish that scatter eggs and hope for the best, livebearers skip the egg stage entirely and give birth to fully formed, free-swimming fry. Females store sperm internally and can produce fry for months after a single mating. A female guppy produces 20–100 fry every 4–6 weeks — a level of productivity that beginners are often unprepared for.',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Guppy population explosion is real and rapid. Without a plan (other fish eating fry, a separate grow-out tank, or accepting losses), a single pair becomes hundreds within a year. Have a strategy before you mix males and females.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Guppies — The Fancy Car of Beginner Fish',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Temperature: 22–28°C (72–82°F)\n• pH: 7.0–8.0 (they prefer slightly alkaline)\n• Hardness: GH 8–12 (moderately hard water)\n• Males display elaborate fins and vivid colours; females are drab but larger\n• For colour display without breeding: keep males only\n• For no breeding at all: keep females only',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Platys — Hardy and Beginner-Proof',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Platys (Xiphophorus maculatus) are stockier than guppies and widely considered even more disease-resistant. They tolerate a wider range of water conditions and are rarely aggressive. An excellent choice for new fishkeepers — they\'re colourful, active, and forgiving. Available in dozens of colour morphs: sunset, blue mirror, Mickey Mouse, salt and pepper, and more.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Temperature: 20–28°C — tolerates cooler water than guppies\n• pH: 7.0–8.0\n• Minimum tank: 60L for a small group\n• Keep 2:1 female-to-male ratio to reduce male harassment of females',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Mollies — A Little More Demanding',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Mollies (Poecilia sphenops, P. latipinna) are the most sensitive of the three common livebearers. They prefer slightly hard water and, in their native habitat, often live in brackish conditions near coastal estuaries. Poor water quality hits mollies harder than guppies or platys — they\'ll show symptoms like clamped fins and wasting before other fish are affected. Treat them as a canary for water quality.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Temperature: 24–28°C (75–82°F) — warmth is important\n• pH: 7.5–8.5, prefer harder water\n• Sailfin mollies need larger tanks — 110L+\n• Black mollies are a popular captive-bred variety\n• A small amount of aquarium salt (1 tsp per 20L) can help mollies in soft-water areas',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'For all livebearers: use a 2:1 or 3:1 female-to-male ratio. Male livebearers pursue females relentlessly. Outnumbering males with females reduces stress on individual females and prevents exhaustion injuries.',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Dense floating plants (Salvinia, hornwort, water lettuce, frogbit) dramatically increase fry survival rate. Fry instinctively hide in surface vegetation — it\'s their only protection against being eaten by adults and other tank mates.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'Guppies were first formally described in 1866 and named after naturalist Robert John Lechmere Guppy, who sent specimens from Trinidad to the British Museum. They were independently discovered at least twice by different naturalists and were known by several other names before "guppy" stuck.',
      ),
    ],
    quiz: Quiz(
      id: 'sc_livebearers_quiz',
      lessonId: 'sc_livebearers',
      questions: [
        const QuizQuestion(
          id: 'sc_live_q1',
          question:
              'What is the recommended female-to-male ratio for livebearers?',
          options: [
            '1:1 equal ratio',
            'More males than females for colour display',
            '2:1 or 3:1 females to males',
            'Keep only one sex per tank always',
          ],
          correctIndex: 2,
          explanation:
              'Male livebearers constantly pursue females. A 2:1 or 3:1 female-to-male ratio means the pursuit is spread across multiple females, reducing stress and physical exhaustion for individual females. Equal ratios lead to females being relentlessly harassed.',
        ),
        const QuizQuestion(
          id: 'sc_live_q2',
          question:
              'Why can a female guppy produce fry for months after being separated from males?',
          options: [
            'Female guppies can reproduce asexually',
            'She stores sperm from a single mating and uses it to fertilise successive batches of eggs',
            'Her eggs develop extremely slowly over many months',
            'Guppy fry stay inside the mother for 6 months before birth',
          ],
          correctIndex: 1,
          explanation:
              'Female livebearers can store viable sperm internally for extended periods. A single mating provides enough sperm for multiple broods over several months. This is why separating males from females doesn\'t immediately stop the production of fry.',
        ),
        const QuizQuestion(
          id: 'sc_live_q3',
          question:
              'Which livebearer is most sensitive to poor water quality and prefers harder water?',
          options: [
            'Guppy — most sensitive of the three',
            'Platy — most delicate and disease-prone',
            'Molly — shows symptoms earliest and prefers harder, warmer water',
            'All three are equally sensitive to water quality',
          ],
          correctIndex: 2,
          explanation:
              'Mollies are the most demanding of the common livebearers. They\'re native to coastal areas with harder, sometimes brackish water, and are less forgiving of poor conditions than guppies or platys. Clamped fins in mollies are an early water quality warning sign.',
        ),
      ],
    ),
  ),

  // SC-9: Rasboras
  Lesson(
    id: 'sc_rasboras',
    pathId: 'species_care',
    title: 'Rasboras & Small Schoolers',
    description: 'Southeast Asian gems from nano tanks to show tanks',
    orderIndex: 8,
    xpReward: 50,
    estimatedMinutes: 6,
    prerequisites: ['ff_choosing'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Small But Spectacular',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Rasboras originate from Southeast Asia — Indonesia, Malaysia, Thailand — and prefer warm, slightly acidic, soft water. This distinguishes them from tetras, which come from South America. While both fill the "small peaceful schooling fish" role in a community tank, their preferred water parameters and natural biotopes differ. In practice, both do fine in neutral (pH 7) community tanks, but rasboras truly shine in a soft, warm, Southeast Asian setup.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'Harlequin rasboras (Trigonostigma heteromorpha) are one of the best beginner fish in the hobby. Hardy, peaceful, strikingly marked with a distinctive black triangle patch, and reach 4.5cm. A school of 10+ in a planted 60L is a genuinely beautiful display.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Nano Schoolers for Small Tanks',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'The nano tank scene has exploded in popularity, and small rasboras are central to it. These species stay tiny (1–2.5cm) and create stunning effect in groups of 20–30 in a 30–60L tank.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Chili rasbora (Boraras brigittae) — 1cm, vivid red, blackwater species. Minimum school: 15. Ideal in 30L nano tanks.\n• Galaxy rasbora / Celestial Pearl Danio (Danio margaritatus) — 2.5cm, stunning pearl-dotted body, orange fins. School of 10+.\n• Ember tetra (Hyphessobrycon amandae) — technically a tetra, SE Asian-compatible in setup, 2cm, orange-red.\n• Lambchop/Pork Chop rasbora (Trigonostigma espei) — similar to harlequin, slightly smaller and warmer in colour.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Setup and Parameters',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Temperature: 24–28°C — nano rasboras especially prefer the warmer end\n• pH: 5.5–7.0 for best colour and health (neutral works)\n• Hardness: soft — GH 2–8 ideal\n• Dense planting + floating plants to reduce surface light intensity\n• Indian almond leaves add natural tannins and mild antibacterial compounds\n• School size: minimum 10, ideally 15–20 for proper shoaling behaviour',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Nano fish are extremely sensitive to water quality issues. Their small size leaves minimal physiological margin for error — even brief ammonia spikes can kill them. Always fully cycle the tank before adding nano schoolers, and never add them to a new setup.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'The Celestial Pearl Danio was only discovered in 2006 in a small lake in Myanmar. Its announcement immediately caused a sensation — hobbyists called it the most beautiful small fish ever found. Wild populations were threatened by over-collection within months. Fortunately, captive breeding caught up quickly, and it\'s now bred in large numbers worldwide.',
      ),
    ],
    quiz: Quiz(
      id: 'sc_rasboras_quiz',
      lessonId: 'sc_rasboras',
      questions: [
        const QuizQuestion(
          id: 'sc_ras_q1',
          question:
              'How does the natural habitat of rasboras differ from tetras?',
          options: [
            'Rasboras are from South America; tetras are from Southeast Asia',
            'Rasboras are from Southeast Asia; tetras are from South America',
            'Both come from the Amazon river system',
            'There is no geographical difference — both are pan-tropical',
          ],
          correctIndex: 1,
          explanation:
              'Rasboras are from Southeast Asia (Indonesia, Malaysia, Thailand). Tetras are from South America (Amazon, Orinoco basins). This means ideal water parameters and biotope setups differ, though both groups are adaptable enough for neutral community tanks.',
        ),
        const QuizQuestion(
          id: 'sc_ras_q2',
          question:
              'What is the minimum recommended school size for Harlequin Rasboras?',
          options: [
            '3 fish',
            '6 fish',
            '10 fish',
            '25 fish minimum',
          ],
          correctIndex: 2,
          explanation:
              'Harlequin rasboras need a group of at least 10 to feel secure and school properly. Fewer fish means stress, hiding, and pale colouration. In groups of 10+, they school actively through the midwater and show much bolder colouration.',
        ),
        const QuizQuestion(
          id: 'sc_ras_q3',
          question: 'Why are Chili Rasboras suitable for nano tanks?',
          options: [
            'They need very little oxygen and can survive in small tanks',
            'They only grow to about 1cm and have a tiny bioload even in groups',
            'They don\'t require any filtration in tanks under 20L',
            'They\'re solitary fish that don\'t need groups',
          ],
          correctIndex: 1,
          explanation:
              'Chili rasboras (Boraras brigittae) are among the smallest freshwater fish — reaching just 1cm. Their tiny bioload means a group of 15–20 can comfortably live in a well-filtered 30L nano tank without overloading the filtration system.',
        ),
      ],
    ),
  ),

  // SC-10: Angelfish
  Lesson(
    id: 'sc_angelfish',
    pathId: 'species_care',
    title: 'Angelfish: Tall Tanks & Temperament',
    description: 'The jewel of the community tank — with important caveats',
    orderIndex: 9,
    xpReward: 50,
    estimatedMinutes: 7,
    prerequisites: ['sc_cichlids'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'The Jewel of the Community Tank',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Angelfish (Pterophyllum scalare) are South American cichlids — but unlike their aggressive African cousins, they\'re regularly kept in community tanks. With caveats. They\'re laterally compressed (flat-bodied) fish that evolved to weave through tall Amazon riverine vegetation and root structures. This body shape means they need height, not just length, in their aquarium.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'Minimum tank: 110L (29 US gal), tall format — at least 45cm in height. A 90cm × 45cm × 45cm tank is better than a wide, shallow 120cm × 30cm × 30cm tank. Angelfish swim vertically more than horizontally.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'The Tankmate Problem',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'This is the conversation every angelfish owner has after learning the hard way: angelfish eat small fish. Neon tetras are perhaps the most famous casualty — they photograph beautifully together, and in real life, once the angel grows large enough, the neons become prey. This typically happens at 3–4 months of age.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Safe tank mates: larger tetras (Buenos Aires, bleeding heart, diamond), corydoras, mollies, dwarf gouramis, bristlenose plecos\n• Risky: neon tetras, cardinal tetras, small rasboras (any fish small enough to fit in the angel\'s mouth)\n• Generally avoid: aggressive cichlids, tiger barbs (notorious fin-nippers), very large fish',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Two male angelfish in a smaller tank will often fight relentlessly, especially when both are maturing or when breeding season approaches. Signs: chasing, torn fins, one fish hiding. Separate immediately if injuries occur.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Water Parameters',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Temperature: 24–29°C (75–84°F)\n• pH: 6.0–7.5 (wild caught prefer 6.0–6.8; domestic strains tolerate wider range)\n• Hardness: soft to medium — GH 4–8 ideal\n• Tall tank with vertical structure (driftwood, tall plants, broad-leaf plants like Amazon sword)\n• Relatively calm flow — strong currents stress them',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Pair Bonding and Breeding',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Angelfish form long-term pair bonds. Once bonded, a pair will choose and defend a territory in the tank — aggressively, even against larger fish. This is completely natural behaviour. Spawning is common in established tanks — eggs are laid on flat vertical surfaces: broad leaves, filter pipes, the tank glass. The pair fans the eggs and guards them from all other tank inhabitants.',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'The best way to get a bonded pair: buy 4–6 juvenile angels (2–3cm) and raise them together. A natural bonded pair will emerge as they mature. Buying "a pair" from a fish shop provides no guarantee of compatibility — shop pairs are often just two fish that happened to be in the same tank.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'Wild angelfish from the Amazon are almost entirely silver with black vertical bars — perfect camouflage in sunlit, root-choked water. The extraordinary range of colour varieties seen today (marble, koi, gold, platinum, black lace) are all products of decades of selective breeding by hobbyists. No wild angelfish looks like a "gold" angel.',
      ),
    ],
    quiz: Quiz(
      id: 'sc_angelfish_quiz',
      lessonId: 'sc_angelfish',
      questions: [
        const QuizQuestion(
          id: 'sc_angel_q1',
          question: 'Why do angelfish specifically need tall tanks?',
          options: [
            'They swim exclusively at the top of the water column and need access to surface air',
            'Their laterally compressed bodies evolved for navigating tall Amazon vegetation — they swim vertically',
            'They grow to 12 inches in length and need a wide tank',
            'Standard tank height is fine — the "tall tank" advice is outdated',
          ],
          correctIndex: 1,
          explanation:
              'Angelfish are laterally compressed — flat-bodied — because they evolved to slip between tall Amazon roots and vegetation. They\'re naturally vertical swimmers. A shallow tank prevents this natural movement. Minimum 45cm height is recommended.',
        ),
        const QuizQuestion(
          id: 'sc_angel_q2',
          question:
              'Why should you avoid keeping neon tetras with large angelfish?',
          options: [
            'Neon tetras will aggressively nip angel fins',
            'Once large enough, angelfish will eat neon tetras — they fit in the angel\'s mouth',
            'Neon tetras need much colder water than angelfish',
            'They compete for identical food and angelfish always win',
          ],
          correctIndex: 1,
          explanation:
              'Angelfish are predators. As they grow (typically 3–4 months old), neon tetras become small enough to eat. The classic "angelfish + neon tetras" photo setup ignores the reality of fish biology. Choose larger tetras as tankmates.',
        ),
        const QuizQuestion(
          id: 'sc_angel_q3',
          question:
              'What is the recommended way to get a naturally bonded angelfish pair?',
          options: [
            'Buy a pre-sexed male and female from a reputable aquarium shop',
            'Buy one large angel and one small angel — size difference ensures pairing',
            'Raise a group of 4–6 juveniles together and let a bonded pair form naturally',
            'Bonded pairs are a myth — any two angelfish will readily breed',
          ],
          correctIndex: 2,
          explanation:
              'Angelfish choose their own mates. Raising 4–6 juveniles together lets natural pair bonds form as the fish mature. Forced pairings often fail. A naturally bonded pair is far more likely to successfully spawn and raise fry.',
        ),
      ],
    ),
  ),

  // SC-11: Plecos
  Lesson(
    id: 'sc_plecos',
    pathId: 'species_care',
    title: 'Plecos & Algae Eaters',
    description: 'The common pleco myth — and what to keep instead',
    orderIndex: 10,
    xpReward: 50,
    estimatedMinutes: 6,
    prerequisites: ['maint_algae'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Not All Algae Eaters Are Equal',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Every fish shop sells "sucker fish" in small cups — usually common plecos (Pterygoplichthys pardalis). What the label doesn\'t tell you: common plecos grow to 45–60cm and produce enormous waste. Buying one to "solve" your algae problem is one of the most common beginner mistakes. By the time it\'s large enough to make a difference, it\'s too big for your tank and is actually one of your biggest waste contributors.',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'The "sucker fish" in a tiny cup at your local fish shop will likely grow to 45–60cm (18–24 inches). They outgrow standard 4-foot home aquariums within 18–24 months. Always ask the adult size before buying any pleco.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'Bristlenose plecos (Ancistrus sp.) are the correct choice for home aquariums. They stay at 10–13cm, are excellent algae grazers, are hardy, and are genuinely interesting fish to watch. They\'re one of the few pleco species that breed readily in standard aquarium conditions.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Otocinclus — The Planted Tank Specialist',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Otocinclus (Otocinclus vittatus, O. affinis, and related species) are tiny 3–4cm catfish that graze diatoms, biofilm, and green algae off plant leaves with extraordinary precision, without damaging the plants. They\'re the perfect algae cleaner for planted tanks. The major catch: they are delicate.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Otos need: a fully mature, well-established tank (6+ months old minimum)\n• School of 6+ — they are social and will waste away alone\n• Soft, slightly acidic water — pH 6.5–7.2, temperature 22–26°C\n• Supplemental feeding: zucchini, cucumber, algae wafers — don\'t rely on tank algae alone\n• Never add to a new setup — they need the biofilm of an established tank',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Pleco Diet — Beyond Algae',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Plecos are omnivores, not pure herbivores. Algae alone is insufficient for their long-term health. Supplement with zucchini, cucumber, and blanched spinach (vegetables should be pre-blanched to soften them). Algae wafers provide a balanced alternative. Driftwood is also essential — plecos rasp wood as a dietary supplement and digestive aid.',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Bristlenose plecos breed readily in aquariums. The male selects and guards a cave (a small ceramic tube or hollow ornament is perfect). He fertilises the eggs and fans them until they hatch. Seeing a male guarding a cave full of eggs is a clear sign your pair is healthy and well-fed.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'The distinctive bristles on a Bristlenose pleco\'s face (more pronounced on males) grow continuously throughout life. Their exact function is debated — possible roles include mate selection, species recognition, or camouflage. No one has definitively proven what they\'re for.',
      ),
    ],
    quiz: Quiz(
      id: 'sc_plecos_quiz',
      lessonId: 'sc_plecos',
      questions: [
        const QuizQuestion(
          id: 'sc_pleco_q1',
          question:
              'What is the main problem with buying a "common pleco" for a home aquarium?',
          options: [
            'Common plecos are highly aggressive towards other fish',
            'They grow to 45–60cm and produce enormous waste, unsuitable for most home tanks',
            'Common plecos eat all live plants in the aquarium',
            'They\'re too sensitive for beginner tanks and require expert care',
          ],
          correctIndex: 1,
          explanation:
              'Common plecos (Pterygoplichthys sp.) are frequently sold at 5cm but will grow to 45–60cm. They become the biggest waste producers in the tank — the opposite of what buyers hoped for. Bristlenose plecos stay at 10–13cm and are the appropriate home aquarium choice.',
        ),
        const QuizQuestion(
          id: 'sc_pleco_q2',
          question: 'Why should you never add otocinclus to a new tank?',
          options: [
            'Otocinclus are extremely aggressive towards newly introduced fish',
            'They need a mature, established tank with biofilm and algae to survive',
            'New tanks are always too cold for otocinclus',
            'Otocinclus only thrive in saltwater or brackish conditions',
          ],
          correctIndex: 1,
          explanation:
              'Otos feed primarily on biofilm — the thin layer of microorganisms that develops on surfaces in established tanks. A new tank has no biofilm. Adding otos to a new setup means starvation within days, no matter how much zucchini you offer.',
        ),
        const QuizQuestion(
          id: 'sc_pleco_q3',
          question: 'Why do Bristlenose plecos need driftwood in their tank?',
          options: [
            'Driftwood is where they lay their eggs',
            'They rasp wood as a dietary supplement and digestive aid',
            'Driftwood lowers pH to the level plecos require',
            'Bristlenose plecos don\'t actually need driftwood',
          ],
          correctIndex: 1,
          explanation:
              'Plecos rasp wood as a normal part of their feeding behaviour. The wood fibre contributes to digestion and provides additional nutrition. A pleco without access to driftwood may show digestive issues over time. Provide a piece of driftwood as a permanent fixture.',
        ),
      ],
    ),
  ),

  // SC-12: Gouramis
  Lesson(
    id: 'sc_gouramis',
    pathId: 'species_care',
    title: 'Gouramis & Labyrinth Fish',
    description: 'Fish that breathe air — and everything that means',
    orderIndex: 11,
    xpReward: 50,
    estimatedMinutes: 6,
    prerequisites: ['ff_choosing'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Breathing Both Ways',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Labyrinth fish — gouramis, bettas, and paradise fish — have a special organ (the labyrinth organ) that lets them breathe atmospheric air. They supplement gill breathing by gulping air at the surface. This adaptation evolved in the low-oxygen, warm, slow waters of Southeast Asia. In an aquarium, it means the space between the water surface and the tank lid matters.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'Always leave a warm air gap between the water surface and the lid. The air above the water must be warm (same temperature as the tank water). Cold draughts above the water surface — from open windows, air conditioning, or a loose lid — can cause severe respiratory illness. This is how many bettas and gouramis develop recurring infections.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Species Overview',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Dwarf gourami (Trichogaster lalius) — 5cm, peaceful, community tank star. Available in blue, flame, neon varieties. Vulnerable to DGIV (see warning below).\n• Honey gourami (T. chuna) — slightly smaller, even more peaceful, golden-orange when mature. Excellent beginner choice.\n• Pearl gourami (T. leerii) — 10cm, one of the most beautiful freshwater fish. Community safe, prefers planted tanks.\n• Three-spot gourami (T. trichopterus) — 12cm, semi-aggressive especially with smaller fish. Males can be nippy.\n• Giant gourami (Osphronemus goramy) — up to 70cm. Pond/public aquarium fish, not suitable for home tanks.',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Dwarf Gourami Iridovirus (DGIV) is a viral disease endemic in farmed dwarf gouramis from Southeast Asia. There is no cure and no test available for hobbyists. Many fish shops unknowingly stock infected fish. Symptoms: progressive lethargy, loss of colour, refusal to eat, wasting. Buy from specialist breeders where possible and always quarantine new fish.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Tank Setup for Gouramis',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Floating plants (Salvinia, frogbit) — reduce surface light intensity, create refuge areas\n• Planted tank with caves and sight breaks — reduces territorial aggression between males\n• Calm water flow — strong current stresses labyrinth fish and makes it harder to surface for air\n• Temperature: 24–28°C for most species\n• pH: 6.0–7.5\n• One male per tank for dwarf gouramis in smaller setups',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Male gouramis of many species build bubble nests at the water surface using plant material or foam bubbles. Even without a female present, a healthy, comfortable male will build nests. Seeing a bubble nest is a reliable sign your gourami is happy with his environment.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'The Giant Gourami is a major food fish across Southeast Asia, farmed in huge numbers. In the wild it can reach 70cm and live over 20 years. The same family as the delicate 5cm dwarf gourami sold in every fish shop.',
      ),
    ],
    quiz: Quiz(
      id: 'sc_gouramis_quiz',
      lessonId: 'sc_gouramis',
      questions: [
        const QuizQuestion(
          id: 'sc_gour_q1',
          question: 'Why must labyrinth fish always have access to the water surface?',
          options: [
            'They feed exclusively at the surface and cannot reach food elsewhere',
            'They breathe atmospheric air using their labyrinth organ and will suffocate without surface access',
            'Surface access regulates their body temperature',
            'They need to see natural light from above to remain healthy',
          ],
          correctIndex: 1,
          explanation:
              'Labyrinth fish (gouramis, bettas) breathe atmospheric air as a supplement to gill breathing. If they cannot access the surface — blocked by a tight lid, equipment, or floating debris — they will drown. Always ensure clear surface access.',
        ),
        const QuizQuestion(
          id: 'sc_gour_q2',
          question: 'What is Dwarf Gourami Iridovirus (DGIV)?',
          options: [
            'A curable bacterial infection that responds to standard antibiotic treatment',
            'An incurable viral disease endemic in many farm-raised dwarf gouramis',
            'A white spot parasite similar to ich that affects gouramis specifically',
            'A nutritional deficiency caused by incorrect diet',
          ],
          correctIndex: 1,
          explanation:
              'DGIV is a viral disease with no known cure. It\'s widespread in farmed dwarf gouramis from Southeast Asia. Infected fish gradually waste away. Prevention is the only strategy: quarantine, buy from reputable breeders, and consider honey gouramis as a more disease-resistant alternative.',
        ),
        const QuizQuestion(
          id: 'sc_gour_q3',
          question: 'Why do gouramis prefer calm water flow in their tank?',
          options: [
            'Strong current prevents bubble nest building and is contrary to their natural slow-water habitat',
            'Fast flow reduces the oxygen levels they need from the water',
            'Gouramis are too physically small to swim against any current',
            'Current causes physical fin damage to gouramis specifically',
          ],
          correctIndex: 0,
          explanation:
              'Gouramis evolved in slow-moving or still waters (rice paddies, marshes, slow rivers) in Southeast Asia. Strong currents prevent natural behaviour including bubble nest building, stress them physiologically, and make it harder to access the surface for air. Use gentle filtration flow.',
        ),
      ],
    ),
  ),

  // SC-13: Loaches
  Lesson(
    id: 'sc_loaches',
    pathId: 'species_care',
    title: 'Loaches: Active Bottom Dwellers',
    description: 'The comedians of the aquarium — social, quirky, and fascinating',
    orderIndex: 12,
    xpReward: 50,
    estimatedMinutes: 6,
    prerequisites: ['ff_choosing', 'eq_substrate'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'The Comedians of the Aquarium',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Loaches are endlessly entertaining. They pile on top of each other in caves, wedge themselves into impossibly tight gaps, play in filter outflows, and some species (notably clown loaches) make audible clicking sounds audible from outside the tank. They\'re among the most personable fish in the hobby — curious, bold, and surprisingly interactive with their keepers.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Kuhli loach (Pangio kuhlii) — snake-like, 8–12cm, burrows through substrate. School of 6+.\n• Clown loach (Chromobotia macracanthus) — striking orange and black, grows to 30cm. Long-lived (25+ years). Needs very large tank.\n• Yoyo loach (Botia almorhae) — 12–15cm, bold pattern, active mid-water swimmer for a loach. School of 5+.\n• Hillstream loach — flat, fast-water adapted, clings to glass and rocks. Needs high-oxygen, cooler water.\n• Zebra loach (Botia striata) — 8–10cm, striking bold stripes, excellent community loach.',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Clown loaches are one of the most commonly mis-purchased fish. Sold at 4–5cm, they grow to 30cm and live 25+ years. A proper clown loach setup requires a 300L+ tank and a school of 5+. A single clown loach in a 60L tank will live a miserable life. Consider yoyo or zebra loaches instead.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Substrate and Hiding',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Kuhli loaches must burrow. Provide at least 5–7cm of fine sand and they will excavate tunnels, burrow completely, and emerge looking surprised. Without soft substrate, kuhli loaches stress severely and spend their lives hiding motionlessly rather than displaying natural behaviour. All loaches benefit from extensive hiding spots — caves, pipes, driftwood arches, dense plant cover.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'Most loaches have very small scales or are scaleless and are exceptionally sensitive to ich treatments and aquarium salt. When treating a tank containing loaches, use quarter-strength medication dose and monitor closely. Salt should be avoided entirely with loaches.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Temperature and Parameters',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Most loaches: 24–28°C, soft to medium hardness, pH 6.5–7.5\n• Hillstream loaches: exception — need 18–22°C, very high dissolved oxygen, fast-flow areas (powerhead against a flat surface of smooth rocks)\n• Kuhli loaches: prefer 24–28°C, benefit from tannins and soft water\n• Yoyo and clown loaches: 26–30°C, softer water preferred',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'Kuhli loaches were long thought to be nocturnal. In reality, their "nocturnal" behaviour is largely a stress response to feeling exposed. In a well-planted tank with plenty of hiding spots and a soft substrate to burrow into, kuhli loaches are active throughout the day. They were just hiding because they felt vulnerable, not because they prefer darkness.',
      ),
    ],
    quiz: Quiz(
      id: 'sc_loaches_quiz',
      lessonId: 'sc_loaches',
      questions: [
        const QuizQuestion(
          id: 'sc_loach_q1',
          question:
              'Why are Clown Loaches considered unsuitable for most home aquariums?',
          options: [
            'They are highly aggressive and attack other fish',
            'They grow to 30cm and live 25+ years, requiring a very large tank and school',
            'They are extremely delicate and difficult to keep healthy',
            'They eat all other fish in the tank regardless of size',
          ],
          correctIndex: 1,
          explanation:
              'Clown loaches are sold at 4–5cm but grow to 30cm over several years, living 25+ years with good care. They\'re highly social and need groups of 5+. A proper setup requires 300L+. Most home aquariums cannot provide what they need for the decades of life ahead of them.',
        ),
        const QuizQuestion(
          id: 'sc_loach_q2',
          question:
              'Why are loaches especially vulnerable to standard ich treatments?',
          options: [
            'Ich specifically targets loach species and infects them more severely',
            'Loaches lack traditional scales, making them highly sensitive to many medications',
            'Loaches absorb all chemicals primarily through their mouth while bottom feeding',
            'Standard ich treatments are always safe — dose as directed regardless of fish',
          ],
          correctIndex: 1,
          explanation:
              'Most loaches have tiny embedded scales or are scaleless, meaning they absorb medications through their skin more readily than scaled fish. Standard medication doses can be lethal. Always use quarter-strength medication with loaches and remove salt from the treatment protocol entirely.',
        ),
        const QuizQuestion(
          id: 'sc_loach_q3',
          question:
              'What does a Kuhli loach need to display natural behaviour?',
          options: [
            'Strong current and open swimming space in the midwater',
            'At least 5–7cm of fine sand to burrow into',
            'Brackish water with added sea salt',
            'A solo territory without other fish nearby',
          ],
          correctIndex: 1,
          explanation:
              'Kuhli loaches are natural burrowers. Fine sand of adequate depth allows them to tunnel, burrow completely, and emerge naturally throughout the day. Without it, they stress, hide motionlessly, and rarely display their actual personality. Sand depth is the single most important aspect of kuhli loach care.',
        ),
      ],
    ),
  ),
];
