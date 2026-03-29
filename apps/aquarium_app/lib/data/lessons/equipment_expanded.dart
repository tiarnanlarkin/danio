/// Lesson content - Equipment (Expanded)
/// 5 new equipment lessons added in Phase 5
library;

import '../../models/learning.dart';

final equipmentExpandedLessons = [
  // EQ-4: Test Kits (moved earlier — essential gear before advanced topics)
  Lesson(
    id: 'eq_test_kits',
    pathId: 'equipment',
    title: 'Test Kits: Your Water Quality Dashboard',
    description: 'Liquid kits, test strips, and when to use what',
    orderIndex: 3,
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

  // EQ-5: Setting Up Your First Tank (Step by Step)
  Lesson(
    id: 'eq_setup_guide',
    pathId: 'equipment',
    title: 'Setting Up Your First Tank',
    description: 'From empty box to cycled aquarium — step by step',
    orderIndex: 4,
    xpReward: 75,
    estimatedMinutes: 8,
    prerequisites: ['eq_filters', 'eq_heaters', 'eq_lighting', 'eq_test_kits'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Before You Buy a Single Fish',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Setting up a tank correctly at the start saves you from headaches, lost fish, and expensive re-dos. This guide walks you through every step — in order. Skip a step and you\'ll likely pay for it later.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'The biggest mistake beginners make: buying fish on day one. A new tank needs to cycle for 4–6 weeks before it\'s safe for fish. Plan for this.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Step 1: Choose Your Tank Size',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Bigger is almost always easier to manage. Small tanks (under 40L) fluctuate in temperature and water parameters faster, making mistakes harder to recover from. A 60–80L tank is the sweet spot for beginners — large enough to be stable, small enough to be affordable.',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Starter kits (tank + filter + light + heater bundled) are good value for beginners. Just upgrade the filter media — replace manufacturer cartridges with reusable sponge and ceramic bio-media.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Step 2: Rinse Everything (No Soap!)',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Rinse the tank with clean water — no soap, no detergent, ever\n• Rinse gravel or substrate thoroughly until water runs clear\n• Rinse decorations and rocks under tap water\n• Do NOT rinse filter media — bacteria haven\'t formed yet, but chemical residue can be absorbed',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Step 3: Add Substrate',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Add 3–5cm of substrate. Create a gentle slope from front (shallower) to back (deeper) — this looks natural and makes gravel vacuuming easier, as debris slides to the front.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Step 4: Add Hardscape (Rocks and Wood)',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Place rocks and driftwood before adding water — much easier to arrange. Check that rocks won\'t tip and trap fish. Heavy driftwood may need weighting or suction cups to stay down initially.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Step 5: Fill with Water',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Place a plate or plastic bag on substrate before pouring — prevents disturbing your layout\n• Add water slowly\n• Add dechlorinator immediately as you fill (dose for full tank volume)\n• Fill to within 3–5cm of the top',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Step 6: Install Equipment',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Filter: hang on back or place inside per manufacturer instructions\n• Heater: position near filter output at an angle, fully submerged\n• Thermometer: attach to inside glass, away from heater\n• Light: mount on lid or rim',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Do NOT plug in the heater until it\'s been in the water for 15 minutes. Glass heaters can crack if hot glass meets cold water — let them temperature-match first.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Step 7: Plant (If Applicable)',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Add plants before cycling — live plants help establish the cycle faster by consuming ammonia directly. Use tweezers to push stems 2–3cm into substrate. Attach Java fern and Anubias to rocks or wood (they don\'t root in substrate).',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Step 8: Switch Everything On',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Turn on filter first\n• Turn on heater — set to 25°C\n• Turn on light — set a timer for 6–8 hours daily\n• Check for leaks — run for 15 minutes, inspect all connections',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Step 9: Begin the Nitrogen Cycle',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Now you wait. The nitrogen cycle takes 4–6 weeks. Add an ammonia source (pure ammonia drops, fish food, or a hardy "starter fish" if you must). Test daily. The cycle is complete when: ammonia reads 0, nitrite reads 0, and nitrate is detectable.',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Speed up cycling by adding a handful of gravel, a used filter sponge, or some water from an established tank. Beneficial bacteria hitch a ride and colonise your new filter faster.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: '✅ Your Setup Checklist',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '☐ Tank cleaned (no soap)\n☐ Substrate rinsed and added\n☐ Hardscape placed\n☐ Water added with dechlorinator\n☐ Filter installed and running\n☐ Heater installed (not plugged in for 15 min)\n☐ Thermometer attached\n☐ Light set on timer\n☐ No leaks — checked after 15 minutes\n☐ Ammonia source added to start cycle\n☐ Test kit ready for daily cycling checks',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'The most common question in fishkeeping forums: "Why are my fish dying?" — and the most common answer is "New Tank Syndrome." That\'s uncycled water with ammonia spikes. Now you know how to avoid it.',
      ),
    ],
    quiz: Quiz(
      id: 'eq_setup_quiz',
      lessonId: 'eq_setup_guide',
      questions: [
        const QuizQuestion(
          id: 'eq_setup_q1',
          question: 'Why should you NOT plug in a glass heater immediately?',
          options: [
            'It needs to sync with the filter first',
            'Hot glass can crack if submerged cold — let it temperature-match for 15 minutes',
            'The heater needs to calibrate its thermostat in air first',
            'There\'s no reason — plug it in immediately',
          ],
          correctIndex: 1,
          explanation:
              'Glass heaters can crack from thermal shock if hot glass suddenly contacts cold water. Always let the heater sit submerged for 15 minutes before plugging in, so it matches the water temperature first.',
        ),
        const QuizQuestion(
          id: 'eq_setup_q2',
          question:
              'How long does the nitrogen cycle typically take in a new tank?',
          options: [
            '1–2 days',
            '1 week',
            '4–6 weeks',
            'It happens instantly if you add fish',
          ],
          correctIndex: 2,
          explanation:
              'The nitrogen cycle takes 4–6 weeks to establish. Beneficial bacteria need time to colonise filter media. Adding fish too early causes ammonia poisoning — the most common cause of "new tank syndrome" fish deaths.',
        ),
        const QuizQuestion(
          id: 'eq_setup_q3',
          question: 'What substrate slope is recommended and why?',
          options: [
            'Flat — easier to vacuum everywhere',
            'Higher at front, lower at back — pushes fish to the front',
            'Higher at back, lower at front — debris slides forward for easier vacuuming',
            'Random — substrate slope doesn\'t matter',
          ],
          correctIndex: 2,
          explanation:
              'Sloping substrate higher at the back creates depth and a natural look, while debris naturally slides to the shallower front — making gravel vacuuming much more efficient.',
        ),
        const QuizQuestion(
          id: 'eq_setup_q4',
          question: 'How can you speed up the nitrogen cycle?',
          options: [
            'Add more fish immediately',
            'Run a stronger filter',
            'Add gravel or used filter sponge from an established tank',
            'Raise the temperature to 30°C+',
          ],
          correctIndex: 2,
          explanation:
              'Beneficial bacteria from an established tank hitchhike on gravel, sponge, or even a cup of old water. Adding these to a new tank seeds it with bacteria and significantly speeds up the cycling process.',
        ),
      ],
    ),
  ),

  // EQ-6: Filter Maintenance
  Lesson(
    id: 'eq_filter_maintenance',
    pathId: 'equipment',
    title: 'Filter Maintenance: Keeping the Biology Alive',
    description: 'Clean your filter without crashing your cycle',
    orderIndex: 5,
    xpReward: 50,
    estimatedMinutes: 6,
    prerequisites: ['eq_filters', 'eq_setup_guide'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Your Filter Holds Your Cycle',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Most of your beneficial bacteria — the ones that convert toxic ammonia to safe nitrate — live in your filter media. Specifically in the sponges, ceramic rings, and bio-balls. When you maintain your filter, you\'re maintaining a living ecosystem. Treat it accordingly.',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'NEVER rinse filter media under tap water. Chlorine and chloramine in tap water kill beneficial bacteria on contact. One rinse can crash your cycle within 48 hours and kill fish.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'The Golden Rule: Only Clean What Needs It',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Clean filter media only when you notice reduced water flow — not on a calendar schedule. Dirty media is working media. A sponge caked with brown gunk is packed with bacteria. Rinsing it "for cleanliness" removes the colony you\'ve spent months building.',
      ),
      const LessonSection(
        type: LessonSectionType.keyPoint,
        content:
            'How to clean: during your weekly water change, remove the media and gently squeeze or swish it in a bucket of OLD tank water. You\'re removing blockage, not sterilising. The media should still look used when you\'re done.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'HOB Filter Maintenance',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Unplug before reaching in\n• Remove the media basket and rinse sponge/media in old tank water\n• Clean impeller (spinning part) with a soft brush — hair and debris jam it\n• Wipe inside of the housing with a damp cloth\n• Check the intake tube — debris clogs reduce flow significantly\n• Reassemble and plug back in — flow should restore immediately',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Canister Filter Maintenance',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Close the taps/valves before disconnecting\n• Carry the canister to a sink (it\'s heavy — prep yourself)\n• Open in layers: rinse mechanical media (coarse sponge) thoroughly, rinse biological media (ceramics) gently\n• Clean impeller housing\n• Check O-ring seals for cracks — replace if needed\n• Reassemble and prime before restarting',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'Canister filters should be opened every 6–8 weeks (or when flow drops). HOB filters every 4–6 weeks. Sponge filters every 4–6 weeks with a gentle rinse.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Never Replace All Media at Once',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Stagger media replacement. If you must swap out old sponge for new, do only one third at a time, leaving the rest to seed the new media. Wait 3–4 weeks between replacements. Full replacement = instant mini-cycle = stressed or dead fish.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Filter Upgrade: Ditch the Cartridges',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Most HOB filters ship with cartridges — proprietary pads designed to be replaced monthly. This is a revenue model, not good advice. Replace cartridges with: reusable coarse sponge (mechanical), ceramic rings or bio-balls (biological). These last years, cost less over time, and host far more bacteria.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Signs Your Filter Needs Attention',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Noticeably reduced water flow or spray bar output\n• Filter making new/unusual noises (impeller debris)\n• Ammonia or nitrite detected in an established tank\n• Visible algae growing inside the filter housing\n• It\'s been more than 8 weeks since last clean',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'A mature, well-established sponge filter is actually worth money in the fishkeeping hobby. Experienced aquarists sell or give away "seeded" sponges to help others cycle new tanks instantly. A single used sponge can start a new cycle in days instead of weeks.',
      ),
    ],
    quiz: Quiz(
      id: 'eq_filter_maint_quiz',
      lessonId: 'eq_filter_maintenance',
      questions: [
        const QuizQuestion(
          id: 'eq_fm_q1',
          question: 'What should you use to rinse filter media?',
          options: [
            'Hot tap water to kill harmful bacteria',
            'Cold tap water',
            'Old tank water saved during a water change',
            'Distilled water — it\'s the purest option',
          ],
          correctIndex: 2,
          explanation:
              'Always use old tank water. Tap water contains chlorine/chloramine that kills beneficial bacteria on contact. Old tank water is the same chemistry your bacteria already live in — safe and effective.',
        ),
        const QuizQuestion(
          id: 'eq_fm_q2',
          question: 'When should you clean filter media?',
          options: [
            'Every week on a fixed schedule',
            'When you notice reduced water flow',
            'Never — cleaning removes beneficial bacteria',
            'Monthly, regardless of flow',
          ],
          correctIndex: 1,
          explanation:
              'Clean only when flow is noticeably reduced. Over-cleaning disrupts bacteria. Under-cleaning causes a slow reduction in filter efficiency. Let the flow tell you when it\'s time.',
        ),
        const QuizQuestion(
          id: 'eq_fm_q3',
          question: 'Why is replacing all filter media at once dangerous?',
          options: [
            'New media is toxic to fish',
            'It removes all beneficial bacteria, causing a cycle crash',
            'It makes the filter too powerful',
            'It\'s not dangerous — replace freely',
          ],
          correctIndex: 1,
          explanation:
              'All your beneficial bacteria live in the media. Replacing it all at once removes your entire colony. The tank instantly becomes uncycled — ammonia spikes, fish die. Always stagger replacements.',
        ),
      ],
    ),
  ),

  // EQ-7: Water Change Equipment and Technique
  Lesson(
    id: 'eq_water_change_gear',
    pathId: 'equipment',
    title: 'Water Change Equipment and Technique',
    description: 'The tools that make water changes fast and stress-free',
    orderIndex: 6,
    xpReward: 50,
    estimatedMinutes: 6,
    prerequisites: ['eq_setup_guide'],
    sections: [
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'The Right Tools Make Water Changes Easy',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Weekly water changes are the cornerstone of fishkeeping. Done badly they\'re stressful and time-consuming. Done with the right gear they take 20–30 minutes and feel routine. Here\'s what you need.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Essential: The Gravel Vacuum (Siphon)',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'A gravel vacuum is a wide tube connected to a long flexible hose. You push it into the substrate — the flow lifts light debris but heavy gravel falls back down. You\'re removing waste while draining water. Two tasks in one.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Standard siphon: manual start (suck or shake), gravity-fed, cheap\n• Pump-start siphon: squeeze bulb to start flow without mouth-contact (highly recommended)\n• Electric gravel vacuum: battery-powered, great for small tanks and awkward angles\n• Python No Spill System: connects to tap, fills and drains without buckets — transforms the experience for larger tanks',
      ),
      const LessonSection(
        type: LessonSectionType.tip,
        content:
            'The pump-start siphon is the upgrade that most beginners wish they\'d bought first. Cheap, no siphon-starting mess, and widely available. Worth the extra few pounds.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Starting a Manual Siphon',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Method 1 (cleanest): Submerge the entire tube, cover the hose end with thumb, lift tube out with thumb sealed, point hose into bucket, release — gravity starts the flow\n• Method 2: Pump-start bulb (if your siphon has one)\n• Method 3: Use a dedicated hand pump starter\n• Method 4: Suck (the classic method — just don\'t swallow tank water)',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Gravel Vacuuming Technique',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Push tube vertically into gravel — debris lifts into tube, gravel falls back\n• Work systematically: front to back, left to right\n• Hover above sand — sand is too light to vacuum through\n• Skip planted areas — don\'t disturb roots\n• Stop when you\'ve removed your target water volume (25–50%)',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'The Dedicated Aquarium Bucket',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Keep one (ideally two) buckets used ONLY for aquarium water. Label them. Buckets that previously held cleaning products, paint, or food can transfer residues that harm fish — even after thorough rinsing. Aquarium-only buckets are a permanent, cheap safeguard.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Dechlorinator: Non-Negotiable',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'Every water change requires dechlorinator (water conditioner). Tap water contains chlorine and/or chloramine, which kills beneficial bacteria and damages fish gills. Add the dechlorinator to new water before it enters the tank — or dose directly into the tank as you refill.',
      ),
      const LessonSection(
        type: LessonSectionType.bulletList,
        content:
            '• Seachem Prime — highly concentrated (5ml treats 200L), detoxifies ammonia/nitrite temporarily at higher doses, widely considered the best all-round conditioner\n• API Stress Coat — adds slime coat protection, good for stressed fish\n• Tetra AquaSafe — standard budget option, effective',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Temperature Matching',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'New water must be the same temperature as the tank (±1–2°C). Cold water shocks tropical fish — their immune system weakens immediately. Fill your bucket with warm tap water, check with a thermometer or your wrist, and adjust until it matches. This is the step most beginners skip and later regret.',
      ),
      const LessonSection(
        type: LessonSectionType.warning,
        content:
            'Temperature shock is cumulative. One cold water change won\'t always kill fish outright — but repeated temperature shocks stress the immune system, leaving fish vulnerable to ich, fin rot, and other opportunistic diseases.',
      ),
      const LessonSection(
        type: LessonSectionType.heading,
        content: 'Upgrade: The Python No Spill System',
      ),
      const LessonSection(
        type: LessonSectionType.text,
        content:
            'For tanks over 100L, the Python (or similar tap-connected water change system) is transformative. It connects to your tap via a venturi valve that creates suction — drain without buckets. Then reverse the valve to fill directly from the tap (use dechlorinator as you fill). No carrying, no spilling.',
      ),
      const LessonSection(
        type: LessonSectionType.funFact,
        content:
            'Professional aquarium stores do massive water changes — often 80–100% — on their display tanks daily or every other day. The key is always matching temperature and dechlorinating. There\'s no magic "minimum safe change" rule — it\'s all about the conditions of the new water, not the volume.',
      ),
    ],
    quiz: Quiz(
      id: 'eq_wc_gear_quiz',
      lessonId: 'eq_water_change_gear',
      questions: [
        const QuizQuestion(
          id: 'eq_wcg_q1',
          question: 'What are the two critical conditions for safe water changes?',
          options: [
            'pH match and mineral match',
            'Temperature match and dechlorination',
            'Low nitrate and high oxygen',
            'Filtered water and room temperature',
          ],
          correctIndex: 1,
          explanation:
              'Temperature match prevents cold shock to fish. Dechlorination neutralises chlorine/chloramine that kills bacteria and damages gills. Both are non-negotiable. Get these right and even 75% water changes are safe.',
        ),
        const QuizQuestion(
          id: 'eq_wcg_q2',
          question: 'Why should aquarium buckets be dedicated and labelled?',
          options: [
            'It looks professional and organised',
            'Residues from cleaning products, food, or paint can transfer to tank water and harm fish',
            'It doesn\'t matter — any clean bucket is fine',
            'Only required for saltwater tanks',
          ],
          correctIndex: 1,
          explanation:
              'Even trace amounts of cleaning products, soap, or food residues in a bucket can harm or kill fish. Dedicated, labelled aquarium buckets are a cheap, permanent safeguard.',
        ),
        const QuizQuestion(
          id: 'eq_wcg_q3',
          question: 'How do you gravel vacuum sand substrate?',
          options: [
            'Push the tube deep into the sand, same as gravel',
            'Hover the tube just above the sand surface — sand is too fine to vacuum through',
            'You cannot vacuum sand at all',
            'Use a stronger electric vacuum to pull sand through',
          ],
          correctIndex: 1,
          explanation:
              'Sand is too fine and light to vacuum through like gravel. Instead, hover the tube just above the surface — debris lifts into the tube while sand is too heavy to follow. Pushing into sand just clogs the tube.',
        ),
      ],
    ),
  ),

  // EQ-8: Air Pumps & Aeration
  Lesson(
    id: 'eq_air_pumps',
    pathId: 'equipment',
    title: 'Air Pumps & Aeration',
    description: 'Why oxygen matters more than you think',
    orderIndex: 7,
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

  // EQ-9: CO2 Systems
  Lesson(
    id: 'eq_co2_systems',
    pathId: 'equipment',
    title: 'CO2 Systems: Pressurised vs DIY',
    description: 'Hardware setup for planted tank CO2 injection',
    orderIndex: 8,
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
    orderIndex: 9,
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
    orderIndex: 10,
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

];
