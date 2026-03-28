/// Lesson content - Troubleshooting & Emergencies Path
/// New path added in Phase 5
library;

import '../../models/learning.dart';
import '../../models/user_profile.dart';

final troubleshootingPath = LearningPath(
  id: 'troubleshooting',
  title: 'Troubleshooting & Emergencies',
  description:
      'Diagnose problems fast and respond before fish die',
  emoji: '🚨',
  recommendedFor: [
    ExperienceLevel.beginner,
    ExperienceLevel.intermediate,
    ExperienceLevel.expert,
  ],
  orderIndex: 11,
  lessons: [
    // TR-1: Emergency Response
    Lesson(
      id: 'tr_emergency',
      pathId: 'troubleshooting',
      title: 'Emergency! Fish in Distress',
      description: 'Recognise the signs and act before it\'s too late',
      orderIndex: 0,
      xpReward: 60,
      estimatedMinutes: 6,
      prerequisites: ['nc_intro'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Read the Signs Fast',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Aquarium emergencies escalate fast. A fish that\'s in distress at 8am can be dead by noon. Knowing which symptoms mean what — and what to do first — is the difference between losing one fish and losing the tank. Don\'t panic. But don\'t wait.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Gasping at surface → low oxygen OR ammonia poisoning — test water immediately\n• Erratic swimming (spinning, darting, spiralling) → parasites, neurological, or pH shock\n• Red streaks on body → ammonia burns OR bacterial hemorrhagic septicemia\n• Clamped fins + lethargy → water quality crash, temperature shock, early disease\n• Multiple fish dying rapidly → toxic contamination, cycle crash, or oxygen depletion\n• Fish lying on bottom, not eating → often disease or water quality — check both',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Ammonia Emergency Protocol',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Ammonia poisoning is the most common aquarium emergency and the most preventable. If your test reads above 0.5 ppm ammonia (or any detectable nitrite), act immediately. The four steps:',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '1. 25–50% water change immediately with dechlorinated water at the same temperature\n2. Dose Seachem Prime at double the standard dose — it detoxifies ammonia for 24–48 hours\n3. Do not feed — all food adds to ammonia load\n4. Identify and remove the source (dead fish, filter crash, overcrowding, new tank not cycled)',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Do NOT do a 100% water change in an emergency. This destroys your biological filter (the beneficial bacteria in your filter media), causes osmotic shock for fish, and leaves you with an uncycled tank on top of the original problem. 25–50% is the safe range.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Seachem Prime is the single most valuable emergency product. It converts ammonia, nitrite, and nitrate to non-toxic forms for 24–48 hours — buying you time to address the root cause. It can be used at double dose (up to 5× in genuine emergencies). Keep a large bottle in stock at all times.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Building an Emergency Kit',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Emergencies don\'t announce themselves. Having the right supplies on hand means the difference between a fast, effective response and a frantic trip to a fish shop that may not have what you need.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Seachem Prime (large bottle, not the tiny starter size)\n• API Freshwater Master Test Kit (liquid, not strips)\n• Spare clean bucket (never used for cleaning products)\n• Small battery-powered air pump and spare batteries\n• Methylene blue (antifungal/antibacterial, low toxicity)\n• Aquarium salt (specific uses — know before you dose)\n• Small bare-bottom hospital tank (10–20L) ready to set up fast',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'A battery backup air pump is one of the best investments a fishkeeper can make. Power cuts, especially during summer heatwaves, can deplete oxygen in a tank within hours. A battery air pump running overnight has saved many tanks from total loss.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Many experienced fishkeepers run a battery-powered backup air pump year-round as standard practice. Power cuts during storms and summer are responsible for a significant number of tank losses every year — not disease, not water chemistry, but simple loss of filtration for 8–12 hours overnight.',
        ),
      ],
      quiz: Quiz(
        id: 'tr_emergency_quiz',
        lessonId: 'tr_emergency',
        questions: [
          const QuizQuestion(
            id: 'tr_emg_q1',
            question:
                'A fish is gasping at the surface. What are the two most likely causes?',
            options: [
              'The fish is hungry and has learned that food comes from above',
              'Low dissolved oxygen OR ammonia poisoning — test water parameters immediately',
              'The light is too bright and the fish wants to escape it',
              'The fish has been startled and this is a normal stress response',
            ],
            correctIndex: 1,
            explanation:
                'Surface gasping has two common causes: insufficient dissolved oxygen (check aeration) or ammonia poisoning (ammonia burns gill tissue, making breathing painful and inefficient). Test water immediately — the treatment differs based on which it is. This is never a "normal" behaviour to ignore.',
          ),
          const QuizQuestion(
            id: 'tr_emg_q2',
            question:
                'Why should you never perform a 100% water change as an emergency response?',
            options: [
              'It wastes too much treated water and is expensive',
              'It destroys your biological filter and causes osmotic shock, compounding the emergency',
              'Fish cannot handle clean water after being in dirty water',
              '100% water changes are completely fine — more is always better in emergencies',
            ],
            correctIndex: 1,
            explanation:
                '100% water changes remove all the beneficial bacteria from your tank water (though most bacteria live in filter media, some are in the water column). They also cause osmotic shock from sudden complete water replacement. Worse, they don\'t fix the root cause. 25–50% with Prime is the correct approach.',
          ),
          const QuizQuestion(
            id: 'tr_emg_q3',
            question: 'What does Seachem Prime do in an ammonia emergency?',
            options: [
              'Kills the ammonia-producing bacteria causing the spike',
              'Permanently removes ammonia from the water',
              'Converts ammonia to a non-toxic bound form for 24–48 hours, buying time to fix the cause',
              'Prime only treats chlorine — it has no effect on ammonia',
            ],
            correctIndex: 2,
            explanation:
                'Prime converts free ammonia (toxic) to ammonium (non-toxic bound form) for 24–48 hours. This buys time to address the root cause — a water change, removing a dead fish, or other source. Prime doesn\'t remove ammonia permanently; it must be re-dosed every 24–48 hours until the problem is resolved.',
          ),
        ],
      ),
    ),

    // TR-2: Disease Diagnosis
    Lesson(
      id: 'tr_disease_diagnosis',
      pathId: 'troubleshooting',
      title: 'Disease Diagnosis: What\'s Wrong With My Fish?',
      description: 'A systematic approach to identifying fish diseases correctly',
      orderIndex: 1,
      xpReward: 60,
      estimatedMinutes: 8,
      prerequisites: ['tr_emergency', 'fh_prevention'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Diagnose Before You Dose',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'The most expensive mistake in fish disease is reaching for medication without first diagnosing correctly. Wrong medications stress fish further, wipe out your beneficial bacteria, and waste money. Worse, while you\'re treating the wrong thing, the correct disease progresses. Force yourself through a systematic diagnosis process before opening any bottle.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '1. Test water parameters — 90% of "disease" starts with water quality stress\n2. Observe carefully — write down all symptoms, when they appeared, which fish are affected\n3. Isolate the sick fish to a hospital tank\n4. Research symptoms against known diseases\n5. Treat specifically for the identified disease',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Symptom Reference Guide',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• White spots (salt-grain sized) on fins and body → Ich (Ichthyophthirius multifiliis) — most common disease\n• White cottony tufts or patches → Fungal infection (Saprolegnia)\n• Red streaks or bloody patches on body → Bacterial hemorrhagic septicemia\n• Frayed, deteriorating fin edges → Fin rot (bacterial)\n• Severe bloating, scales sticking out like a pine cone → Dropsy — usually organ failure, often fatal\n• White stringy faeces trailing from vent → Internal parasites\n• Rapid gill movement, weight loss despite eating → Flukes or gill parasites\n• Wasting, white/grey lesions despite good water → Mycobacteriosis (Fish TB) — highly contagious, no cure',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              '90% of apparent "disease" cases are really water quality stress weakening the immune system. Fix the water first — pristine water, zero ammonia/nitrite, appropriate parameters for the species. Many early-stage conditions resolve completely without any medication if water quality is corrected promptly.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Dropsy (pine-cone scales + severe bloating) indicates kidney failure and severe internal damage. It is almost always fatal. Early intervention with Epsom salt baths (1 tablespoon per 20L) can reduce fluid retention and may extend life, but full recovery is rare. Focus on preventing spread to other fish rather than curing the affected individual.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Quarantine Protocol',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Quarantine sick fish immediately — before you even know what\'s wrong. The hospital tank is your diagnostic and treatment space. Removing a sick fish to a small, bare-bottom, closely monitored hospital tank serves multiple purposes: it protects the main tank from disease spread, removes the fish from stress of the community tank, and allows precise medication dosing in a small volume.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Document symptoms with photos before and during treatment. Good photos allow comparison over days to track improvement or deterioration. Many fishkeeping forums and communities can help with visual diagnosis when you\'re unsure — clear photos are essential for useful advice.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Fish have remarkable regeneration capabilities. A fish with severe fin rot — fins rotted down to stumps — can fully regrow healthy, perfect fins within 4–8 weeks in clean water with proper nutrition. The body\'s ability to rebuild tissue is extraordinary when the underlying cause (water quality) is resolved.',
        ),
      ],
      quiz: Quiz(
        id: 'tr_diagnosis_quiz',
        lessonId: 'tr_disease_diagnosis',
        questions: [
          const QuizQuestion(
            id: 'tr_diag_q1',
            question: 'What is the first step when you notice a sick fish?',
            options: [
              'Add a broad-spectrum medication to the main tank immediately',
              'Test water parameters — most disease presentations begin with water quality stress',
              'Raise the temperature to 86°F to accelerate the immune response',
              'Feed extra high-protein food to boost the fish\'s immune system',
            ],
            correctIndex: 1,
            explanation:
                'Water quality problems are responsible for the majority of fish disease presentations. Poor water weakens immune systems, making fish susceptible to pathogens that wouldn\'t normally cause problems. Test first — you may find the answer without medication.',
          ),
          const QuizQuestion(
            id: 'tr_diag_q2',
            question:
                'What do white, grain-of-salt-sized spots on a fish\'s body indicate?',
            options: [
              'Fungal infection (Saprolegnia)',
              'Bacterial hemorrhagic septicemia',
              'Ich (Ichthyophthirius multifiliis) — a protozoan parasite',
              'Vitamin deficiency causing white calcium deposits',
            ],
            correctIndex: 2,
            explanation:
                'White salt-grain-sized spots covering fins and body are the classic symptom of ich — one of the most common freshwater diseases. The spots are the ich parasite (in the tomont stage) embedded in the fish\'s skin. Treat promptly as ich spreads rapidly to all tank inhabitants.',
          ),
          const QuizQuestion(
            id: 'tr_diag_q3',
            question:
                'Why should you treat sick fish in a hospital tank rather than the main tank?',
            options: [
              'Medications work at lower doses in smaller volumes, reducing cost',
              'Treating the main tank exposes healthy fish to unnecessary medication and destroys beneficial bacteria',
              'Sick fish need warmer water than the main community tank',
              'A hospital tank doesn\'t need to be cycled, so it\'s faster to set up',
            ],
            correctIndex: 1,
            explanation:
                'Many medications kill beneficial bacteria, compromising your main tank\'s cycle. They also expose healthy fish to drugs they don\'t need. Hospital tank treatment protects the main tank\'s established biological filter and allows precise diagnosis and dosing without collateral damage.',
          ),
        ],
      ),
    ),

    // TR-3: Cloudy Water
    Lesson(
      id: 'tr_cloudy_water',
      pathId: 'troubleshooting',
      title: 'Cloudy Water: What It Means',
      description: 'White, green, brown — each colour tells a different story',
      orderIndex: 2,
      xpReward: 60,
      estimatedMinutes: 5,
      prerequisites: ['nc_intro', 'maint_water_changes'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Not All Cloudy Water Is Equal',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Cloudy tank water is one of the most common fishkeeper concerns — and one of the most misdiagnosed. The type of cloudiness tells you exactly what\'s happening. Looking at the colour and circumstances is the first diagnostic step. Treating white cloudiness the same as green water, or brown tint the same as yellow cloudiness, wastes time and can make things worse.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• White/grey milky cloudiness → Bacterial bloom — nitrogen cycle bacteria multiplying rapidly. Normal in new or disrupted tanks.\n• Green water → Algae bloom — free-floating suspended algae cells. Too much light or nutrients.\n• Brown/amber tint → Tannins from driftwood or Indian almond leaves. Aesthetic only, harmless to fish.\n• Yellow tint → Dissolved organics from waste, uneaten food, aging organic material. Water change needed.\n• White cloudiness in established tank → Bacterial bloom from overfeeding, a dead fish, or substrate disturbance.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Bacterial Bloom — The New Tank Mystery',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'During tank cycling, billions of beneficial bacteria multiply rapidly, temporarily clouding the water milky white or grey. This is one of the most alarming-looking events for new fishkeepers — and one of the least concerning. A bacterial bloom is a sign that the nitrogen cycle is establishing, not a sign of contamination or disease.',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'The correct response to a bacterial bloom in a new tank: do nothing disruptive. Keep the filter running, reduce feeding, and wait. The bloom clears on its own within 3–7 days as bacterial populations stabilise. A large water change disrupts the cycle and resets the clock.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Green water (algae bloom) can deplete oxygen at night when algae switch from photosynthesis to respiration. If fish are surface-gasping in the morning but the water is green, add immediate aeration and reduce the photoperiod to 0 for 3–4 days (blackout treatment). The algae will die without light.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Fixes by Cloudiness Type',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Bacterial bloom (new tank): wait, reduce feeding, keep filter running — self-resolves in 3–7 days\n• Bacterial bloom (established tank): find the source (dead fish? overfeeding?), fix it, small water change\n• Green water: cut photoperiod to 6h, reduce nutrients, UV steriliser (fastest fix — kills algae cells in 24–48h)\n• Tannins: add activated carbon to filter, pre-soak driftwood in future — harmless if you don\'t mind the look\n• Yellow/dissolved organics: 25–30% water change, reduce feeding, clean substrate\n• Persistent cloudiness despite changes: check if filter is running correctly, consider polishing media (filter floss)',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'A UV steriliser is the nuclear option for persistent green water. Killing free-floating algae cells within 24–48 hours, it\'s the most reliable solution. Install it temporarily for a green water episode and remove it after the tank clears — there\'s no need to run UV sterilisers permanently in freshwater tanks.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Many dedicated fishkeepers deliberately maintain heavily tannin-stained "blackwater" tanks — warm, dark tea-coloured water that mimics Amazonian tributaries. Betta fish, discus, and small rasboras in these tanks show dramatically more vivid colouring and more relaxed behaviour. Tannins have mild antibacterial properties and lower pH gently. "Dirty" water is sometimes exactly what certain fish need.',
        ),
      ],
      quiz: Quiz(
        id: 'tr_cloudy_quiz',
        lessonId: 'tr_cloudy_water',
        questions: [
          const QuizQuestion(
            id: 'tr_cloud_q1',
            question: 'White milky cloudiness in a new tank is most likely:',
            options: [
              'A dangerous bacterial infection requiring immediate antibiotic treatment',
              'A bacterial bloom during cycling — normal, harmless, and self-resolving within days',
              'Chalk or mineral deposits from hard tap water',
              'A sign the filter has failed and needs immediate replacement',
            ],
            correctIndex: 1,
            explanation:
                'Bacterial bloom during the nitrogen cycle is extremely common and looks alarming but is completely harmless. Beneficial bacteria multiplying rapidly cloud the water temporarily. The correct response is patience — keep the filter running, reduce feeding, and wait 3–7 days for it to clear naturally.',
          ),
          const QuizQuestion(
            id: 'tr_cloud_q2',
            question: 'Green water is caused by:',
            options: [
              'Tannins released from driftwood staining the water',
              'Suspended algae cells proliferating in excess light and available nutrients',
              'A cycling bacterial bloom (same as white cloudiness)',
              'Filter media breaking down and releasing green-coloured particles',
            ],
            correctIndex: 1,
            explanation:
                'Green water is a bloom of free-floating single-celled algae. The cells are suspended throughout the water column, turning it pea-soup green. Excess light and nutrients fuel their growth. The fastest cure is a UV steriliser, which kills suspended algae cells within 24–48 hours.',
          ),
          const QuizQuestion(
            id: 'tr_cloud_q3',
            question:
                'What is the safest response to a bacterial bloom in a new cycling tank?',
            options: [
              'Perform a 100% water change and restart the cycling process',
              'Add antibiotics to kill the bacteria causing the cloudiness',
              'Wait — reduce feeding, keep the filter running, and the bloom will self-resolve',
              'Add salt to the water to clear it faster',
            ],
            correctIndex: 2,
            explanation:
                'Bacterial blooms in new tanks resolve naturally. The bacteria that cause the bloom are not harmful — they\'re establishing the nitrogen cycle. Any intervention (large water change, antibiotics) disrupts the cycle and resets the process. Patient observation is the correct response.',
          ),
        ],
      ),
    ),
  ],
);
