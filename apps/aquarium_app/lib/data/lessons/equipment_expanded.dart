/// Lesson content - Equipment (Expanded)
/// 5 new equipment lessons added in Phase 5
library;

import '../../models/learning.dart';

final equipmentExpandedLessons = [
  // EQ-4: Air Pumps & Aeration
  Lesson(
    id: 'eq_air_pumps',
    pathId: 'equipment',
    title: 'Air Pumps & Aeration',
    description: 'Why oxygen matters more than you think',
    orderIndex: 3,
    xpReward: 50,
    estimatedMinutes: 6,
    prerequisites: ['eq_filters'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Why Oxygen Matters More Than You Think',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Gas exchange happens at the water surface — CO2 exits, oxygen enters. Your filter helps, but surface movement is the real driver. Overloaded tanks, summer heat, and heavily planted tanks at night all deplete oxygen faster than many fishkeepers realise. A tank that\'s fine in the morning can have dangerously low oxygen levels by midnight.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'Signs of low oxygen: fish gasping at the surface, especially at night or early morning. Act fast — low oxygen is an emergency. A school of fish gasping is a school of fish dying.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'What Air Pumps Actually Do',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Air pumps push air through tubing to airstones or sponge filters, creating bubbles that agitate the surface. They don\'t "add oxygen" magically — they increase surface movement so gas exchange can happen. The bubbles themselves contribute very little; it\'s the surface disturbance they create that makes the difference.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Diaphragm pumps — quiet, cheap, good for single tanks\n• Linear piston pumps — powerful, louder, ideal for multiple tanks\n• USB mini pumps — travel, quarantine, backup power use\n• Battery backup pumps — essential for power-cut emergencies',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Always install a check valve between the pump and tank. If the pump loses power, tank water can siphon back through the tubing and destroy the pump — or flood your cabinet. Check valves cost less than £1 and can save a £30+ pump.',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Sizing guide: aim for 1.5× your tank volume per hour as a rough minimum. A 100L tank → 150L/hr pump. In warm weather or heavily stocked tanks, go higher.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Airstones, Sponge Filters, and Bubble Walls',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Airstones — create fine bubble clouds, mainly decorative, modest surface agitation\n• Sponge filters — combine filtration + aeration, ideal for breeding and shrimp tanks\n• Bubble walls — long air diffusers along the back of the tank, dramatic look with functional aeration\n• Uplift tubes — for under-gravel filter systems, less common now',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'For most tanks, a sponge filter or a HOB filter with good surface movement provides adequate oxygenation without a separate air pump. Air pumps become essential in heavily stocked tanks, during summer heatwaves (warm water holds less oxygen), and as backup aeration when treating fish with medications that stress gill function.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'In tropical fish farms, hundreds of sponge filters are run from a single central blower via a branching airline network. It\'s the backbone of commercial fish production — simple, reliable, and dirt cheap to run.',
      ),
    ],
    quiz: Quiz(
      id: 'eq_air_pumps_quiz',
      lessonId: 'eq_air_pumps',
      questions: [
        const QuizQuestion(
          id: 'eq_air_q1',
          question: 'Why should you always install a check valve on an air pump?',
          options: [
            'To make bubbles larger and more visible',
            'To prevent water siphoning back through the tubing if power fails',
            'To increase the air flow rate from the pump',
            'Check valves are purely decorative — they don\'t do anything',
          ],
          correctIndex: 1,
          explanation:
              'If power fails, gravity can pull water back through the airline tubing into the pump — destroying it and potentially flooding your cabinet. A check valve prevents this backflow. They cost pennies and are non-negotiable.',
        ),
        const QuizQuestion(
          id: 'eq_air_q2',
          question:
              'What is the primary way air pumps improve oxygen levels in a tank?',
          options: [
            'They inject pure oxygen directly into the water',
            'They increase surface agitation, enabling gas exchange',
            'They cool the water, which holds more oxygen',
            'They power the filter bacteria that produce oxygen',
          ],
          correctIndex: 1,
          explanation:
              'Oxygen enters water through the surface. Air pumps create surface agitation (via bubbles), which dramatically increases the area available for gas exchange. The bubbles themselves add very little oxygen directly.',
        ),
        const QuizQuestion(
          id: 'eq_air_q3',
          question:
              'A fish is gasping at the surface every morning but seems fine during the day. What\'s the most likely cause?',
          options: [
            'The fish is hungry and learned that the surface is where food comes from',
            'Low oxygen at night — plants consume oxygen in darkness when not photosynthesising',
            'The heater is too hot during the night',
            'The filter is clogged and running slower at night',
          ],
          correctIndex: 1,
          explanation:
              'During daylight, aquatic plants produce oxygen via photosynthesis. At night, the reverse happens — plants consume oxygen like fish do. In a heavily planted or overstocked tank, this nightly oxygen drop can cause surface gasping. Extra aeration solves it.',
        ),
      ],
    ),
  ),

  // EQ-5: CO2 Systems
  Lesson(
    id: 'eq_co2_systems',
    pathId: 'equipment',
    title: 'CO2 Systems: Pressurised vs DIY',
    description: 'Hardware setup for planted tank CO2 injection',
    orderIndex: 4,
    xpReward: 50,
    estimatedMinutes: 7,
    prerequisites: ['eq_lighting', 'planted_co2'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Two Ways to Inject CO2',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'If you\'ve learned why CO2 matters in the planted tank path, this lesson covers the equipment side — the hardware that actually delivers it. There are two main approaches: pressurised CO2 systems (the serious option) and DIY yeast fermentation (the starter option).',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Pressurised CO2: cylinder + regulator + solenoid + diffuser. Consistent, precise, controllable. Higher upfront cost (£80–£200+) but accurate and reliable long-term.\n• DIY yeast: sugar + yeast + water in a bottle. Cheap (under £5 to set up). Variable output, degrades over 2–3 weeks, needs constant refreshing.\n• Paintball CO2: small pressurised cylinders, popular for nano tanks. Good middle ground.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'Pressurised systems pay for themselves in results and reliability within a few months. DIY yeast is fine to learn on and understand CO2 principles — but serious planted tanks benefit from the control that pressurised systems provide.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'The Key Components of a Pressurised System',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• CO2 Cylinder — refillable, typically 500g, 1kg or 2kg\n• Regulator — dual gauge (tank pressure + working pressure), the critical component\n• Solenoid valve — electrically controlled shutoff, connected to your timer\n• Bubble counter — counts bubbles per second, helps dial in flow rate\n• Diffuser or reactor — dissolves CO2 into the water column\n• Drop checker — monitors CO2 level in the tank via colour indicator',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'NEVER run CO2 at night. CO2 + no photosynthesis = pH crash = dead fish. Without plants consuming CO2 during darkness, levels build to toxic concentrations. A solenoid connected to a timer is non-negotiable — it automatically shuts off CO2 when the lights go off.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Reading Your Drop Checker',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'A drop checker is a small glass vessel hung inside the tank filled with indicator solution. The colour tells you your CO2 level:\n\n🔵 Blue = too little CO2 — plants not getting enough, increase injection\n🟢 Green = perfect — target this colour\n🟡 Yellow = too much CO2 — reduce injection rate, risk to fish',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'CO2 takes time to build up in the water column. Turn on your CO2 1 hour before the lights come on, and turn it off 1 hour before lights go off. This aligns peak CO2 with peak plant photosynthesis.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'CO2 is the single biggest factor in plant growth rate — more impactful than light or fertiliser. Plants are literally made of carbon. Without adequate CO2, even the best light and nutrients can\'t drive fast, healthy growth.',
      ),
    ],
    quiz: Quiz(
      id: 'eq_co2_quiz',
      lessonId: 'eq_co2_systems',
      questions: [
        const QuizQuestion(
          id: 'eq_co2_q1',
          question: 'Why must a solenoid valve be used with pressurised CO2?',
          options: [
            'To reduce the size of CO2 bubbles in the water',
            'To automatically shut off CO2 when lights go off, preventing a pH crash',
            'To control the output pressure from the cylinder',
            'Solenoids are optional — just a convenience feature',
          ],
          correctIndex: 1,
          explanation:
              'Without plants photosynthesising at night, CO2 accumulates in the water — crashing pH and suffocating fish. A solenoid connected to your light timer automatically cuts CO2 when lights go off. Non-negotiable for fish safety.',
        ),
        const QuizQuestion(
          id: 'eq_co2_q2',
          question: 'What does a yellow drop checker indicate?',
          options: [
            'Too little CO2 — increase your injection rate',
            'CO2 level is perfect — maintain current rate',
            'Too much CO2 — reduce your injection rate immediately',
            'The indicator fluid has expired and needs replacing',
          ],
          correctIndex: 2,
          explanation:
              'Yellow means excess CO2. Green is the target. Blue means too little. Yellow/orange CO2 levels can stress fish — reduce your bubble rate and check your solenoid timer is working.',
        ),
        const QuizQuestion(
          id: 'eq_co2_q3',
          question: 'When should you turn on your CO2 relative to the lights?',
          options: [
            'At the exact same moment as the lights turn on',
            '1 hour before lights come on',
            'Only when plants start to look pale or stunted',
            'Continuously, 24 hours a day',
          ],
          correctIndex: 1,
          explanation:
              'CO2 takes time to diffuse through the water and build up to useful levels. Starting 1 hour before lights on ensures CO2 is at the right level when photosynthesis begins. Stopping 1 hour before lights off prevents overnight build-up.',
        ),
      ],
    ),
  ),

  // EQ-6: Aquascaping Tools & Hardscape
  Lesson(
    id: 'eq_aquascape_tools',
    pathId: 'equipment',
    title: 'Aquascaping Tools & Hardscape',
    description: 'The tools and materials of aquatic design',
    orderIndex: 5,
    xpReward: 50,
    estimatedMinutes: 6,
    prerequisites: ['eq_lighting'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Tools of the Trade',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Aquascaping with bare hands is frustrating — plants float, substrate shifts, and reaching the back of a deep tank is near impossible. The right tools make layout work cleanly and quickly.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Curved scissors — trimming plants in the midground/background without reaching awkwardly\n• Straight scissors — general cutting and shaping\n• Spring scissors — self-opening, less hand fatigue for detailed work\n• Long tweezers / planting tongs — planting stem plants and carpets in substrate\n• Substrate spatula — shaping and smoothing substrate slopes\n• Magnetic glass cleaner — algae removal without getting hands wet',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Budget tip: a set of long kitchen tongs and craft scissors work surprisingly well to start. Invest in proper aquascaping tools once you\'re committed to the hobby.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Rock Types — What\'s Safe?',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Not all rocks are safe for aquariums. The key test: pour white vinegar onto the rock. If it fizzes, the rock contains calcium carbonate — it will slowly dissolve in your tank water, raising pH and KH. This is fine for African cichlid tanks but harmful for soft-water planted setups.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Safe (inert) rocks: Dragon Stone (Ohko), lava rock, Seiryu stone (check with vinegar — some batches react), slate, petrified wood, sandstone\n• Avoid in soft-water tanks: limestone, marble, calcium-heavy rocks\n• The vinegar test: fizzing = calcium carbonate = will raise pH and KH',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Never use rocks collected from gardens or roadsides without testing. Outdoor rocks may contain pesticides, heavy metals, or minerals toxic to fish. The vinegar test only checks for carbonates — it won\'t detect other contaminants. Stick to aquarium-grade rocks from reputable suppliers.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Driftwood — Natural and Functional',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Driftwood lowers pH and releases tannins, giving water a warm tea colour — the blackwater aesthetic beloved by betta, discus, and rasbora keepers. It also provides shelter and, for plecos, an actual dietary supplement. Common types: Mopani (dense, dark, sinks quickly), Malaysian driftwood (branch-like), Spider wood (dramatic branching), Cholla wood (tubular, great for shrimp).',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Pre-soak new driftwood in a bucket of water for 1–2 weeks, changing the water every few days. This leaches out the bulk of tannins and waterlogging, so it sinks properly and doesn\'t stain your tank water brown for months.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Design Basics: Rule of Thirds and Odd Numbers',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'The rule of thirds: divide your tank into thirds horizontally and vertically. Place your focal point — the centrepiece rock, dramatic piece of driftwood — at one of the intersection points, not dead centre. Centred compositions look formal and unnatural. Off-centre looks organic.\n\nOdd numbers of stones (3, 5, 7) look natural; even numbers feel artificially paired. In nature, rocks don\'t arrange themselves in symmetric pairs — odd groupings mimic organic clustering. Create depth by placing rocks at slightly different distances from the front glass.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'Takashi Amano — the founder of the Nature Aquarium style — was trained as a photographer and cyclist before becoming an aquascaper. He applied Japanese wabi-sabi and garden design principles to a glass box. His work is exhibited in art galleries, not just aquarium shops.',
      ),
    ],
    quiz: Quiz(
      id: 'eq_aquascape_tools_quiz',
      lessonId: 'eq_aquascape_tools',
      questions: [
        const QuizQuestion(
          id: 'eq_aqt_q1',
          question:
              'How do you quickly test whether a rock will raise your tank\'s pH?',
          options: [
            'Drop it in your tank for a week and monitor pH daily',
            'Drop white vinegar on the rock — fizzing indicates calcium carbonate',
            'Boil the rock and check if the water turns cloudy',
            'There is no way to test rocks at home',
          ],
          correctIndex: 1,
          explanation:
              'The vinegar test is quick and effective. Calcium carbonate reacts with acetic acid (vinegar) and fizzes. If the rock fizzes, it will gradually dissolve in your aquarium and raise pH and KH. Safe for hard-water tanks, avoid in soft-water setups.',
        ),
        const QuizQuestion(
          id: 'eq_aqt_q2',
          question: 'Why should you soak driftwood before adding it to your tank?',
          options: [
            'To sterilise it and kill any bacteria living in the wood',
            'To reduce tannin release and help it sink rather than float',
            'To add beneficial minerals that fish need',
            'So fish can get used to the smell before it enters the tank',
          ],
          correctIndex: 1,
          explanation:
              'Fresh driftwood contains lots of tannins that turn water dark brown, and it often floats. Pre-soaking leaches out tannins progressively and waterloggs the wood so it sinks properly when placed in your aquascape.',
        ),
        const QuizQuestion(
          id: 'eq_aqt_q3',
          question:
              'Why do odd-numbered groupings of rocks look more natural than even?',
          options: [
            'Even numbers are considered bad luck in Japanese aesthetics',
            'Natural rock formations rarely occur in symmetric pairs — odd numbers mimic organic, random clustering',
            'Even groupings confuse fish and affect their behaviour',
            'It\'s purely a designer preference with no basis in observation',
          ],
          correctIndex: 1,
          explanation:
              'In nature, rocks settle randomly. Symmetric pairings look arranged and unnatural. Odd-numbered groupings with varied spacing replicate natural clustering, creating a more convincing "slice of nature" in your aquarium.',
        ),
      ],
    ),
  ),

  // EQ-7: Substrate Types
  Lesson(
    id: 'eq_substrate',
    pathId: 'equipment',
    title: 'Choosing Your Substrate',
    description: 'Gravel, sand, aqua soil — which is right for you?',
    orderIndex: 6,
    xpReward: 50,
    estimatedMinutes: 6,
    prerequisites: ['eq_filters'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Your Foundation Matters',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Substrate affects aesthetics, fish behaviour (especially bottom-dwellers), plant root growth, water chemistry, and ongoing maintenance effort. It\'s worth thinking through carefully before you fill the tank — changing substrate later means a full teardown. Get it right the first time.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Fine sand — natural look, great for bottom-dwelling fish, easy to siphon but can compact\n• Coarse gravel — traditional, easy to clean, no good root nutrition for plants\n• Natural pea gravel — smooth rounded gravel, safer than sharp gravel, neutral chemistry\n• Aqua soil (e.g. ADA Aqua Soil, Fluval Stratum) — nutrient-rich, lowers pH, ideal for planted tanks\n• Crushed coral — raises KH and pH, good for African cichlids and hard-water species\n• Bare bottom — clinical, easy to clean, ideal for quarantine and breeding tanks',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'What Your Fish Prefer',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Corydoras and other armoured catfish have sensitive barbels — the delicate whiskers around their mouth that they use to sense food. Sharp gravel damages these barbels over time, leading to bacterial infections that can shorten the fish\'s life significantly. Fine sand is essential for cories, kuhli loaches, and other bottom-feeders that sift through the substrate.',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Burrowing loaches (kuhli loaches, dwarf chain loaches) need at least 5cm of soft substrate to exhibit natural behaviour. A kuhli loach on bare glass or sharp gravel will spend its life hiding and never display its natural, active personality.',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Avoid dyed or brightly coloured gravel. It looks unnatural, can leach dye over time, and creates no natural environment cue for fish. Fish often show their best colour against dark, natural substrates — not hot pink or electric blue gravel.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Aqua Soil — The Planted Tank Choice',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Nutrient-rich aqua soils provide root nutrition for plants without the need for separate root tabs during the first 12–18 months. They also naturally lower and soften pH — ideal for most planted aquarium setups. The trade-off: aqua soils break down over 1–3 years as nutrients exhaust, eventually becoming inert. Top up with root tabs or replace the substrate layer after this point.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Bare Bottom — The Practical Choice',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '✅ Pros: Easy to clean, waste visible on the glass floor, no substrate trapping uneaten food or detritus\n❌ Cons: Unnatural, stresses bottom-dwelling fish, fish may see their reflection in the glass and stress, no root medium for plants',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Breeding tanks and hospital/quarantine tanks should almost always be bare bottom. Fry are tiny and hard to see in substrate. Sick fish benefit enormously from the clean environment. Easy daily cleaning keeps ammonia and bacteria in check during recovery.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'In the wild, riverbeds shift constantly with currents. Many fish species have never encountered aquarium "gravel" in their natural habitat at all. The vast majority of tropical fish come from environments with sand, fine silt, leaf litter, or bare rock — never the round decorative gravel sold in most fish shops.',
      ),
    ],
    quiz: Quiz(
      id: 'eq_substrate_quiz',
      lessonId: 'eq_substrate',
      questions: [
        const QuizQuestion(
          id: 'eq_sub_q1',
          question:
              'Why is fine sand specifically recommended for Corydoras catfish?',
          options: [
            'Corydoras eat sand particles as part of their diet',
            'Sharp gravel damages their sensitive barbels, leading to bacterial infections',
            'Sand keeps the water temperature more stable for them',
            'Corydoras don\'t actually care about substrate type',
          ],
          correctIndex: 1,
          explanation:
              'Corydoras have delicate barbels (sensory whiskers) that they use to find food. Sharp gravel wears these down over months, creating entry points for bacteria. Infected, shortened barbels are a common sign of improper substrate — and a quality-of-life issue for the fish.',
        ),
        const QuizQuestion(
          id: 'eq_sub_q2',
          question:
              'What is the main advantage of bare-bottom tanks for quarantine and breeding?',
          options: [
            'Bare bottom is warmer and better for all fish',
            'Easy cleaning with no substrate traps — waste is visible and removed immediately',
            'Bare bottom naturally lowers pH',
            'Bare bottom increases biological filtration capacity',
          ],
          correctIndex: 1,
          explanation:
              'Bare bottom tanks eliminate hiding places for uneaten food, waste, and pathogens. Everything is visible on the glass floor and easily siphoned. This cleanliness is critical for sick fish recovery and for safely raising vulnerable fry.',
        ),
        const QuizQuestion(
          id: 'eq_sub_q3',
          question:
              'What happens if you use crushed coral as substrate in a soft-water community tank?',
          options: [
            'Nothing — substrate doesn\'t affect water chemistry',
            'It will gradually raise KH and pH, potentially stressing soft-water species like tetras',
            'It will lower pH and soften the water over time',
            'Crushed coral only affects chemistry in marine tanks, not freshwater',
          ],
          correctIndex: 1,
          explanation:
              'Crushed coral dissolves slowly in water, releasing calcium and raising KH (carbonate hardness) and pH. This is excellent for African cichlids and mollies but harmful for tetras, discus, and other soft-water species that need pH 6.0–7.0.',
        ),
      ],
    ),
  ),

  // EQ-8: Test Kits
  Lesson(
    id: 'eq_test_kits',
    pathId: 'equipment',
    title: 'Test Kits: Your Water Quality Dashboard',
    description: 'Liquid kits, test strips, and when to use what',
    orderIndex: 7,
    xpReward: 50,
    estimatedMinutes: 5,
    prerequisites: ['nc_testing'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Test Strips vs Liquid Test Kits',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Two options exist for testing aquarium water at home: test strips (dip a strip in, read colours off a chart) and liquid test kits (add drops of reagent to a water sample, compare to colour chart). They are not equal.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Test strips: fast (30 seconds), cheap, convenient, significantly less accurate\n• Liquid kits (API, Salifert, Sera): slightly slower (3–5 minutes), more expensive per test, reliably accurate\n• Digital meters (pH pens, TDS meters): accurate for specific parameters, require calibration',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Test strips are not reliable enough for critical decisions. The same tank can show readings 0.5 pH units apart between a strip and a liquid kit. For cycling a new tank, diagnosing disease, or adjusting parameters for sensitive species — always use liquid kits.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'The API Freshwater Master Test Kit covers ammonia (NH3/NH4), nitrite (NO2), nitrate (NO3), and pH — the four essential parameters. Every fishkeeper should own one. It\'s the single most important piece of equipment after the tank itself.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'When to Test',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• New tank (cycling): daily — you need to track ammonia and nitrite peaks\n• Established tank: weekly — catching problems before they become emergencies\n• After adding new fish: 48 hours later — bioload increase can spike ammonia\n• After illness/treatment: after the medication course ends — confirm water quality\n• After unusual behaviour: any time fish act oddly — always test water first',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Digital Meters — When Are They Worth It?',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'pH pens (like the Bluelab Pen or Milwaukee pH600) give precise, instant pH readings and are essential for precision planted tanks where pH is adjusted regularly. TDS (Total Dissolved Solids) meters are invaluable for shrimp keepers who need to hit a precise mineral target. Refractometers are standard in marine setups for salinity. For a standard freshwater community tank, liquid kits cover everything you need.',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Store liquid test kit reagents at room temperature, away from direct sunlight. Heat degrades the chemicals faster and causes inaccurate readings. Check the expiry date — old reagents are a false economy.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'Professional aquaculture facilities test water automatically every 15 minutes using inline sensors and automated dosing systems. For hobbyists, once per week is sufficient to catch the vast majority of problems before they become fatal emergencies.',
      ),
    ],
    quiz: Quiz(
      id: 'eq_test_kits_quiz',
      lessonId: 'eq_test_kits',
      questions: [
        const QuizQuestion(
          id: 'eq_test_q1',
          question:
              'Why are test strips considered less reliable than liquid test kits?',
          options: [
            'Test strips cannot test for ammonia',
            'Test strips give less accurate readings and can mislead dosing decisions',
            'Test strips take much longer to give results',
            'Test strips only work in saltwater, not freshwater',
          ],
          correctIndex: 1,
          explanation:
              'Test strips are notoriously imprecise — colour interpretation is subjective and the chemicals degrade quickly once the tube is opened. The same water can give readings 0.5 pH units apart between a strip and a liquid kit. For reliable results, use liquid test kits.',
        ),
        const QuizQuestion(
          id: 'eq_test_q2',
          question:
              'How often should you test water in a cycling (brand new) tank?',
          options: [
            'Once a week is sufficient',
            'Every day to track ammonia and nitrite peaks',
            'Only when fish seem unwell',
            'Monthly — cycling takes weeks',
          ],
          correctIndex: 1,
          explanation:
              'Cycling a new tank produces rapid ammonia and nitrite spikes that can happen within hours. Daily testing lets you track the cycle progress, know when it\'s safe to add fish, and catch dangerous spikes before they kill anything.',
        ),
        const QuizQuestion(
          id: 'eq_test_q3',
          question:
              'Which four parameters does the API Freshwater Master Test Kit measure?',
          options: [
            'Temperature, pH, TDS, and nitrate',
            'Ammonia, nitrite, nitrate, and pH',
            'pH, KH, GH, and nitrite',
            'Chlorine, ammonia, pH, and calcium',
          ],
          correctIndex: 1,
          explanation:
              'The API Freshwater Master Kit covers the four parameters that matter most: ammonia (NH3), nitrite (NO2), nitrate (NO3), and pH. Together these tell you if your nitrogen cycle is working, if there\'s an immediate danger, and whether your pH is appropriate for your fish.',
        ),
      ],
    ),
  ),
];
