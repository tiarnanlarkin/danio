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
      prerequisites: ['br_breeding_tank', 'at_breeding_egg_layers'],
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
  ],
);
