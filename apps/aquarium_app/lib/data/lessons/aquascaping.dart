/// Lesson content - Aquascaping & Design Path
/// New path added in Phase 5
library;

import '../../models/learning.dart';
import '../../models/user_profile.dart';

final aquascapingPath = LearningPath(
  id: 'aquascaping',
  title: 'Aquascaping & Design',
  description:
      'Create stunning aquatic landscapes — from layout principles to plant placement and maintenance',
  emoji: '🌿',
  recommendedFor: [
    ExperienceLevel.intermediate,
    ExperienceLevel.expert,
  ],
  orderIndex: 9,
  lessons: [
    // AQ-1: Layout Styles
    Lesson(
      id: 'aq_layout_styles',
      pathId: 'aquascaping',
      title: 'Aquascape Layout Styles',
      description: 'Iwagumi, Dutch, and Nature Aquarium — three distinct philosophies',
      orderIndex: 0,
      xpReward: 60,
      estimatedMinutes: 7,
      prerequisites: ['at_aquascaping'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Three Paths to a Masterpiece',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Aquascaping has developed distinct design philosophies over the past 40 years, each with its own aesthetic, plant selection, and maintenance demands. The three dominant styles are Iwagumi (minimalist rock), Dutch (dense plant collection), and Nature Aquarium (organic landscape). Each requires different skills, equipment, and time investment.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Iwagumi — rocks only as hardscape, carpet grass as the single or primary plant species, stark simplicity. Requires CO2, high light, and perfect water chemistry. Any algae is immediately and brutally visible.\n• Dutch — maximum plant diversity, strict rules about plant arrangement, colour blocks, and row spacing. No hardscape. The traditional European aquascaping style originating from the Netherlands.\n• Nature Aquarium — organic landscape style. Represents forests, cliffs, hillsides, valleys. Created by Takashi Amano. Most creative freedom. The dominant modern competition style.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'For beginners: Nature Aquarium style is the most forgiving. It allows mixed plants, imperfect placement, and creative problem-solving. Iwagumi is the most visually striking but ruthlessly exposes any algae issue or balance problem — a beginner\'s mistakes become centrepiece features.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Golden Ratio in Aquascaping',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'The golden ratio (approximately 1:1.618) appears throughout nature and art as a proportion that feels naturally balanced to the human eye. In aquascaping, it\'s used to determine where focal points should sit. The golden ratio intersection point in your tank — approximately 1/3 from one side and 1/3 from the bottom — is where your focal element (primary rock, dramatic driftwood) should be placed.',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Centred compositions feel static and artificial. A focal point positioned at the golden ratio (or rule of thirds) intersection creates natural-feeling visual tension and guides the eye through the composition. Great aquascapes are designed like photographs — they\'re planned with compositional intent, not arranged randomly.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Style Maintenance Requirements',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Iwagumi: Highest maintenance. Algae on carpet grass or rocks destroys the aesthetic. Requires daily monitoring, consistent CO2, weekly large water changes.\n• Dutch: High maintenance. Rapid-growing stem plants need regular trimming (weekly). Colour and height balance must be actively managed.\n• Nature Aquarium: Moderate maintenance. More forgiving of imperfection. Larger plants hide occasional algae. Still needs regular trimming and water changes.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Photograph your aquascape straight-on at water level, not from above. Eye-level shooting reveals compositional issues — lopsided layouts, wrong plant heights, missing depth — that are invisible from the standing viewing angle.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Takashi Amano\'s large-scale aquascape photography has been exhibited in art galleries alongside paintings and sold as fine art prints. His work fundamentally changed how aquariums are viewed — not as pet enclosures, but as living art installations.',
        ),
      ],
      quiz: Quiz(
        id: 'aq_layout_quiz',
        lessonId: 'aq_layout_styles',
        questions: [
          const QuizQuestion(
            id: 'aq_lay_q1',
            question: 'What characterises the Iwagumi aquascape style?',
            options: [
              'Maximum plant diversity with no rocks or hardscape',
              'Minimalist rock-only hardscape with carpet plants as the primary vegetation',
              'Colourful fish as the centrepiece with minimal planting',
              'Driftwood forests with no rocks and dense background plants',
            ],
            correctIndex: 1,
            explanation:
                'Iwagumi uses only rocks as hardscape, with carpet grass (dwarf hairgrass, Monte Carlo, or HC Cuba) as the primary plant. The composition relies on the stone arrangement alone for visual interest. It\'s the most minimalist and demanding aquascaping style.',
          ),
          const QuizQuestion(
            id: 'aq_lay_q2',
            question: 'Why is Iwagumi the hardest style for beginners?',
            options: [
              'It requires the most expensive fish species',
              'Its minimalist design leaves algae, dead plants, and every imperfection completely exposed',
              'Iwagumi rocks are rare and extremely expensive',
              'It requires saltwater chemistry to maintain properly',
            ],
            correctIndex: 1,
            explanation:
                'Iwagumi has nowhere to hide mistakes. A single patch of algae on a clean carpet, a browning leaf, or an off-balance rock placement is immediately visible in an Iwagumi composition. There is no "cover" — every imperfection is a centrepiece feature.',
          ),
          const QuizQuestion(
            id: 'aq_lay_q3',
            question:
                'Where should your aquascape\'s focal point sit, according to the golden ratio?',
            options: [
              'Dead centre of the tank for maximum visual impact',
              'In the back corner to create depth',
              'At the golden ratio intersection — approximately 1/3 from one side',
              'Always in the front left corner',
            ],
            correctIndex: 2,
            explanation:
                'The golden ratio (and related rule of thirds) places the focal point off-centre — approximately 1/3 from one side. This creates natural visual tension and makes compositions feel organic rather than artificially posed. Centred compositions feel static.',
          ),
        ],
      ),
    ),

    // AQ-2: Plant Zones
    Lesson(
      id: 'aq_plant_zones',
      pathId: 'aquascaping',
      title: 'Plant Zones: Foreground, Mid & Background',
      description: 'The layering system that creates depth in a glass box',
      orderIndex: 1,
      xpReward: 60,
      estimatedMinutes: 7,
      prerequisites: ['aq_layout_styles', 'planted_basics'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Layers Create Depth',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'A flat glass box can look like a deep forest, a sweeping field, or an underwater cliff — purely through careful plant layering. The principle is deceptively simple: short plants at the front, medium plants in the middle, tall plants at the back. Executed well, this creates a sense of perspective and depth that makes a 60cm tank look far larger than it is.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Three Zones — Plants for Each',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Foreground / Carpet zone (0–5cm tall): Dwarf hairgrass (Eleocharis parvula), HC Cuba (Hemianthus callitrichoides), Monte Carlo (Micranthemum tweediei), Marsilea species, Java moss as ground cover\n• Midground (5–15cm): Cryptocoryne species (wendtii, parva, lucens), Anubias (attached to hardscape), stem plant groupings, Staurogyne repens\n• Background (15cm+): Vallisneria (spiralis, nana, asiatica), Amazon sword (Echinodorus), Rotala rotundifolia, Hygrophila polysperma, Bacopa monnieri',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Slow vs Fast Growers',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Mixing growth rates creates long-term maintenance problems. Fast growers (Vallisneria, Hygrophila, most stem plants) will crowd out slow growers (Anubias, Cryptocoryne, Java fern) within weeks if not managed. Either plan dedicated zones for each growth rate, or commit to frequent trimming to keep everything in balance.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'The easiest beginner aquascape: Anubias nana (attached to hardscape) + Java fern (attached to wood) + Vallisneria background. All are slow to moderate growers, require no CO2, survive in low to moderate light, and are almost impossible to kill. A beautiful, low-maintenance starting point.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'HC Cuba and most true carpet plants require high-intensity light, injected CO2, and liquid fertilisers to grow as a carpet. Without all three, they will melt within 2–4 weeks. Don\'t plant them in a low-tech setup expecting a carpet to form — it won\'t.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Attaching Plants to Hardscape',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Anubias, Java fern, Bucephalandra, and Bolbitis should never be planted in substrate — bury their rhizome and they rot. Instead, attach them to driftwood or rock using aquarium-safe superglue gel or cotton thread. The plants will naturally attach their own roots within 4–6 weeks and the thread or glue becomes irrelevant. These plants are epiphytes — substrate dwellers only by force.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Aquarium plants actually grow better fully submerged in CO2-rich water than they do emersed (above water) in air. The same species grows faster, denser, and more vibrant underwater with CO2 injection than it would as a houseplant above water. The aquarium provides near-ideal growing conditions that terrestrial environments rarely match.',
        ),
      ],
      quiz: Quiz(
        id: 'aq_zones_quiz',
        lessonId: 'aq_plant_zones',
        questions: [
          const QuizQuestion(
            id: 'aq_zone_q1',
            question: 'Which plant zone should Vallisneria be placed in?',
            options: [
              'Foreground — it stays short and creates a carpet effect',
              'Midground — for contrast with other plants',
              'Background — it grows tall and creates a rear wall of grass-like plants',
              'Floating at the surface — Vallisneria is a floating plant',
            ],
            correctIndex: 2,
            explanation:
                'Vallisneria grows tall (30–100cm+ depending on species) and is a classic background plant. Its grass-like leaves create a natural-looking rear wall and excellent shelter for fish. It\'s also one of the easiest aquarium plants to grow — hardy, fast, and undemanding.',
          ),
          const QuizQuestion(
            id: 'aq_zone_q2',
            question: 'Why does HC Cuba often melt in beginner tanks?',
            options: [
              'HC Cuba is not actually an aquatic plant and cannot survive submerged',
              'It requires high-intensity light, injected CO2, and fertilisers — without these, it melts',
              'HC Cuba needs saltwater conditions to grow as a carpet',
              'It only grows in very cold water below 18°C',
            ],
            correctIndex: 1,
            explanation:
                'HC Cuba is a high-tech plant that demands all three pillars: intense light, CO2 injection, and regular nutrient dosing. Missing any one of these causes it to deteriorate. It\'s one of the most demanding carpet plants — not for low-tech setups.',
          ),
          const QuizQuestion(
            id: 'aq_zone_q3',
            question: 'How does plant layering create the illusion of depth?',
            options: [
              'By using brighter, more colourful plants at the back of the tank',
              'Short foreground, medium midground, tall background creates natural perspective — mimicking how we perceive depth in landscapes',
              'By using plants of different leaf colours to create contrast only',
              'Depth is an optical illusion caused by water light refraction, not plant height',
            ],
            correctIndex: 1,
            explanation:
                'The layering system mimics natural perspective cues — small objects appear to be in the foreground, large objects in the background. Your brain reads the plant height gradient as spatial depth, making the tank look significantly larger than it is.',
          ),
        ],
      ),
    ),

    // AQ-3: Fertilisation
    Lesson(
      id: 'aq_fertilisation',
      pathId: 'aquascaping',
      title: 'Fertilising Your Planted Tank',
      description: 'Macros, micros, deficiencies, and the Estimative Index',
      orderIndex: 2,
      xpReward: 60,
      estimatedMinutes: 7,
      prerequisites: ['aq_plant_zones', 'planted_co2'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Plants Need Food Too',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Like all living things, aquarium plants require specific nutrients to grow and stay healthy. Fish waste provides some nitrogen — but a heavily planted tank needs significantly more than fish can supply. Understanding plant nutrition prevents the baffling "my tank looks great but plants are dying" problem that frustrates many beginners.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Macronutrients (NPK): Nitrogen (N), Phosphorus (P), Potassium (K) — needed in larger quantities\n• Secondary macros: Calcium (Ca), Magnesium (Mg), Sulphur (S)\n• Micronutrients (trace elements): Iron (Fe), Manganese, Zinc, Boron, Copper (trace), Molybdenum\n• CO2: The primary carbon source — not a "fertiliser" technically, but the foundation of photosynthesis',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Liquid Fertilisers vs Root Tabs',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Liquid fertilisers (Easy Green, Tropica Premium Nutrition, Seachem Flourish Comprehensive) — dissolved in the water column. Fast-acting, good for water-column feeders (Java fern, Anubias, floating plants, most stem plants).\n• Root tabs (Seachem Flourish Tabs, API Leaf Zone tabs) — capsules pushed into the substrate near plant roots. Feed root-feeding plants (Cryptocoryne, Echinodorus, Vallisneria, Sagittaria).\n• Most heavily planted tanks benefit from both approaches used together.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Reading Deficiency Symptoms',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Yellow leaves throughout the plant → Nitrogen (N) deficiency — add liquid nitrogen source\n• Yellow between leaf veins, green veins remain → Iron (Fe) deficiency — dose chelated iron\n• Purple/red undersides on leaves → Phosphate (P) deficiency — dose phosphate\n• Holes or pinholes in leaves → Potassium (K) deficiency — dose potassium\n• Pale, stunted growth overall → CO2 deficiency — check injection rate\n• New leaves malformed or twisted → Calcium or boron deficiency',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Over-fertilising with phosphate and potassium in a high-light tank without sufficient CO2 is a direct route to algae. Nutrients + light without CO2 = algae, not plant growth. The three pillars (light, CO2, nutrients) must be balanced. Adding more fertiliser to a struggling tank often makes things worse if CO2 or light is the real limiting factor.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'The Estimative Index (EI) method: dose nutrients generously according to a standard schedule and rely on regular 50% weekly water changes to reset and prevent build-up. EI eliminates complex dosing calculations — generous dosing ensures plants are never limited; large water changes prevent accumulation of any individual element.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Simple Dosing Schedules',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'For beginners: a single all-in-one liquid fertiliser (Tropica Specialised or Easy Green) dosed 2–3 times per week covers most planted tanks without the complexity of separate macro and micro dosing. Upgrade to split dosing (separate macros and micros) only when you\'re confident diagnosing deficiency symptoms.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Tom Barr developed the Estimative Index dosing method in 2003 on the Aquatic Plant Central forum. Before EI, planted tank nutrient management was complex, precise, and frequently misunderstood. Barr\'s "dose generously, change water regularly" approach simplified everything and is still the most widely used method two decades later.',
        ),
      ],
      quiz: Quiz(
        id: 'aq_fert_quiz',
        lessonId: 'aq_fertilisation',
        questions: [
          const QuizQuestion(
            id: 'aq_fert_q1',
            question:
                'What visual symptom suggests iron deficiency in aquarium plants?',
            options: [
              'Holes or pinholes appearing in the middle of leaves',
              'Purple or reddish colouration on the undersides of leaves',
              'Yellowing between the leaf veins while the veins themselves remain green',
              'Leaves turning brown and falling off the plant',
            ],
            correctIndex: 2,
            explanation:
                'Iron deficiency causes interveinal chlorosis — yellowing between leaf veins while the vein network itself stays green. This is called chlorosis and is the classic iron deficiency symptom. Dose chelated iron (Fe-EDTA or Fe-DTPA) to correct it.',
          ),
          const QuizQuestion(
            id: 'aq_fert_q2',
            question:
                'What is the key difference between liquid fertilisers and root tabs?',
            options: [
              'Root tabs are for floating plants; liquid fertilisers are for all submerged plants',
              'Liquid fertilisers feed the water column; root tabs feed root-feeding plants through the substrate',
              'Liquid fertilisers are only used in high-tech CO2 tanks',
              'Root tabs change pH significantly; liquid fertilisers are pH-neutral',
            ],
            correctIndex: 1,
            explanation:
                'Different plants feed differently. Epiphytes and stem plants with fine root systems primarily absorb nutrients from the water column (liquid ferts). Heavy root feeders like Cryptocoryne and Echinodorus absorb most nutrients through their roots (root tabs). Using both covers all plant types.',
          ),
          const QuizQuestion(
            id: 'aq_fert_q3',
            question:
                'What does the Estimative Index (EI) dosing method rely on to prevent nutrient build-up?',
            options: [
              'Precise measurement of each nutrient individually with test kits',
              'Regular 50% weekly water changes to reset nutrient levels',
              'Using only natural fish waste as the sole nutrient source',
              'Automated dosers with inline sensors that maintain exact levels',
            ],
            correctIndex: 1,
            explanation:
                'EI doses nutrients generously — plants are never limited. The weekly 50% water change resets the water column, preventing accumulation of any element to toxic levels. This eliminates the need for complex measuring. Dose generously, change water regularly. Done.',
          ),
        ],
      ),
    ),

    // AQ-4: Algae Management
    Lesson(
      id: 'aq_algae_management',
      pathId: 'aquascaping',
      title: 'Algae Management in Planted Tanks',
      description: 'What algae is telling you — and how to fix it',
      orderIndex: 3,
      xpReward: 60,
      estimatedMinutes: 7,
      prerequisites: ['aq_fertilisation', 'maint_algae'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Algae Is a Symptom, Not the Problem',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Every algae type in a planted tank is diagnostic — it tells you something specific about what\'s out of balance. Treating the algae without fixing the underlying cause just means the algae returns. The key shift: stop seeing algae as an enemy to destroy and start reading it as a data point about your system.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Green Spot Algae (GSA) — circular hard green dots on glass and slow-growing leaves → low phosphate OR excess light\n• Black Beard Algae (BBA) — dark, tufted, hair-like, clings to hardscape and plant edges → CO2 fluctuations\n• Green Water (suspended algae) — water turns pea-soup green → too much light, new tank, nutrient imbalance\n• Hair/Thread algae — long fine strands of bright green algae → excess light + low nutrients (paradox)\n• Diatoms (brown algae) — brown powdery coating on everything → new tank stage, high silicates\n• Staghorn algae — grey-green, branching → similar causes to BBA, CO2 instability',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Balance Theory',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Algae thrives when the balance between light, CO2, and nutrients is disrupted. The most common imbalance: too much light relative to CO2. High light drives photosynthesis demand — but without enough CO2, plants can\'t use all that energy. The excess energy is captured by algae instead. Reducing light duration (not intensity) while stabilising CO2 resolves the majority of planted tank algae issues.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Black Beard Algae (BBA) is almost always caused by CO2 fluctuations — not too little CO2, but unstable CO2 delivery. If your CO2 varies during the photoperiod (pressure drops toward cylinder end, regulator instability, needle valve inconsistency), BBA exploits the unstable conditions. Stabilise CO2 delivery before any other intervention.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Targeted Algae Treatments',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• GSA: Dose phosphate, reduce light duration. Scrape glass with a razor blade.\n• BBA: Spot-treat with Excel/liquid carbon directly via syringe with flow off, or hydrogen peroxide (3%) diluted 1:3. Fix CO2 stability first.\n• Green water: UV steriliser (most effective — 24–48hr cure). Blackout 3–4 days as alternative. Reduce photoperiod permanently.\n• Hair algae: Manual removal + reduce photoperiod + check CO2 stability.\n• Diatoms: Wait — they self-resolve in 2–4 weeks as the tank matures. Otocinclus eat them eagerly.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Prevention Strategy for New Planted Tanks',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'The single most effective algae prevention strategy is dense planting from day one. A fully planted tank from the initial setup gives plants a massive competitive advantage over algae. They consume nutrients and CO2 before algae can establish. A sparsely planted new tank with bright lights and high nutrients is an algae incubator.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Start with the photoperiod at 6 hours for the first month. Once the tank is established and plants are growing well, increase gradually to 8 hours. Never start at maximum — new tanks are algae-vulnerable during establishment.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Shrimp, particularly Amano and cherry shrimp, actively graze many algae types that even fish won\'t touch. A well-populated shrimp colony can keep a planted tank remarkably clean, grazing biofilm, diatoms, and early-stage algae constantly. Some aquascapers run a shrimp army specifically as their algae management strategy.',
        ),
      ],
      quiz: Quiz(
        id: 'aq_algae_quiz',
        lessonId: 'aq_algae_management',
        questions: [
          const QuizQuestion(
            id: 'aq_alg_q1',
            question:
                'What does Black Beard Algae (BBA) typically indicate about your CO2 system?',
            options: [
              'Complete absence of CO2 injection',
              'Excessive CO2 levels harming plants',
              'CO2 fluctuations — unstable delivery rather than too little CO2',
              'BBA is caused by overfeeding, not CO2 levels',
            ],
            correctIndex: 2,
            explanation:
                'BBA is a CO2 instability indicator. It thrives in tanks where CO2 levels fluctuate — a regulator that drifts, a cylinder running low, or an inconsistent needle valve. The fix is stabilising CO2 delivery, not simply adding more CO2.',
          ),
          const QuizQuestion(
            id: 'aq_alg_q2',
            question: 'Why do diatoms (brown algae) usually self-resolve in new tanks?',
            options: [
              'Fish gradually eat all the diatoms over the first few weeks',
              'As the tank matures, beneficial bacteria, plants, and biofilm organisms outcompete diatoms for silicates',
              'The tank light gradually destroys diatom cells over time',
              'Diatoms never self-resolve — they must be manually removed',
            ],
            correctIndex: 1,
            explanation:
                'Diatoms are an early-tank phenomenon. They thrive on silicates (present in tap water) in the absence of competition. As the tank establishes — bacteria colonise, plants root and grow, biofilm develops — diatoms are outcompeted and fade away naturally within 2–4 weeks.',
          ),
          const QuizQuestion(
            id: 'aq_alg_q3',
            question:
                'What is the most effective prevention strategy for algae in a new planted tank?',
            options: [
              'Keep all lights off for the first week to prevent algae establishment',
              'Dense planting from day one so plants outcompete algae for light and nutrients',
              'Use maximum nutrient dosing to give plants a head start over algae',
              'Add algae-eating fish before adding any plants',
            ],
            correctIndex: 1,
            explanation:
                'Dense planting from setup day gives plants an immediate competitive advantage. They consume the light, CO2, and nutrients that algae would otherwise exploit. A sparsely planted bright tank is an algae trap — the resources plants would use are instead claimed by algae.',
          ),
        ],
      ),
    ),
  ],
);
