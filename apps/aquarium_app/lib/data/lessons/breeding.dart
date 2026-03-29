/// Lesson content - Breeding Basics Path
/// New path added in Phase 5
library;

import '../../models/learning.dart';
import '../../models/user_profile.dart';

final breedingBasicsPath = LearningPath(
  id: 'breeding_basics',
  title: 'Breeding Basics',
  description:
      'Successfully breed fish in a home aquarium — from egg layers to livebearers',
  emoji: '🥚',
  recommendedFor: [
    ExperienceLevel.intermediate,
  ],
  orderIndex: 10,
  lessons: [
    // BR-1: Setting Up a Breeding Tank
    Lesson(
      id: 'br_breeding_tank',
      pathId: 'breeding_basics',
      title: 'Setting Up a Breeding Tank',
      description: 'Everything you need before your fish spawn',
      orderIndex: 0,
      xpReward: 60,
      estimatedMinutes: 6,
      prerequisites: ['nc_how_to', 'ff_quarantine'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Why a Separate Breeding Tank?',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Most fish eat their eggs and fry. In a community tank, successful reproduction is rare — eggs are eaten within hours, and free-swimming fry are eliminated within days. A dedicated breeding tank separates adults from their spawn, lets you control conditions precisely, and creates a safe space for raising young fish to a size where they can hold their own.',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Even species that guard their eggs (cichlids, bettas) benefit from the isolation of a breeding tank. Without competition from other community fish, spawning pairs are less stressed, eggs are better protected, and the keeper can observe and intervene if needed.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Tank size: 40–60L for most species. Smaller is easier to control.\n• Substrate: bare bottom (essential for egg observation and hygiene)\n• Filter: sponge filter only — no power filter intakes that can eat eggs or fry\n• Flow: gentle — sponge filter creates the right level\n• Heater: adjustable submersible\n• Lighting: low-moderate (reduce stress)\n• Spawning media: depends on species (see conditioning section)',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Conditioning Your Breeding Pair',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Conditioning means bringing fish to peak reproductive health before attempting to spawn them. A fish in poor condition won\'t spawn, and even if it does, egg quality will be poor. Conditioning takes 2–4 weeks of intensive feeding with high-quality foods.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Live foods: baby brine shrimp, micro worms, daphnia, blackworms\n• Frozen foods: bloodworms, brine shrimp, daphnia, cyclops\n• Feeding frequency: 2–3 times daily (more than the standard once daily)\n• Water quality: pristine — 20% changes every 2 days during conditioning\n• Separate the pair for 1–2 weeks before introducing them, if possible',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Spawning Triggers',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fish spawn in response to environmental cues that signal the right season — typically the rainy season in tropical species. You can simulate these cues in the aquarium to trigger breeding behaviour.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Temperature increase: raise by 1–2°C above normal — simulates pre-season warming\n• Large cool water change: 30–50% with slightly cooler water — simulates rainfall\n• Increased live food feeding: protein surge mimics the food abundance of the wet season\n• Longer photoperiod: 10–12 hours simulates summer days\n• Introducing pair: after separate conditioning, introducing a conditioned pair often triggers immediate spawning',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Fry food progression: Day 1–7 (just hatched): infusoria or commercial "first bites" fry powder — fry mouths are too small for anything larger. Week 2–4: baby brine shrimp nauplii (hatched fresh daily). Month 1+: micro pellets, finely crushed flake. This progression matches mouth size development.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Set up a culture of infusoria before spawning. Add a small piece of lettuce, banana skin, or grass to a jar of tank water — leave it in a warm, light spot. Within 2–3 days, microscopic organisms multiply. Add drops to the fry tank daily for the first week.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Siamese fighting fish (bettas) are one of very few fish species where the male provides active parental care. He builds a bubble nest, entices the female to spawn beneath it, collects falling eggs in his mouth, and places them in the nest. He then guards the nest aggressively until the fry are free-swimming — sometimes for 2–3 days without eating.',
        ),
      ],
      quiz: Quiz(
        id: 'br_breeding_tank_quiz',
        lessonId: 'br_breeding_tank',
        questions: [
          const QuizQuestion(
            id: 'br_tank_q1',
            question:
                'Why is a bare-bottom breeding tank preferred over a substrate?',
            options: [
              'Bare bottom keeps the water warmer, which fish need for spawning',
              'It allows easy egg observation, simpler cleaning, and no substrate to harbour bacteria near eggs',
              'Bare bottom tanks cycle faster and are ready sooner',
              'Fish only spawn successfully on bare glass surfaces',
            ],
            correctIndex: 1,
            explanation:
                'Bare bottom breeding tanks make eggs immediately visible (allowing monitoring), make the tank easy to clean thoroughly between uses, and eliminate substrate that can trap uneaten food and bacteria near vulnerable eggs and fry.',
          ),
          const QuizQuestion(
            id: 'br_tank_q2',
            question:
                'What is the most appropriate first food for newly hatched fry?',
            options: [
              'Finely crushed adult fish flake food',
              'Small pellet food broken into pieces',
              'Infusoria or commercial first bites powder — baby brine shrimp follows within a week',
              'Full-sized adult brine shrimp',
            ],
            correctIndex: 2,
            explanation:
                'Newly hatched fry have tiny mouths. Infusoria (microscopic organisms) and commercial fry powder are small enough to be ingested. Baby brine shrimp nauplii are introduced in week 2 once fry grow. Larger foods cannot be eaten and instead foul the water.',
          ),
          const QuizQuestion(
            id: 'br_tank_q3',
            question:
                'Which of the following is a common spawning trigger for tropical fish?',
            options: [
              'Reducing feeding to nothing for 2 weeks before spawning',
              'A temperature rise combined with a large water change with slightly cooler water',
              'Turning off filtration for 48 hours',
              'Adding salt to the breeding tank',
            ],
            correctIndex: 1,
            explanation:
                'Many tropical fish evolved in environments where temperature rises and then cool rainfall triggers the breeding season. A warm conditioning period followed by a large cool water change simulates this seasonal cue and often triggers spawning within 24–48 hours.',
          ),
        ],
      ),
    ),

    // BR-2: Raising Fry
    Lesson(
      id: 'br_raising_fry',
      pathId: 'breeding_basics',
      title: 'Raising Fry: From Hatch to Juvenile',
      description: 'The first weeks — the most fragile and most critical',
      orderIndex: 1,
      xpReward: 60,
      estimatedMinutes: 6,
      prerequisites: ['br_breeding_tank'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Most Fragile Stage',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'The first two weeks of fry life are the critical period. Tiny fry produce waste that degrades water quality rapidly — but water changes must be extremely gentle to avoid damaging or losing fry. Daily small water changes with slow, controlled siphoning are essential. This is time-intensive but forms the backbone of successful fry raising.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Egg stage (1–3 days): do not disturb. Remove any white (unfertilised) eggs promptly.\n• Wriggler/yolk-sac stage (2–4 days after hatching): fry absorb their yolk sac. Do not feed yet — they\'re not eating.\n• Free-swimming stage (begins when fry swim horizontally): start feeding immediately.\n• Juvenile (4–8 weeks): recognisable as miniature adults, eating normal small foods.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Feeding Fry',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fry require frequent feeding — 3–5 small feeds daily. Their digestive systems are undeveloped and they need constant food availability to grow. Leftover food must be removed after 30 minutes to prevent water quality crashes.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Week 1–2: infusoria, first bites powder, egg yolk paste (tiny amounts)\n• Week 2–4: baby brine shrimp nauplii — hatch fresh daily from brine shrimp eggs + saltwater\n• Week 4–8: micro pellets, finely crushed quality flake, chopped frozen foods\n• Week 8+: standard small fish foods, transitioning to adult diet',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Water Changes for Fry',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fry tanks need frequent small water changes — 10–15% daily. The challenge: standard gravel vacs and siphons will kill fry. Use a length of airline tubing with your finger over one end to control suction precisely. Siphon debris from the tank floor slowly and carefully, scanning the area first to ensure no fry are in the suction path.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Never use a gravel vacuum or standard siphon near fry — you will accidentally suck them up. Even a brief blockage while trying to remove a fry from a siphon tube can be fatal. Use airline tube with controlled flow only. Over a bucket, not a drain.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Growth Rate and Temperature',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Growth rate is temperature-sensitive. Warmer water accelerates metabolism and growth — 27–28°C in the fry tank speeds development compared to 24°C. Keep the heater running consistently; temperature fluctuations stress fry more than they stress adults. Good nutrition and warm, stable water are the two biggest drivers of rapid, healthy growth.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'When to Move Fry to the Community Tank',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'The rule of thumb: fry are ready to move when they\'re too large to fit into any existing tank mate\'s mouth. For most community fish this means 2–2.5cm. Livebearer fry (guppies, platys) can move earlier if the main tank has dense floating cover — 1–1.5cm is usually safe with floating plants providing refuge.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Grow out fry of fast-growing species (guppies, swordtails) in a separate container from slower growers (cichlids, bettas). Size variation between siblings means larger fry will eat smaller siblings. Size-grading groups keeps mortality low.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Discus (Symphysodon sp.) are one of the very few fish to nurse their young in a mammal-like way. Both parents secrete a specialised protein-rich mucus from their skin that newly hatched fry feed from directly. The fry swarm over their parents\' bodies, feeding on the mucus for the first 10–14 days of life.',
        ),
      ],
      quiz: Quiz(
        id: 'br_fry_quiz',
        lessonId: 'br_raising_fry',
        questions: [
          const QuizQuestion(
            id: 'br_fry_q1',
            question:
                'Why should you wait before feeding newly hatched fry?',
            options: [
              'Fry don\'t require any food for the first full week',
              'Newly hatched fry have a yolk sac to absorb — feeding during this wriggler stage wastes food and dirties water',
              'Early feeding disrupts the remaining eggs from hatching',
              'Fry cannot see food items until their eyes fully develop at 2 weeks',
            ],
            correctIndex: 1,
            explanation:
                'Fish fry hatch with a yolk sac attached that provides all nutrition for the first 2–4 days. They\'re not eating — they\'re absorbing. Only once they become free-swimming (swim horizontally) should feeding begin. Feeding wrigglers just pollutes the water.',
          ),
          const QuizQuestion(
            id: 'br_fry_q2',
            question:
                'What is the safest water change method for a fry tank?',
            options: [
              'Full gravel vacuum as normal — fry are tougher than they look',
              'A slow siphon with airline tubing with flow controlled by a finger',
              'Remove 50% of the tank water rapidly using a cup',
              'No water changes until fry are 4 weeks old — changes are too risky',
            ],
            correctIndex: 1,
            explanation:
                'Airline tubing with your finger controlling the suction provides a gentle, controllable siphon. You can stop flow instantly if a fry approaches, target specific debris, and avoid creating the turbulence that a standard siphon creates. 10–15% daily via this method is ideal.',
          ),
          const QuizQuestion(
            id: 'br_fry_q3',
            question:
                'When are fry generally ready to be moved to a community tank?',
            options: [
              'Once they can swim upright without sinking',
              'After 48 hours of free-swimming',
              'When they\'ve grown to approximately 2–2.5cm — too large to fit in tank mates\' mouths',
              'After exactly one month, regardless of size',
            ],
            correctIndex: 2,
            explanation:
                'The practical test for moving fry: are they too large to be eaten by the smallest carnivore in the main tank? For most community fish, 2–2.5cm is the safe threshold. Move too early and they become expensive fish food.',
          ),
        ],
      ),
    ),

    // BR-3: Egg-Layer Spawning Techniques
    Lesson(
      id: 'br_egg_layers',
      pathId: 'breeding_basics',
      title: 'Egg-Layer Spawning Techniques',
      description: 'Scatter spawners, guarders, mouthbrooders, and bubble nesters',
      orderIndex: 2,
      xpReward: 60,
      estimatedMinutes: 7,
      prerequisites: ['br_breeding_tank', 'br_raising_fry'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Four Ways to Lay Eggs',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Egg-laying fish have evolved four distinct reproductive strategies, each with different aquarium management requirements. Understanding which strategy your fish uses determines how to set up the spawning tank, when to remove adults, and how to protect the eggs.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Egg scatterers (tetras, danios, white cloud mountain minnows) — broadcast eggs randomly into plants or substrate, then immediately abandon (and eat) them. Eggs must be protected from adults instantly.\n• Egg guarders (cichlids, gobiids) — spawn on a cleaned surface, then defend eggs and fry aggressively against all comers. Parents provide the protection.\n• Mouthbrooders (many cichlid species, some bettas) — one or both parents carry eggs and fry inside the mouth for protection, sometimes for weeks.\n• Bubble nesters (bettas, most gouramis, some paradise fish) — male builds a floating nest of mucus bubbles, catches falling eggs, and guards until fry are free-swimming.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Spawning Setup for Scatter Spawners',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Scatter spawners are the easiest breeding project for beginners. Zebra danios, white cloud mountain minnows, and most tetras are scatter spawners. The challenge: they eat their own eggs immediately after spawning. The setup goal is to let eggs fall somewhere the parents can\'t reach.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Spawning mops (wool or artificial yarn) — mimic plant thickets where eggs hide in the fibres\n• Marbles on the tank floor — eggs fall between the marbles, out of adults\' reach\n• Dense Java moss or hornwort — eggs lodge in the leaves\n• Remove adults immediately after spawning is complete (within hours of first spawning)',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Fighting Egg Fungus',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Unfertilised or damaged eggs turn white and fuzzy within 24–48 hours — this is fungal infection (Saprolegnia). If not removed, it spreads to adjacent healthy eggs and can destroy an entire spawn. Manual removal with a pipette is the first line of defence. Methylene blue — a safe antifungal dye — added to the hatching water at a low dose significantly reduces fungal spread from unavoidable unfertilised eggs.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Keep the hatching tank dimly lit or covered after removing adults. Light stimulates both fungal growth on eggs and algae. A dark, warm hatching tank produces better hatch rates than a brightly lit one.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Bubble Nesters — The Betta Spawning Protocol',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Betta spawning is the most commonly attempted egg-layer project. The male must be conditioned for 2 weeks before introducing the female. Float the female in a clear container inside the male\'s tank for 2–5 days before releasing — this allows visual acclimation without contact. Spawning is dramatic: the male wraps around the female, she releases eggs, he catches falling eggs and places them in the bubble nest. This repeats for 1–2 hours.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Male builds bubble nest before (or during) courtship — healthy sign\n• After spawning: remove the female immediately — male becomes aggressive\n• Male cares for the nest — do not disturb for first 3 days\n• When fry are free-swimming (3–4 days): remove the male — his guarding instinct ends and he may eat fry\n• Begin feeding infusoria or fry powder immediately',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Corydoras — The Unique T-Position',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Corydoras have one of the strangest spawning rituals in freshwater fishkeeping. The female cleans a flat surface (glass, broad leaf, rock). During spawning, the male and female form a "T" position — the female holds the male\'s sperm vent in her mouth and swims to the chosen surface, where she presses her body and releases eggs, simultaneously using the mouth-held sperm to fertilise them. She may repeat this dozens of times over several hours.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Trigger corydoras spawning with a large cool water change (25–30% with slightly cooler water) in the evening. They often spawn overnight, and you\'ll find eggs on the glass, plants, and equipment the next morning. Move eggs to a separate hatching container immediately.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Mouthbrooding African cichlids (Mbuna, Utaka) incubate eggs in the mother\'s mouth for 3–4 weeks. During this time, the mother may eat nothing. When the fry are finally released, they remain loose in the tank but return to the mother\'s mouth at the first sign of danger for the first few weeks of life.',
        ),
      ],
      quiz: Quiz(
        id: 'br_egg_layers_quiz',
        lessonId: 'br_egg_layers',
        questions: [
          const QuizQuestion(
            id: 'br_egg_q1',
            question: 'Why are marbles used as a substrate in egg-scatter spawning tanks?',
            options: [
              'Marbles look attractive and stimulate spawning behaviour',
              'Eggs fall between the marbles and are hidden from parents who would immediately eat them',
              'Marbles regulate water temperature in the hatching area',
              'Adults prefer to spawn on hard marble surfaces specifically',
            ],
            correctIndex: 1,
            explanation:
                'Scatter spawners eat their own eggs. Marbles on the tank floor allow eggs to fall into gaps between them, out of reach of the parents hovering above. Spawning mops work on the same principle — eggs lodge in the fibres where adults can\'t easily reach them.',
          ),
          const QuizQuestion(
            id: 'br_egg_q2',
            question: 'What does methylene blue do when added to a spawning/hatching tank?',
            options: [
              'Provides essential nutrients to developing embryos',
              'Acts as an antifungal agent to reduce fungal spread from unfertilised eggs',
              'Changes the water pH to the optimal level for egg development',
              'It\'s purely decorative and has no functional purpose',
            ],
            correctIndex: 1,
            explanation:
                'Methylene blue is an antifungal dye. Unfertilised eggs inevitably appear in any spawn and immediately begin developing Saprolegnia fungus, which spreads to adjacent healthy eggs. Methylene blue inhibits this spread, significantly improving overall hatch rates.',
          ),
          const QuizQuestion(
            id: 'br_egg_q3',
            question: 'When should a female betta be removed from the spawning tank?',
            options: [
              'Before spawning begins — females should never be in the spawning tank',
              'Immediately after spawning is complete',
              'After the eggs hatch, so she can help guard the nest',
              'After the fry become free-swimming — she helps feed them',
            ],
            correctIndex: 1,
            explanation:
                'Once spawning is complete, the male becomes aggressively protective of his bubble nest and eggs. He will attack the female relentlessly. She must be removed immediately after spawning ends. Leaving her in risks serious injury or death from the male\'s aggression.',
          ),
        ],
      ),
    ),

    // BR-4: Livebearer Breeding (moved from advanced_topics)
    Lesson(
      id: 'br_livebearers',
      pathId: 'breeding_basics',
      title: 'Livebearer Breeding: Guppies, Platys & Mollies',
      description:
          'The easiest breeding project in the hobby — guppies, platys, and mollies for beginners',
      orderIndex: 3,
      xpReward: 60,
      estimatedMinutes: 7,
      prerequisites: ['br_breeding_tank'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Livebearer Family',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Guppies, mollies, platys, and swordtails are livebearers — they give birth to fully-formed, free-swimming fry instead of laying eggs. They\'re the easiest fish to breed in the hobby. In fact, the hard part isn\'t getting them to breed — it\'s everything that comes after: managing population growth, fry survival, and responsible rehoming.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Male:female ratio matters. Keep 1 male for every 2–3 females. Too many males constantly harassing females causes stress, disease, and death. A 1:1 ratio will wear females out within weeks.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Recognising a Gravid Female',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Gestation is approximately 28 days for guppies, 30–35 days for platys and mollies — varying with temperature (warmer = faster). A pregnant (gravid) female develops a dark "gravid spot" near the anal fin, caused by the eyes of developing fry showing through the thin skin. As birth approaches, the belly becomes noticeably boxy rather than rounded — this is called "squaring off" and indicates birth is imminent, usually within 24–48 hours.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Early pregnancy: slight rounding of belly, gravid spot begins to darken\n• Mid-pregnancy: obvious belly growth, gravid spot large and dark\n• Late pregnancy (days from birth): belly appears boxy/square, female may become less active\n• Imminent birth: female seeks corners or hiding spots, may stop eating briefly',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Protecting Fry from Being Eaten',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Livebearer parents — and all tank mates — will eat their own fry immediately after birth. In a community tank, fry survival without intervention approaches zero. Two main strategies exist:',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Option 1 — Breeding box: separate the female into a floating breeding box before birth. She gives birth, fry drop through a mesh away from the mother, then move the fry to a separate grow-out tank. Effective but stressful for the mother.\n• Option 2 — Dense planting: a heavily planted tank with floating plants (guppy grass, java moss, hornwort) provides enough cover that some fry survive naturally. More natural, lower stress, but lower survival rate.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Feeding Livebearer Fry',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Day 1: livebearer fry are already large enough for finely crushed flake food — no infusoria needed\n• Week 1–4: crushed flake 3–4 times daily + baby brine shrimp (BBS) when available\n• Baby brine shrimp dramatically improves growth rate — fry raised on BBS grow 30–50% faster\n• Week 4+: transition to standard small fish foods\n• Feed 3–4 times daily in small amounts — remove uneaten food after 10 minutes to prevent water quality issues',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Basic Colour Genetics (Guppies)',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'In guppies, many colour and tail patterns are carried on the Y chromosome — passed from father to son. This means the colour of your male guppy\'s father strongly predicts what his sons will look like. Selecting the most attractive males from each generation for breeding is the basis of all fancy guppy strains.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Population explosion: a single female guppy can produce 20–80 fry every 28 days. If you keep both sexes together, you will have hundreds of fish within a few months. Plan for this before you start. Have a grow-out tank ready, contact local fish shops about taking fry, or join a local aquarium club where members trade surplus fish.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Never release unwanted fry into local waterways — it is illegal in most countries and can devastate native ecosystems. Invasive guppies and mollies have already wiped out native fish populations in many regions. Rehome through fish clubs, sell to shops, or feed surplus fry to larger fish.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Female guppies can store sperm from a single mating for up to 6 months. A female purchased at a fish shop — even in an all-female tank — may already be pregnant and give birth within days of bringing her home. Most "mystery fry" from new fish purchases are explained by this stored-sperm mechanism.',
        ),
      ],
      quiz: Quiz(
        id: 'br_livebearers_quiz',
        lessonId: 'br_livebearers',
        questions: [
          const QuizQuestion(
            id: 'br_live_q1',
            question: 'What male-to-female ratio is recommended for livebearer tanks?',
            options: [
              '3 males per female for maximum breeding activity',
              '1 male per female for balanced pairing',
              '1 male per 2–3 females to prevent female harassment and stress',
              'All-female tanks — males are not needed',
            ],
            correctIndex: 2,
            explanation:
                'Keep 1 male per 2–3 females. Multiple males compete to mate, exhausting females with constant pursuit. Chronic stress leads to disease and early death. The 1:3 ratio distributes male attention across multiple females.',
          ),
          const QuizQuestion(
            id: 'br_live_q2',
            question: 'What does "squaring off" mean in a pregnant livebearer?',
            options: [
              'The female develops a checkerboard colour pattern before giving birth',
              'The female becomes territorial and defends a square area of the tank',
              'The pregnant belly becomes boxy and squared rather than round — indicating birth is imminent',
              'The female swims in a square pattern when in labour',
            ],
            correctIndex: 2,
            explanation:
                '"Squaring off" describes the visual change in a gravid female\'s belly in the final 24–48 hours before birth. Instead of a rounded belly, the sides become flat and the belly looks square or boxy as fry move into birthing position. Time to set up the breeding box.',
          ),
          const QuizQuestion(
            id: 'br_live_q3',
            question:
                'Why can a female guppy give birth even when she\'s been kept only with other females?',
            options: [
              'Female guppies reproduce asexually when no males are present',
              'Female guppies can store sperm from an earlier mating for up to 6 months',
              'All guppies are born female and some later change sex to male',
              'Females spontaneously produce fry after 6 months of age regardless',
            ],
            correctIndex: 1,
            explanation:
                'Female guppies can store viable sperm from a single mating for up to 6 months. A female bought from a shop — even an all-female display — may have mated before purchase and can produce multiple broods from that single stored sperm batch.',
          ),
        ],
      ),
    ),

    // BR-5: Fry Care and Grow-Out
    Lesson(
      id: 'br_fry_care',
      pathId: 'breeding_basics',
      title: 'Fry Care: Grow-Out and Health',
      description: 'Keeping fry healthy, growing fast, and ready for rehoming',
      orderIndex: 4,
      xpReward: 60,
      estimatedMinutes: 6,
      prerequisites: ['br_raising_fry', 'br_livebearers'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Grow-Out Tank',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'A grow-out tank is a dedicated tank for raising fry to a size where they can be moved to the community tank or rehomed. It\'s separate from the spawning/breeding tank, which is now free for the next spawn. Grow-out tanks prioritise cleanliness, stable water, and maximum growth rate over aesthetics.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Size: as large as practical — more volume means more stable water chemistry\n• Filter: mature sponge filter (seeded from existing tank) — gentle flow, safe for fry\n• Substrate: bare bottom or fine sand — easier to clean, no debris traps\n• Temperature: 27–28°C for tropical fry — slightly warmer than the adult tank to accelerate growth\n• Lighting: moderate — enough to feed by, but not so intense it causes algae problems',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Feeding for Maximum Growth',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Growth rate in fry is driven almost entirely by two things: food quality and water quality. Feed frequently with nutritious food, and maintain excellent water quality with regular small water changes. Fry raised on a varied diet of live and frozen foods reach rehomeable size weeks faster than those raised on flake alone.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Feed 3–4 times daily — fry have small stomachs, need constant food availability\n• Remove all uneaten food after 10–15 minutes — fry tanks pollute quickly\n• Vary the diet: crushed flake, micro pellets, baby brine shrimp, micro worms, daphnia\n• Egg yolk paste (hard-boiled yolk pressed through a cloth into the water) is highly nutritious for tiny fry\n• Spirulina-based foods improve colour development in species with natural green/blue colours',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Water Quality in Fry Tanks',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fry produce more waste relative to their body size than adults. Their metabolisms run hot, and they eat frequently. Ammonia accumulates faster in fry tanks than in adult tanks. Daily or every-other-day water changes of 10–20% are essential during the first 4 weeks.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Always match temperature and treat new water with dechlorinator before adding it to a fry tank. Even a small temperature mismatch (3–4°C) that an adult fish would tolerate can stress or kill fragile fry. Test the replacement water temperature against the tank before pouring.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Culling — A Difficult Reality',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Culling means humanely removing deformed or severely stunted fry from the grow-out tank. This is not cruelty — it\'s responsible husbandry. A deformed fry that cannot swim correctly, cannot eat, or has severe spinal curvature will not thrive and will suffer. Culling early prevents that suffering.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Identify cull candidates by day 3–5: bent spine (scoliosis), swim bladder issues (floating/sinking), missing eyes, severe deformities\n• Humane method: clove oil in water (5–10 drops per 500ml) — fish rapidly lose consciousness and do not recover\n• Mild deformities that don\'t impair function (slightly bent tail fin) are often acceptable — fish can live normal lives\n• Most reputable breeders cull roughly 5–15% of each spawn',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Size-grade your fry at 3–4 weeks. Sort the large, medium, and small individuals into separate containers. This prevents larger siblings from out-competing and stunting smaller ones. Size-graded groups grow more uniformly and reach rehomeable size faster overall.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Wild guppy populations in Trinidad have been studied for decades as a natural experiment in evolution. In rivers with predators (pike cichlids), guppies evolved to mature faster, produce more and smaller fry, and have drab colouring. In predator-free headwaters, the same species evolved slower maturation, fewer and larger fry, and bright male colouring. The same species — wildly different life strategies based on predation pressure.',
        ),
      ],
      quiz: Quiz(
        id: 'br_frycare_quiz',
        lessonId: 'br_fry_care',
        questions: [
          const QuizQuestion(
            id: 'br_care_q1',
            question:
                'Why are daily water changes more important in a fry grow-out tank than in an adult tank?',
            options: [
              'Fry require pure water with no dissolved minerals at all',
              'Fry produce more waste relative to body size and eat frequently, causing faster ammonia accumulation',
              'Adult fish are immune to ammonia; only fry are affected',
              'Fry produce growth hormones that pollute the water and need daily removal',
            ],
            correctIndex: 1,
            explanation:
                'Fry eat frequently and have high metabolic rates, producing proportionally more waste than adults. Combined with a small tank volume, ammonia builds rapidly. Daily 10–20% water changes maintain the pristine water quality that fast, healthy fry growth requires.',
          ),
          const QuizQuestion(
            id: 'br_care_q2',
            question:
                'What is the purpose of size-grading fry at 3–4 weeks?',
            options: [
              'Larger fry need warmer water, so they must be separated by temperature requirement',
              'To identify which fry to sell and which to keep — size indicates quality',
              'Larger fry bully and out-compete smaller siblings; separating them allows more even growth',
              'Size-grading is only done for show-quality fish, not general breeding',
            ],
            correctIndex: 2,
            explanation:
                'Size variation in a batch of fry creates a competitive hierarchy. Larger, more aggressive individuals monopolise food and space, stunting smaller siblings. Sorting into size groups levels the playing field — each fry competes with others its own size, and the overall batch grows faster and more evenly.',
          ),
          const QuizQuestion(
            id: 'br_care_q3',
            question: 'Why do many responsible breeders cull a percentage of each spawn?',
            options: [
              'To maintain the exclusive value of their fish by limiting supply',
              'Culling deformed fry prevents their suffering and prevents passing deformities to future generations',
              'Fish clubs require documented culling rates before allowing members to sell fish',
              'Culling is illegal in most countries and should never be done',
            ],
            correctIndex: 1,
            explanation:
                'Fry with severe deformities — bent spines, swim bladder disorders, missing organs — cannot live normal lives and will suffer. Humane culling early prevents extended suffering. It\'s considered responsible husbandry by the fishkeeping community, not cruelty.',
          ),
        ],
      ),
    ),

    // BR-6: Separating Fry and Rehoming
    Lesson(
      id: 'br_rehoming',
      pathId: 'breeding_basics',
      title: 'Separating Fry and Responsible Rehoming',
      description: 'When and how to move fry — and what to do with the ones you can\'t keep',
      orderIndex: 5,
      xpReward: 60,
      estimatedMinutes: 5,
      prerequisites: ['br_fry_care'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Overpopulation Reality',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Breeding fish is exciting. The first batch of fry is magical. By the sixth batch — each of 40–80 fry — the reality of aquarium keeping sets in: you will have far more fish than you can house. Planning for this before your first spawn is not pessimism, it\'s responsible fishkeeping. Having a rehoming plan is as important as having a breeding setup.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'When to Separate Fry from Adults',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Livebearer fry (guppies, platys, mollies): can go into a planted community tank once they reach 1–1.5cm — floating plants provide cover. Move to grow-out tank if you want maximum survival.\n• Egg layer fry: must stay in the breeding/fry tank until they\'re too large to be eaten — typically 2–2.5cm for community fish, larger for tanks with large predatory species.\n• General rule: a fry is safe when it cannot fit in any tank mate\'s mouth.\n• Never rush the move — a few extra weeks in the fry tank is better than losing a fry to a hungry angelfish.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Rehoming Options',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Local fish shop (LFS): most shops accept healthy, well-grown fry in exchange for store credit or cash. Call ahead — many have slow periods and won\'t accept all species.\n• Aquarium clubs: local fishkeeping clubs are an excellent outlet. Members breed, swap, and sell fish. Joining a club is one of the best things a breeder can do.\n• Online classifieds: Facebook groups, dedicated aquarium forums, and classified sites allow direct sales or donations to fellow hobbyists.\n• Fellow hobbyists: ask in online communities — someone always needs guppies or corydoras.\n• Fish swaps and auctions: club events where bags of fish are auctioned. Surplus fry sell easily at these events.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Responsible Disposal of Surplus',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Sometimes fry cannot be rehomed — you have more than the market can absorb. Options for surplus that cannot find homes:',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Feed to larger carnivorous fish (puffer fish, large cichlids, eels) — natural food chain\n• Humane culling using clove oil solution\n• Contact a local pond keeper — surplus guppies and platys are often useful as live pond food for koi\n• Schools and offices sometimes accept small, easy-care fish as a first tank gift',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'NEVER release aquarium fish into wild waterways, ponds, rivers, or drainage systems. This is illegal in most countries and has caused serious ecological damage worldwide. Guppies, mollies, and platys have colonised natural waterways across five continents after release by aquarium keepers. The damage to native ecosystems is irreversible.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Transporting Fry Safely',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Use fish bags (available from fish shops) or ziplock bags — not rigid containers for short trips\n• Fill with 1/3 tank water and 2/3 air — the air volume matters for gas exchange\n• Seal tightly and transport in an insulated bag or box to maintain temperature\n• Keep bags upright and minimise jostling\n• Trips under 2 hours: no oxygen needed. Over 2 hours: add pure oxygen before sealing if possible (fish shops can do this)\n• At the destination: float the bag for 15–20 minutes to equalise temperature, then release',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'When contacting a fish shop about taking your fry, bring them already in bags at a size the shop can immediately display — usually 2–3cm. Small fry require specialist care the shop may not have time for. Coming with ready-to-sell juveniles gets a much better response than arriving with a bag of 1-week-old fry.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'The ornamental fish trade moves approximately 1.5 billion fish worth over \$15 billion annually. A significant portion of guppies, platys, and mollies sold in pet shops across Europe and North America are captive-bred in fish farms in Southeast Asia — but local breeders selling to local shops provide fresher, often healthier fish that have never been through international shipping stress.',
        ),
      ],
      quiz: Quiz(
        id: 'br_rehoming_quiz',
        lessonId: 'br_rehoming',
        questions: [
          const QuizQuestion(
            id: 'br_reh_q1',
            question:
                'At what approximate size are livebearer fry (guppies, platys) safe to introduce to a community tank with floating plant cover?',
            options: [
              'Immediately after birth — they\'re born fully formed',
              'At 0.5cm — any larger and they\'re too territorial',
              'At 1–1.5cm with dense floating plants providing refuge',
              'Only at 4cm — smaller fish will always be eaten',
            ],
            correctIndex: 2,
            explanation:
                'Livebearer fry at 1–1.5cm with dense floating plants (guppy grass, java moss, hornwort) have a reasonable survival rate in a community tank. The plants provide shelter and break line of sight. Smaller than 1cm has poor survival; larger is safer but takes more time in the grow-out tank.',
          ),
          const QuizQuestion(
            id: 'br_reh_q2',
            question:
                'When bringing bagged fry to a new tank, why should the bag be floated for 15–20 minutes first?',
            options: [
              'To allow the fish time to adjust psychologically to the new environment',
              'To equalise the temperature between the bag water and the tank water before release',
              'Floating the bag adds oxygen to the water through the plastic',
              'It\'s a fish shop myth — you can release immediately without floating',
            ],
            correctIndex: 1,
            explanation:
                'Temperature equilibration prevents thermal shock. The bag water cools or warms to match the tank temperature over 15–20 minutes. Releasing fish directly from a bag that\'s 3–5°C different from the tank temperature stresses them and can trigger ich or other stress-related conditions.',
          ),
          const QuizQuestion(
            id: 'br_reh_q3',
            question:
                'What is the main reason releasing aquarium fish into wild waterways is prohibited?',
            options: [
              'Wild fish are territorial and will immediately attack tank-bred fish',
              'Aquarium chemicals in fish tissue poison local wildlife',
              'Introduced species can outcompete native species and cause irreversible ecological damage',
              'It is only prohibited in countries with endangered native fish',
            ],
            correctIndex: 2,
            explanation:
                'Introduced aquarium fish (and plants) are among the most damaging invasive species globally. Guppies, goldfish, suckermouth catfish, and aquatic plants have devastated native ecosystems on every inhabited continent after release by aquarium keepers. This is illegal in most countries — and for good reason.',
          ),
        ],
      ),
    ),
  ],
);
