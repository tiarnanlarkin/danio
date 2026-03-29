/// Lesson content - Species Care
/// Part of the lazy-loaded lesson system
library;

import '../../models/learning.dart';
import '../../models/user_profile.dart';

final speciesCarePath = LearningPath(
  id: 'species_care',
  title: 'Species-Specific Care',
  description: 'Deep dives into popular fish species and their unique needs',
  emoji: '🐠',
  recommendedFor: [ExperienceLevel.beginner, ExperienceLevel.intermediate],
  orderIndex: 7,
  lessons: [
    Lesson(
      id: 'sc_betta',
      pathId: 'species_care',
      title: 'Betta Fish Care',
      description:
          'The beautiful Siamese fighting fish — more than just a cup fish!',
      orderIndex: 0,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Betta Truth',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Bettas don\'t live in puddles! In nature, they inhabit rice paddies and slow streams. They need space, filtration, and warm water like any tropical fish.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Minimum 10 gallons (40 litres) — bigger is always better. Heated to 78-82°F (25.6-27.8°C), filtered water. No bowls!',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Male bettas are aggressive to other males and long-finned fish. Keep one male per tank or choose a sorority of females.',
        ),
      ],
      quiz: Quiz(
        id: 'sc_betta_quiz',
        lessonId: 'sc_betta',
        questions: [
          const QuizQuestion(
            id: 'sc_betta_q1',
            question: 'What is the minimum recommended tank size for a betta?',
            options: [
              '1 gallon (a bowl)',
              '2.5 gallons',
              '5 gallons (19 litres)',
              '10 gallons (40 litres)',
            ],
            correctIndex: 3,
            explanation:
                'The minimum is 10 gallons (40 litres). Bettas need heated, filtered water — a bowl is not an appropriate home.',
          ),
          const QuizQuestion(
            id: 'sc_betta_q2',
            question: 'What temperature range do bettas need?',
            options: [
              '65-70°F (18-21°C)',
              '71-75°F (22-24°C)',
              '78-82°F (25.6-27.8°C)',
              '85-90°F (29-32°C)',
            ],
            correctIndex: 2,
            explanation:
                'Bettas are tropical fish that need warm water — 78-82°F (25.6-27.8°C). Room temperature is too cold for them.',
          ),
          const QuizQuestion(
            id: 'sc_betta_q3',
            question: 'What is true about betta fish in the wild?',
            options: [
              'They live in tiny puddles',
              'They inhabit rice paddies and slow streams',
              'They live in the ocean',
              'They only live in fast-moving rivers',
            ],
            correctIndex: 1,
            explanation:
                'Contrary to the myth, bettas don\'t live in puddles. In nature, they inhabit rice paddies, marshes, and slow-moving streams across Southeast Asia.',
          ),
          const QuizQuestion(
            id: 'sc_betta_q4',
            question: 'How should you house male bettas with other fish?',
            options: [
              'Multiple males together in a large tank',
              'One male per tank or a sorority of females',
              'Always keep them completely alone',
              'With any long-finned fish',
            ],
            correctIndex: 1,
            explanation:
                'Male bettas are aggressive to other males and may attack long-finned fish. Keep one male per tank or choose a carefully managed sorority of females.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'sc_goldfish',
      pathId: 'species_care',
      title: 'Goldfish: The Misunderstood Fish',
      description: 'Goldfish are NOT beginner fish — they\'re messy giants!',
      orderIndex: 1,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Goldfish grow to 6-12 inches and live 10-20 years (not 2 weeks!). They\'re coldwater fish that need huge tanks and powerful filtration.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              '20 gallons for the first fancy goldfish, +10 gallons per additional fish. Commons and comets are pond fish that grow to 12"+ and should not be kept in typical home aquariums.',
        ),
      ],
      quiz: Quiz(
        id: 'sc_goldfish_quiz',
        lessonId: 'sc_goldfish',
        questions: [
          const QuizQuestion(
            id: 'sc_gold_q1',
            question: 'How large can goldfish grow?',
            options: [
              '1-2 inches',
              '3-4 inches',
              '6-12 inches',
              '24 inches',
            ],
            correctIndex: 2,
            explanation:
                'Goldfish grow to 6-12 inches depending on variety. They\'re not small fish — commons and comets can reach 12+ inches and are really pond fish.',
          ),
          const QuizQuestion(
            id: 'sc_gold_q2',
            question: 'How long can goldfish live with proper care?',
            options: [
              '2-4 weeks',
              '1-2 years',
              '10-20 years',
              '50+ years',
            ],
            correctIndex: 2,
            explanation:
                'With proper care, goldfish live 10-20 years. The "dies in a week" myth comes from keeping them in tiny, unfiltered bowls.',
          ),
          const QuizQuestion(
            id: 'sc_gold_q3',
            question: 'How much tank space does the first fancy goldfish need?',
            options: [
              '5 gallons',
              '10 gallons',
              '20 gallons',
              '50 gallons',
            ],
            correctIndex: 2,
            explanation:
                'The first fancy goldfish needs 20 gallons, plus 10 additional gallons per extra fish. They produce a lot of waste and need powerful filtration.',
          ),
          const QuizQuestion(
            id: 'sc_gold_q4',
            question: 'What type of water do goldfish need?',
            options: [
              'Warm tropical water (80°F+)',
              'Coldwater — no heater needed',
              'Brackish water',
              'Very soft, acidic water',
            ],
            correctIndex: 1,
            explanation:
                'Goldfish are coldwater fish. They don\'t need a heater and actually prefer cooler temperatures than tropical fish.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'sc_tetras',
      pathId: 'species_care',
      title: 'Tetras: Community Tank Stars',
      description: 'Peaceful schooling fish perfect for community tanks',
      orderIndex: 2,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Neons vs Cardinals',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Neon tetras and cardinal tetras look similar — both have the iconic blue-and-red stripe — but there are key differences. Neons are hardier, cheaper, and more forgiving of water parameters. Cardinals are slightly larger, more vibrant (the red runs the full length of the body), but need softer, more acidic water to truly thrive.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'For beginners: start with neon tetras. For a mature, soft-water planted tank: cardinals are stunning. Never mix both species in the same school — they won\'t form cohesive groups.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Schooling Rules',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Tetras are schooling fish and must be kept in groups of at least 6 — ideally 10 or more. Fewer fish means stress, hiding, and sometimes aggression (nipping). A proper school moves together, shows bolder colouration, and is far more confident in the tank.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Water: pH 6.0–7.0, temperature 72–80°F (22–27°C)\n• Tank mates: corydoras, small rasboras, peaceful dwarf gouramis\n• Diet: varied — quality flake food + frozen brine shrimp or daphnia\n• Tank size: 10 gallon minimum for a school',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Neon Tetra Disease: watch for faded, blotchy patches on the body — especially where the blue stripe should be. There\'s no cure. Isolate affected fish immediately to protect the rest of the school.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Cardinal tetras are one of the most exported fish in the world — most are wild-caught from the Amazon Basin. In Brazil, the sustainable wild harvest is so profitable it protects rainforest from deforestation.',
        ),
      ],
      quiz: Quiz(
        id: 'sc_tetras_quiz',
        lessonId: 'sc_tetras',
        questions: [
          const QuizQuestion(
            id: 'sc_tet_q1',
            question: 'What is the minimum recommended school size for tetras?',
            options: [
              '2 fish',
              '4 fish',
              '6 fish',
              '12 fish',
            ],
            correctIndex: 2,
            explanation:
                'Tetras need at least 6 to form a proper school and feel secure. Fewer fish leads to stress, hiding, and potential fin-nipping.',
          ),
          const QuizQuestion(
            id: 'sc_tet_q2',
            question: 'What should you do if you notice blotchy fading on a tetra\'s body?',
            options: [
              'Raise the temperature and add salt',
              'Isolate the fish immediately — it may have Neon Tetra Disease',
              'Feed more protein-rich food',
              'Do a 90% water change',
            ],
            correctIndex: 1,
            explanation:
                'Neon Tetra Disease has no cure. Isolating affected fish immediately is the only way to protect the rest of the school.',
          ),
          const QuizQuestion(
            id: 'sc_tet_q3',
            question: 'What pH range do tetras prefer?',
            options: [
              'pH 7.8–8.5 (hard alkaline)',
              'pH 6.0–7.0 (soft acidic to neutral)',
              'pH 8.0–9.0 (very alkaline)',
              'pH 5.0–5.5 (very acidic)',
            ],
            correctIndex: 1,
            explanation:
                'Tetras are from South American rivers and prefer soft, slightly acidic water — pH 6.0–7.0. Hard alkaline water stresses them over time.',
          ),
          const QuizQuestion(
            id: 'sc_tet_q4',
            question: 'How does a cardinal tetra differ from a neon tetra?',
            options: [
              'Cardinals are smaller and cheaper',
              'Cardinals have red colouring on only the lower half of the body',
              'Cardinals have full-length red colouring and are more vibrant but less hardy',
              'Cardinals are freshwater fish; neons are saltwater',
            ],
            correctIndex: 2,
            explanation:
                'Cardinals are more vibrant — red runs the full body length — but they need softer, more acidic water and are less forgiving for beginners than neons.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'sc_cichlids',
      pathId: 'species_care',
      title: 'Cichlids: Personality Fish',
      description: 'From peaceful Rams to aggressive Oscars',
      orderIndex: 3,
      xpReward: 50,
      estimatedMinutes: 7,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'African vs South American Cichlids',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Cichlids split into two very different worlds. African cichlids (from Lakes Malawi, Tanganyika, and Victoria) need hard, alkaline water — pH 7.8–8.6. They\'re aggressive, colourful, and need caves and rockwork. South American cichlids (rams, discus, angels, oscars) prefer softer, slightly acidic water and are generally less aggressive — though Oscars can be seriously rowdy.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Never mix African and South American cichlids. Their water chemistry requirements are incompatible — one group will always be stressed.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Tank Size Matters',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Africans need a minimum of 55 gallons — the extra space dilutes aggression. South American species range from 30 gallons for dwarf cichlids (rams, apistogrammas) up to 75+ gallons for Oscars, which grow to 12–14 inches. Don\'t let a fish shop sell you a "small" Oscar for a 20-gallon tank.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• African cichlids: pH 7.8–8.6, 55 gal+, rock caves, slight overstocking reduces aggression\n• Dwarf SA cichlids (rams): pH 6.0–7.2, 30 gal+, driftwood and plants\n• Oscars: pH 6.5–7.5, 75 gal+, grow fast, very messy — need heavy filtration',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Aggression management for Africans: break lines of sight with rocks, keep fish of similar size, and slightly overstock. Counterintuitively, more fish means aggression is spread across the group rather than focused on one target.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Do not mix African and South American cichlids. Their water parameter needs are incompatible. One group will always suffer.',
        ),
      ],
      quiz: Quiz(
        id: 'sc_cichlids_quiz',
        lessonId: 'sc_cichlids',
        questions: [
          const QuizQuestion(
            id: 'sc_cich_q1',
            question: 'What water parameters do African cichlids need?',
            options: [
              'Soft, acidic water — pH 5.5–6.5',
              'Neutral water — pH exactly 7.0',
              'Hard, alkaline water — pH 7.8–8.6',
              'Brackish water with added salt',
            ],
            correctIndex: 2,
            explanation:
                'African cichlids from the Rift Lakes need hard, alkaline water — pH 7.8–8.6. This replicates the mineral-rich water of Lakes Malawi and Tanganyika.',
          ),
          const QuizQuestion(
            id: 'sc_cich_q2',
            question: 'What is the minimum tank size recommended for African cichlids?',
            options: [
              '10 gallons',
              '20 gallons',
              '30 gallons',
              '55 gallons',
            ],
            correctIndex: 3,
            explanation:
                'African cichlids need 55 gallons as a minimum. The extra space dilutes aggression and allows the natural territorial behaviours without constant fighting.',
          ),
          const QuizQuestion(
            id: 'sc_cich_q3',
            question: 'Why should you never mix African and South American cichlids?',
            options: [
              'They look too similar and will breed',
              'Their water chemistry requirements are incompatible',
              'African cichlids will always eat South American ones',
              'They can\'t be purchased from the same store',
            ],
            correctIndex: 1,
            explanation:
                'Africans need hard, alkaline water; South Americans need softer, more acidic water. Setting a compromise means both groups are stressed.',
          ),
          const QuizQuestion(
            id: 'sc_cich_q4',
            question: 'For African cichlids, how does overstocking help manage aggression?',
            options: [
              'More fish means less oxygen for fighting',
              'Aggression is spread across the group instead of targeting one fish',
              'Overcrowding makes cichlids too tired to fight',
              'It doesn\'t help — overstocking always makes aggression worse',
            ],
            correctIndex: 1,
            explanation:
                'With African cichlids, slight overstocking spreads aggression across many targets rather than letting one fish be relentlessly bullied. Combined with rock caves and sight breaks, it works.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'sc_shrimp',
      pathId: 'species_care',
      title: 'Shrimp Keeping',
      description: 'Tiny cleanup crew with surprising complexity',
      orderIndex: 4,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Cherry Shrimp vs Amano Shrimp',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Cherry shrimp (Neocaridina) are the perfect beginner shrimp. They\'re hardy, accept a wide range of parameters, come in dozens of colour morphs (red, orange, yellow, blue, black), and breed readily in a healthy tank. Amano shrimp are larger (2 inches), transparent, and are the single best algae eaters in freshwater — but they won\'t breed in freshwater, so the colony won\'t grow.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Target parameters for cherry shrimp: TDS 150–250, pH 6.5–7.5, GH 6–8. They\'re forgiving — but consistency matters more than perfection. Sudden changes kill shrimp faster than stable "imperfect" water.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              '⚠️ COPPER KILLS SHRIMP. Never use copper-based medications (many ich treatments contain copper) in a shrimp tank. Check every product label before adding anything to the water.',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Shrimp need a fully cycled tank. Ammonia and nitrite will kill them instantly — they have no tolerance at all. Even small ammonia spikes that fish can handle will wipe out shrimp. Always cycle fully before adding them.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Cherry shrimp will breed on their own in a healthy, established tank with hiding spots (moss, dense plants). A small colony can grow to hundreds in a few months — a great sign your tank is thriving.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Cleanup crew role: algae grazing, biofilm, uneaten food\n• Safe tank mates: small tetras, rasboras, corydoras, snails\n• Avoid: angelfish, bettas (may eat shrimp), any copper medications\n• Minimum tank: 5 gallons for a shrimp-only setup',
        ),
      ],
      quiz: Quiz(
        id: 'sc_shrimp_quiz',
        lessonId: 'sc_shrimp',
        questions: [
          const QuizQuestion(
            id: 'sc_shrimp_q1',
            question: 'Why is copper so dangerous in a shrimp tank?',
            options: [
              'It makes the water turn blue',
              'Copper is lethal to shrimp even at low concentrations',
              'It prevents shrimp from breeding',
              'It only affects Crystal Red shrimp, not cherries',
            ],
            correctIndex: 1,
            explanation:
                'Copper is toxic to invertebrates including shrimp. Even trace amounts in medications can wipe out an entire colony. Always check product labels before adding anything to a shrimp tank.',
          ),
          const QuizQuestion(
            id: 'sc_shrimp_q2',
            question: 'What is the recommended TDS range for cherry shrimp?',
            options: [
              '50–100',
              '150–250',
              '350–500',
              '600–800',
            ],
            correctIndex: 1,
            explanation:
                'Cherry shrimp do best with TDS 150–250. Too low means insufficient minerals; too high stresses them. This range supports healthy moulting and breeding.',
          ),
          const QuizQuestion(
            id: 'sc_shrimp_q3',
            question: 'Why won\'t Amano shrimp breed in your freshwater tank?',
            options: [
              'Amano shrimp are all male',
              'They need brackish or marine water for their larvae to develop',
              'They only breed in water above 90°F',
              'Amano shrimp reproduce asexually and don\'t need a mate',
            ],
            correctIndex: 1,
            explanation:
                'Amano shrimp larvae need brackish or marine conditions to survive — which your freshwater tank can\'t provide. This means your Amano colony won\'t grow without purchasing more.',
          ),
          const QuizQuestion(
            id: 'sc_shrimp_q4',
            question: 'Why do shrimp require a fully cycled tank more strictly than fish?',
            options: [
              'Shrimp create more ammonia than fish',
              'Shrimp have zero tolerance for ammonia and nitrite — even small amounts are lethal',
              'Shrimp need the bacteria from cycling as a food source',
              'It\'s just a recommendation, not a strict requirement',
            ],
            correctIndex: 1,
            explanation:
                'Unlike fish which can tolerate brief ammonia spikes, shrimp will die even at trace levels. A fully cycled tank with zero ammonia and nitrite is non-negotiable before adding shrimp.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'sc_snails',
      pathId: 'species_care',
      title: 'Snails: Cleanup Crew',
      description:
          'Algae eaters that won\'t overrun your tank (if chosen right!)',
      orderIndex: 5,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Three Main Types',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Nerite snails are the gold standard for algae control. They eat virtually every type of algae, won\'t breed in freshwater (need brackish conditions for larvae), and stay small (1 inch). The catch: they lay tiny white eggs on every hard surface — glass, rocks, driftwood. Annoying but harmless.',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Mystery snails (also called apple snails) are larger, more decorative, and can breed in freshwater — though slowly. They\'re peaceful and add character. Malaysian Trumpet Snails (MTS) are tiny cone-shaped snails that burrow through substrate, which actually aerates it and prevents compaction. They reproduce rapidly, but are rarely a problem in a well-maintained tank.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'MTS population explosion is almost always a sign of overfeeding. Cut back on food and the population naturally drops. They\'re feeding on excess — not causing the problem.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Nerite: best algae eater, won\'t breed in freshwater, lays white eggs on surfaces\n• Mystery: decorative, can breed, moderate bioload\n• MTS: substrate aerators, rapid breeders, indicator of overfeeding\n• Pest snails (bladder/pond): hitchhike on plants, reproduce fast — quarantine new plants!',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Pest snail management: reduce feeding first, then try assassin snails (Clea helena) — they hunt and eat other snails without touching plants or bothering fish.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Snails need calcium for healthy shells. In soft water, shells become pitted and thin. Add a small piece of cuttlebone or crushed coral to boost calcium levels.',
        ),
      ],
      quiz: Quiz(
        id: 'sc_snails_quiz',
        lessonId: 'sc_snails',
        questions: [
          const QuizQuestion(
            id: 'sc_snail_q1',
            question: 'Why won\'t Nerite snails breed in your freshwater tank?',
            options: [
              'Nerite snails are all the same sex',
              'They need brackish or marine water for their larvae to survive',
              'Nerites only breed in water above 85°F',
              'They eat their own eggs',
            ],
            correctIndex: 1,
            explanation:
                'Nerite larvae need brackish or marine conditions — which freshwater tanks can\'t provide. This makes them ideal: great algae control, no population explosion.',
          ),
          const QuizQuestion(
            id: 'sc_snail_q2',
            question: 'What does a Malaysian Trumpet Snail population explosion usually indicate?',
            options: [
              'The tank water is too cold',
              'The tank is overfeeding — MTS thrive on excess food',
              'The filter is broken',
              'The pH is too high',
            ],
            correctIndex: 1,
            explanation:
                'MTS eat uneaten food and detritus. A population explosion means there\'s excess food in the tank. Cut back on feeding and numbers will drop naturally.',
          ),
          const QuizQuestion(
            id: 'sc_snail_q3',
            question: 'Why do snails need calcium in their water?',
            options: [
              'Calcium makes snails more active',
              'Calcium is needed for shell growth and health — low calcium causes shell deterioration',
              'Calcium prevents snail reproduction',
              'Calcium is only needed for fish, not snails',
            ],
            correctIndex: 1,
            explanation:
                'Snail shells are made of calcium carbonate. In soft, low-calcium water, shells become thin, pitted, and cracked. Cuttlebone or mineral supplements help.',
          ),
          const QuizQuestion(
            id: 'sc_snail_q4',
            question: 'What is the best natural method to control pest snail populations?',
            options: [
              'Add a strong chemical treatment to kill all snails',
              'Reduce feeding and add assassin snails',
              'Remove all plants from the tank',
              'Raise the pH to 9.0',
            ],
            correctIndex: 1,
            explanation:
                'Reducing feeding removes the food source that sustains the population. Assassin snails (Clea helena) actively hunt pest snails without harming plants or community fish.',
          ),
        ],
      ),
    ),
  ],
);
