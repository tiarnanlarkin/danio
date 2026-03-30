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
              '• Gasping at surface → low oxygen OR ammonia poisoning — test water immediately\n• Erratic swimming (spinning, darting, spiralling) → parasites, neurological, or pH shock\n• Red streaks on body → ammonia burns OR bacterial haemorrhagic septicaemia\n• Clamped fins + lethargy → water quality crash, temperature shock, early disease\n• Multiple fish dying rapidly → toxic contamination, cycle crash, or oxygen depletion\n• Fish lying on bottom, not eating → often disease or water quality — check both',
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
              '• White spots (salt-grain sized) on fins and body → Ich (Ichthyophthirius multifiliis) — most common disease\n• White cottony tufts or patches → Fungal infection (Saprolegnia)\n• Red streaks or bloody patches on body → Bacterial haemorrhagic septicaemia\n• Frayed, deteriorating fin edges → Fin rot (bacterial)\n• Severe bloating, scales sticking out like a pine cone → Dropsy — usually organ failure, often fatal\n• White stringy faeces trailing from vent → Internal parasites\n• Rapid gill movement, weight loss despite eating → Flukes or gill parasites\n• Wasting, white/grey lesions despite good water → Mycobacteriosis (Fish TB) — highly contagious, no cure',
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
              'Bacterial haemorrhagic septicaemia',
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
              '• White/grey milky cloudiness → Bacterial bloom — nitrogen cycle bacteria multiplying rapidly. Normal in new or disrupted tanks.\n• Green water → Algae bloom — free-floating suspended algae cells. Too much light or nutrients.\n• Brown/amber tint → Tannins from driftwood or Indian almond leaves. Aesthetic only, harmless to fish.\n• Yellow tint → Dissolved organics from waste, uneaten food, ageing organic material. Water change needed.\n• White cloudiness in established tank → Bacterial bloom from overfeeding, a dead fish, or substrate disturbance.',
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

    // TR-4: Power Outage Recovery
    Lesson(
      id: 'tr_power_outage',
      pathId: 'troubleshooting',
      title: 'Power Outage Recovery',
      description: 'What to do when the power goes out — and how to keep fish alive',
      orderIndex: 3,
      xpReward: 60,
      estimatedMinutes: 6,
      prerequisites: ['tr_emergency'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Silent Killer: Loss of Filtration',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Power cuts are one of the most dangerous aquarium emergencies — and one of the most overlooked. When the power goes out, your filter stops circulating water. Oxygen levels drop. Ammonia starts building from fish waste and uneaten food. In warm water (above 24°C), a heavily stocked tank can reach dangerous ammonia levels within 4–6 hours. Overnight cuts in summer are responsible for many total tank losses.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• First hour: low risk — oxygen and biological filtration continue from residual flow\n• 2–4 hours: oxygen begins depleting, especially in warm or heavily stocked tanks\n• 4–8 hours (overnight): critical — ammonia builds, oxygen critically low, fish show distress\n• 8+ hours: high mortality risk in warm, heavily stocked tanks without aeration',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Immediate Response Protocol',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '1. Deploy a battery-powered air pump immediately — oxygenation is the priority\n2. Do NOT open the lid unnecessarily — heat escapes and water temperature matters\n3. Do NOT feed — food produces ammonia, worsening an already-stressed system\n4. Keep the room warm if you have a portable heater — temperature stability reduces fish stress\n5. If outage extends beyond 4 hours: perform a small water change (15–20%) with treated water at correct temperature',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'A battery-powered air pump is the single most important emergency piece of equipment. Buy one, keep batteries fresh, and test it quarterly. It costs less than £15 and can prevent total tank loss during a power cut. Keep it within arm\'s reach of the tank.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'When Power Returns: Equipment Check',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Power restoration is not the end of the emergency. Equipment restarts, heaters can overshoot, and the sudden return to normal flow can cause turbulence that stresses already-weakened fish. Run through this checklist when power returns:',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Check filter is running — internal filters sometimes need a manual prime after power cuts\n• Check heater is functioning, not overheating (verify temperature after 30 minutes)\n• Test ammonia immediately — it will have been building during the outage\n• Dose Seachem Prime at double dose — detoxifies any ammonia that built up\n• Do NOT feed for 24 hours after a major outage — give the system time to stabilise\n• Monitor fish closely for 48–72 hours for signs of stress (clamped fins, lethargy, surface gasping)',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Fish Stress After Power Cuts',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Even if fish survive the outage, immune systems are suppressed by the stress. Opportunistic infections (ich, fin rot, bacterial) often appear 3–7 days after a major power event. Watch closely and be ready to quarantine any fish showing symptoms.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Some heaters malfunction after power restoration — they overshoot target temperature dramatically. After power returns, monitor tank temperature every 15 minutes for the first hour. A heater that\'s running constantly and the temperature keeps climbing indicates a stuck heater — unplug it immediately and replace.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'For long-term protection, consider an Uninterruptible Power Supply (UPS) designed for electronics. A small UPS unit can power a filter and heater for several hours during outages. More practical for serious fishkeepers with valuable or sensitive fish.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Public aquariums run on generator backup power with automatic failover — a power cut triggers generator start within seconds. Some dedicated home fishkeepers with large or expensive setups (koi ponds, marine tanks) have invested in the same technology for their home systems.',
        ),
      ],
      quiz: Quiz(
        id: 'tr_power_quiz',
        lessonId: 'tr_power_outage',
        questions: [
          const QuizQuestion(
            id: 'tr_power_q1',
            question:
                'What is the most critical action to take immediately during a power outage affecting your aquarium?',
            options: [
              'Perform a 50% water change to dilute any ammonia that builds up',
              'Deploy a battery-powered air pump to maintain oxygen levels',
              'Move all fish to a bucket of fresh tap water',
              'Feed extra food to ensure fish have enough energy',
            ],
            correctIndex: 1,
            explanation:
                'Oxygen depletion is the fastest-acting danger during a power outage. A battery-powered air pump provides immediate oxygenation and surface agitation, buying significant time. Water changes can come later — oxygenation is the first priority.',
          ),
          const QuizQuestion(
            id: 'tr_power_q2',
            question:
                'Why should you test ammonia immediately when power is restored after a long outage?',
            options: [
                'Power surges cause chemical reactions that create ammonia',
                'Ammonia builds up whenever filtration stops — it will have accumulated during the outage',
                'Ammonia only tests accurately when equipment is running normally',
                'Power cuts affect test kit accuracy, so you need to recalibrate',
            ],
            correctIndex: 1,
            explanation:
                'Biological filtration stops when the filter stops. Fish continue producing waste, and ammonia accumulates with no bacteria processing it. After any extended outage, ammonia will be elevated. Testing immediately and dosing Prime lets you understand the scale of the problem.',
          ),
          const QuizQuestion(
            id: 'tr_power_q3',
            question:
                'Why might fish show disease symptoms 3–7 days after a power outage, even if they survived it?',
            options: [
              'Power cuts change the water chemistry permanently, weakening fish',
              'The stress of the outage suppresses the immune system, making fish vulnerable to opportunistic infections',
              'Filters introduce bacteria when they restart, causing disease',
              'Temperature changes from outages permanently damage fish organs',
            ],
            correctIndex: 1,
            explanation:
                'Stress — from oxygen depletion, temperature fluctuation, and ammonia exposure — suppresses fish immune systems. Even a fish that appears fine after a power cut may succumb to ich, fin rot, or bacterial infection in the days that follow. Monitoring closely for 72 hours after any major emergency is essential.',
          ),
        ],
      ),
    ),

    // TR-5: Temperature Crash / Heater Failure
    Lesson(
      id: 'tr_temperature_crash',
      pathId: 'troubleshooting',
      title: 'Temperature Crash: Heater Failure',
      description: 'Emergency response to sudden temperature drops and heater failures',
      orderIndex: 4,
      xpReward: 60,
      estimatedMinutes: 6,
      prerequisites: ['tr_emergency'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Temperature: The Invisible Emergency',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fish are ectotherms — their body temperature equals their environment. A heater failure in winter, especially overnight, can drop tank temperature from 26°C to 15°C in just a few hours. Most tropical fish experience severe immune suppression below 20°C. Below 15°C, metabolic function slows to dangerous levels. The fish may still be swimming — but organ damage is occurring.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Warning signs of heater failure: temperature below target, heater light not on, heater feels cool to touch\n• Signs of temperature crash in fish: lethargy and slow movement, sitting on the bottom, clamped fins, laboured breathing, reduced or no appetite\n• Species most vulnerable: discus, rams, altum angelfish (high-temperature specialists)\n• Species most tolerant: white clouds, goldfish, rosy barbs (cold-water tolerant)',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Emergency Response',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '1. Confirm heater failure — check the thermostat, test if it\'s outputting heat\n2. Raise room temperature if possible — close doors and windows, use a portable heater in the room\n3. Float sealed bags or bottles of warm (not hot) water in the tank — raises temperature gently\n4. Wrap insulation around the tank exterior — towels, polystyrene, blankets\n5. Do NOT add very hot water directly — rapid temperature increase is as harmful as gradual decrease\n6. Source a replacement heater as quickly as possible',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'The safe rate of temperature change is no more than 1–2°C per hour. Slower is better. A fish that has experienced a temperature drop over 8 hours should have its temperature restored over at least 4–6 hours — not in a single rapid correction. Rewarming too fast causes thermal shock.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Backup Heating Strategies',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Heater failure is not a matter of if, but when. A heater has a typical lifespan of 3–5 years, and most fail without warning. Having a backup strategy ready significantly reduces risk.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Always keep a spare heater — one size larger than your main heater, unopened and ready\n• Run two heaters in a large tank — each set 1°C below target; if one fails, the other maintains most of the target temp\n• Install a temperature alarm — simple digital thermometers with min/max alerts can wake you if the temperature drops at night\n• For valuable fish (discus, rare cichlids), consider a dedicated temperature controller with dual-probe redundancy',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Opposite Problem: Heater Stuck ON',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Heater failure also occurs in the opposite direction: the thermostat sticks in the ON position, and the heater runs continuously. In a small tank this can raise temperatures by 5–10°C in just a few hours — cooking the fish. This is the reason a thermometer should always be read at every tank check.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'If you find your heater running continuously and temperature is rising past target: unplug the heater immediately. Do not wait. Float sealed bottles of cold (not iced) water to slowly bring temperature down. Check fish for stress signs. A heater that sticks ON is destroyed — replace it.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Check your thermometer at every tank visit — before looking at the fish, before doing maintenance. Temperature problems are invisible until the fish show symptoms. A 2-second thermometer glance prevents a catastrophic emergency.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Discus (Symphysodon sp.) are kept at 28–31°C — the highest temperature of any common aquarium fish. They evolved in seasonally warm Amazonian flooded forests where temperatures rarely drop. A temperature dip to 24°C — comfortable for most tropicals — will trigger illness and potential death in discus within days.',
        ),
      ],
      quiz: Quiz(
        id: 'tr_temp_quiz',
        lessonId: 'tr_temperature_crash',
        questions: [
          const QuizQuestion(
            id: 'tr_temp_q1',
            question:
                'What is the safest rate to restore temperature after a temperature crash?',
            options: [
              'As fast as possible — add boiling water to the tank to restore immediately',
              'No more than 1–2°C per hour — rapid rewarming causes thermal shock',
              'Exactly 5°C per hour is the recommended safe rate',
              'Temperature should only ever be restored by replacing the heater — no manual intervention',
            ],
            correctIndex: 1,
            explanation:
                'Whether cooling or warming, rapid temperature changes are highly stressful for fish. After a crash, restoration should be gradual — no faster than 1–2°C per hour. Using sealed bottles of warm water, raised room temperature, and insulation achieves this safely.',
          ),
          const QuizQuestion(
            id: 'tr_temp_q2',
            question:
                'What is the best long-term strategy to protect against heater failure?',
            options: [
              'Use a heater that\'s double the tank\'s recommended wattage',
              'Run two heaters set 1°C below target temperature, so if one fails the other maintains most of the warmth',
              'Change heaters every 6 months regardless of whether they\'ve failed',
              'Only heat the room, not the tank directly',
            ],
            correctIndex: 1,
            explanation:
                'Running two smaller heaters is the standard approach for valuable fish. Each set 1°C below target means neither overheats the tank alone, but if one fails, the other keeps temperature close to target, preventing a catastrophic crash before you can respond.',
          ),
          const QuizQuestion(
            id: 'tr_temp_q3',
            question:
                'A heater stuck in the ON position is dangerous because:',
            options: [
              'It causes electrical fires that can damage the entire aquarium cabinet',
              'It continuously raises water temperature, potentially cooking fish before you notice',
              'It overloads the filter motor, causing simultaneous filter failure',
              'A heater stuck ON is actually beneficial — fish prefer warmer water',
            ],
            correctIndex: 1,
            explanation:
                'A heater with a stuck-ON thermostat will run continuously, raising temperature well past the target — sometimes by 10°C or more in small tanks. Fish can die from heat stress as surely as cold. This is why checking the thermometer at every tank visit is non-negotiable.',
          ),
        ],
      ),
    ),

    // TR-6: pH Crash / Overnight Death
    Lesson(
      id: 'tr_ph_crash',
      pathId: 'troubleshooting',
      title: 'pH Crash and Overnight Deaths',
      description: 'What causes the tank to crash overnight — and how to prevent it',
      orderIndex: 5,
      xpReward: 60,
      estimatedMinutes: 7,
      prerequisites: ['tr_emergency', 'wp_ph'],
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Overnight Mystery',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'You check the tank before bed — everything looks fine. You wake up and find fish dead. No visible disease, no obvious contamination. The most common culprit is a pH crash: a rapid, dramatic drop in water pH during the night. Understanding why this happens, and how to prevent it, is one of the most important pieces of aquarium knowledge you can have.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Why pH Crashes Overnight',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'During the day, plants photosynthesize — they consume CO₂ and produce oxygen, which drives pH up. At night, photosynthesis stops. Plants and fish both respire — releasing CO₂, which dissolves in water to form carbonic acid, lowering pH. In a well-planted, soft water tank with low buffering capacity (KH below 3°dKH), pH can drop 1–2 full units between lights-off and morning.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Heavily planted tank + soft water (low KH) = maximum pH crash risk\n• CO₂ injection systems that run overnight amplify the problem dramatically\n• Overcrowded tanks (high respiration load) and low surface agitation worsen pH swings\n• A drop from pH 7.4 in the evening to pH 6.0 at dawn is not unusual in vulnerable setups',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'KH (carbonate hardness) is your pH buffer. KH above 4°dKH provides sufficient buffering to resist overnight pH crashes in most setups. If your KH is very low (soft water, RO water), pH instability is a constant risk. Always test KH alongside pH when investigating overnight deaths.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'What to Check First',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '1. Test pH in the morning (before lights on) AND in the evening (before lights off)\n2. Test KH — if below 3°dKH, pH crash is highly likely\n3. Check CO₂ injection schedule — ensure it turns off 1–2 hours before lights-off\n4. Check surface agitation at night — poor surface movement means CO₂ accumulates\n5. Review plant-to-fish ratio — heavily planted tanks with many fish have high overnight CO₂ production',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Prevention Strategies',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• Increase surface agitation at night — a surface-agitating filter outlet or air stone running overnight drives off CO₂\n• Raise KH to 4–6°dKH using crushed coral in the filter, or commercial KH buffer products\n• Set CO₂ on a timer — turn it off 1–2 hours before lights out, or use a pH controller\n• Consider an air pump on a timer — runs at night only to increase surface gas exchange\n• Regular water changes top up KH naturally if tap water has moderate hardness',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Other Causes of Overnight Deaths',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Not all overnight deaths are pH crashes. Run through this differential diagnosis when you find dead fish in the morning:',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• pH crash (see above) — test morning pH vs evening pH\n• Oxygen depletion — common in hot weather, overstocked tanks, heavy algae blooms that respire at night\n• Ammonia spike — cycle crash, dead fish you hadn\'t found, filter failure\n• CO₂ overdose — CO₂ injection set too high, fish suffocate\n• Poisoning — new decor or substrate leaching toxins, household chemicals near the tank\n• Predation — older fish (angels, larger cichlids) hunting at night when lights are off',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'If multiple fish die overnight with no obvious cause, test everything before adding new fish: ammonia, nitrite, pH (morning AND evening), KH, and oxygen if you have an oxygen probe. The cause must be identified and resolved before stocking again.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'A simple and inexpensive prevention method: run an air stone on a timer from lights-off to lights-on. It increases surface agitation, drives off CO₂, and raises dissolved oxygen overnight — addressing two common overnight death causes simultaneously.',
        ),
        const LessonSection(
          type: LessonSectionType.funFact,
          content:
              'Natural Amazonian blackwater streams have pH as low as 3.5 — similar to orange juice. Fish like cardinal tetras and wild discus evolved to tolerate these extreme conditions. However, they\'re adapted to stable low-pH, not rapid pH swings. Even acid-tolerant species suffer from rapid pH changes more than from sustained low pH.',
        ),
      ],
      quiz: Quiz(
        id: 'tr_ph_quiz',
        lessonId: 'tr_ph_crash',
        questions: [
          const QuizQuestion(
            id: 'tr_ph_q1',
            question:
                'Why does pH tend to drop overnight in planted aquariums?',
            options: [
              'Lights going off causes a chemical reaction that acidifies water',
              'Fish produce more ammonia at night, which is acidic',
              'Plants stop photosynthesizing and switch to respiration, releasing CO₂ that forms carbonic acid',
              'Heaters turn off overnight, and cooler water is naturally more acidic',
            ],
            correctIndex: 2,
            explanation:
                'During photosynthesis, plants consume CO₂ and produce O₂, raising pH. At night, plants respire — consuming O₂ and releasing CO₂. CO₂ dissolves to form carbonic acid, lowering pH. In soft water with low KH (buffering capacity), this overnight CO₂ accumulation causes significant pH crashes.',
          ),
          const QuizQuestion(
            id: 'tr_ph_q2',
            question:
                'What water parameter is most important for preventing pH crashes?',
            options: [
              'GH (general hardness) above 10°dGH',
              'KH (carbonate hardness) — it buffers against pH swings',
              'TDS (total dissolved solids) above 500ppm',
              'Nitrate below 10ppm',
            ],
            correctIndex: 1,
            explanation:
                'KH (carbonate hardness) is the pH buffer. Carbonate ions neutralise acids before they can lower pH. KH above 4°dKH provides resistance to overnight pH crashes. In soft water or RO-heavy setups with very low KH, pH crashes are much more likely and can be severe.',
          ),
          const QuizQuestion(
            id: 'tr_ph_q3',
            question:
                'What is the simplest prevention measure for overnight pH crashes in a planted tank?',
            options: [
              'Add a strong acid buffer to maintain a stable low pH',
              'Run an air stone or surface agitation from lights-off to lights-on to drive off overnight CO₂',
              'Remove all plants from the tank — only fish cause pH changes',
              'Increase CO₂ injection to counteract nighttime oxygen changes',
            ],
            correctIndex: 1,
            explanation:
                'Surface agitation during lights-off drives CO₂ out of the water before it can accumulate to acidic levels. An air pump on a timer — off during the day (so it doesn\'t strip CO₂ needed for plant growth), on at night — is one of the cheapest and most effective ways to prevent overnight pH crashes.',
          ),
        ],
      ),
    ),
  ],
);
