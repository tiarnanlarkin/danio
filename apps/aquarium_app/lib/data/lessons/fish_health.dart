/// Lesson content - Fish Health
/// Part of the lazy-loaded lesson system
library;

import '../../models/tank.dart';
import '../../models/learning.dart';
import '../../models/user_profile.dart';

final fishHealthPath = LearningPath(
  id: 'fish_health',
  title: 'Fish Health & Disease',
  description:
      'Prevent, identify, and treat common fish diseases. Keep your fish healthy!',
  emoji: '🏥',
  recommendedFor: [ExperienceLevel.intermediate],
  orderIndex: 6,
  lessons: [
    // Lesson 33: Disease Prevention 101
    Lesson(
      id: 'fh_prevention',
      pathId: 'fish_health',
      title: 'Disease Prevention 101',
      description: 'An ounce of prevention is worth a pound of cure',
      orderIndex: 0,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Prevention is Key',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Most fish diseases are preventable! Sick fish are usually the result of poor water quality, stress, or poor nutrition - not bad luck.',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              '90% of fish disease is caused by stress. Eliminate stress sources and most problems disappear!',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Prevention Triangle',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **Water Quality**: Test weekly, do water changes religiously\n• **Nutrition**: Varied diet, not just flakes\n• **Stress Reduction**: Proper tank mates, hiding spots, stable conditions',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Quarantine new fish for 2-4 weeks before adding to your main tank. This prevents disease introduction and gives you time to observe!',
        ),
      ],
      quiz: Quiz(
        id: 'fh_prevention_quiz',
        lessonId: 'fh_prevention',
        questions: [
          const QuizQuestion(
            id: 'fh_prev_q1',
            question: 'What causes most fish disease?',
            options: [
              'Bad luck',
              'Stress and poor water quality',
              'Genetics',
              'Temperature',
            ],
            correctIndex: 1,
            explanation:
                'Stress weakens immune systems, making fish vulnerable. Fix the environment, not just the symptoms!',
          ),
        ],
      ),
    ),

    // Lessons 34-38 (condensed for space - would be fully expanded in production)
    Lesson(
      id: 'fh_ich',
      pathId: 'fish_health',
      title: 'Ich: The White Spot Killer',
      description: 'Identify and treat the most common fish disease',
      orderIndex: 1,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'What is Ich?',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Ich (Ichthyophthirius multifiliis) is the most common fish disease in the hobby, and it\'s a parasite — not a bacterium or fungus. It looks like someone sprinkled coarse salt grains all over your fish\'s body, fins, and gills. Nearly every fishkeeper will encounter it at some point, so knowing how to beat it is essential.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'How It Spreads',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Ich is almost always introduced via new fish, plants, or decorations that haven\'t been quarantined. Stressed fish with weakened immune systems are the most vulnerable. This is why quarantine isn\'t optional — it\'s your first line of defence.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'The Life Cycle (This is Crucial!)',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Ich has a 3-stage lifecycle lasting 3–7 days. You can ONLY kill it during the free-swimming stage (tomites). While embedded in your fish (trophonts), medications can\'t reach it.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **Trophont** — The white spot you see on the fish. The parasite feeds under the skin.\n• **Tomont** — Falls off the fish and attaches to surfaces, dividing into hundreds of tomites.\n• **Tomite** — Free-swimming stage! This is when medication and heat work.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Treatment Plan',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              '**Step 1: Raise the temperature** — Gradually increase to 30°C (86°F) over 24–48 hours. Raising temperature speeds up the ich parasite\'s lifecycle, causing it to drop off the fish faster so medication can kill the free-swimming stage. Maintain this temperature for the full treatment duration (usually 10–14 days). Don\'t jump the temperature suddenly.\n\n**Step 2: Add salt** — ⚠️ Salt is irreversible — you cannot remove it by water changes alone. Only use salt treatments in dedicated hospital/quarantine tanks, never in display tanks with live plants or sensitive species. Use aquarium salt at 1–3 teaspoons per gallon (dissolve first!). Salt is effective against the free-swimming stage and is safe for most community fish. Avoid with scaleless species like loaches and catfish.\n\n**Step 3: Commercial medication** — If salt alone isn\'t working, use a copper-based or malachite green treatment. Follow the instructions carefully — copper is toxic in overdoses.\n\n**Step 4: Continue treatment for 7–10 days AFTER the last white spot disappears.** This is the most common mistake. Stopping early leaves surviving tomonts to re-infect your fish.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Remove chemical filter media (activated carbon) before treating with any medication — carbon absorbs the medication and makes it ineffective. You can return the carbon 24 hours after the final treatment dose.',
        ),
      ],
      quiz: Quiz(
        id: 'fh_ich_quiz',
        lessonId: 'fh_ich',
        questions: [
          const QuizQuestion(
            id: 'fh_ich_q1',
            question: 'Which stage of the Ich life cycle can you treat with medication?',
            options: [
              'Trophont (embedded in fish)',
              'Tomont (attached to surfaces)',
              'Tomite (free-swimming)',
              'All stages equally',
            ],
            correctIndex: 2,
            explanation:
                'Only the free-swimming tomites are vulnerable to medication and salt. The embedded and attached stages are protected.',
          ),
          const QuizQuestion(
            id: 'fh_ich_q2',
            question: 'What temperature should you raise your tank to when treating Ich?',
            options: [
              '24°C (75°F)',
              '27°C (80°F)',
              '30°C (86°F)',
              '35°C (95°F)',
            ],
            correctIndex: 2,
            explanation:
                'Gradually raise to 30°C (86°F) to speed up the life cycle, making the parasite vulnerable faster. Never raise temperature suddenly.',
          ),
          const QuizQuestion(
            id: 'fh_ich_q3',
            question: 'How long should you continue Ich treatment after the last spot disappears?',
            options: [
              'Stop immediately',
              '2-3 days',
              '7-10 days',
              '30 days',
            ],
            correctIndex: 2,
            explanation:
                'Continue for 7-10 days after the last visible spot. Stopping early is the most common treatment failure.',
          ),
          const QuizQuestion(
            id: 'fh_ich_q4',
            question: 'Why should you remove carbon from your filter during Ich treatment?',
            options: [
              'It lowers the temperature',
              'It absorbs the medication',
              'It harms beneficial bacteria',
              'It clouds the water',
            ],
            correctIndex: 1,
            explanation:
                'Activated carbon absorbs medications, rendering them ineffective. Remove it during treatment and replace it afterwards.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'fh_fin_rot',
      pathId: 'fish_health',
      title: 'Fin Rot & Bacterial Infections',
      description: 'Bacterial diseases and how to treat them',
      orderIndex: 2,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'What is Fin Rot?',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fin rot is one of the most common bacterial infections in aquarium fish. It typically starts at the edges of the fins — you\'ll notice the fins looking ragged, discoloured (white, red, or black edges), or literally melting away. Left untreated, it can progress to the body and become fatal. The culprits are usually bacteria from the Aeromonas or Pseudomonas families, which are naturally present in aquarium water but only cause trouble when fish are stressed or water quality is poor.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'What Causes It?',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Fin rot is almost always a sign of poor water quality. It\'s your tank telling you something needs to change!',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **High ammonia or nitrite** — The #1 trigger. Test your water first.\n• **Infrequent water changes** — Waste builds up, bacteria thrive.\n• **Overcrowding** — More waste, more stress, more infection risk.\n• **Fin-nipping tank mates** — Physical damage lets bacteria enter.\n• **Stress** — Weakens the fish\'s immune system.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Treatment Plan',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              '**Step 1: Fix the water.** Before any medication, do a 30–50% water change and test your parameters. If ammonia or nitrite are elevated, daily water changes until they reach zero. Many mild cases of fin rot clear up with clean water alone.\n\n**Step 2: Add antibacterial medication** if the fins continue to deteriorate after water quality is corrected. Options include API Fin & Body Cure (minocycline), Maracyn 2, or antibacterial food if the fish is still eating.\n\n**Step 3: Monitor closely.** Healthy fin tissue should start regrowing within 1–2 weeks. Be patient — fins grow slowly. The new growth may appear clear or slightly different in colour at first; this is normal.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Distinguish fin rot from fin-nipping: rot starts at the edges and is usually symmetrical. Nipping has irregular shapes and happens when specific fish are together.',
        ),
      ],
      quiz: Quiz(
        id: 'fh_finrot_quiz',
        lessonId: 'fh_fin_rot',
        questions: [
          const QuizQuestion(
            id: 'fh_finrot_q1',
            question: 'Which bacteria families are most commonly responsible for fin rot?',
            options: [
              'Saprolegnia and Achlya',
              'Aeromonas and Pseudomonas',
              'Ichthyophthirius multifiliis',
              'Nitrobacter and Nitrospira',
            ],
            correctIndex: 1,
            explanation:
                'Aeromonas and Pseudomonas are the usual bacterial culprits behind fin rot. Saprolegnia is fungal, Ichthyophthirius causes Ich, and Nitrobacter/Nitrospira are beneficial bacteria.',
          ),
          const QuizQuestion(
            id: 'fh_finrot_q2',
            question: 'What should be your FIRST step when treating fin rot?',
            options: [
              'Add antibacterial medication immediately',
              'Raise the temperature to 30°C',
              'Do a water change and test your parameters',
              'Remove all tank mates',
            ],
            correctIndex: 2,
            explanation:
                'Always fix water quality first. Many mild fin rot cases clear up with clean water alone. Medication is step 2.',
          ),
          const QuizQuestion(
            id: 'fh_finrot_q3',
            question: 'How can you tell fin rot apart from fin-nipping by tank mates?',
            options: [
              'Fin rot is always black, nipping is always red',
              'Fin rot starts at the edges and is usually symmetrical; nipping is irregular',
              'Fin rot only affects the tail fin',
              'There is no difference between them',
            ],
            correctIndex: 1,
            explanation:
                'Fin rot typically starts at the fin edges and appears relatively symmetrical, while fin-nipping creates irregular, asymmetrical damage.',
          ),
          const QuizQuestion(
            id: 'fh_finrot_q4',
            question: 'How long does it take for new fin tissue to start growing back?',
            options: [
              '24 hours',
              '1-2 days',
              '1-2 weeks',
              '1-2 months',
            ],
            correctIndex: 2,
            explanation:
                'Fin regrowth is slow — expect 1-2 weeks before you see new tissue. Be patient and maintain good water quality throughout.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'fh_fungal',
      pathId: 'fish_health',
      title: 'Fungal Infections',
      description: 'Cotton-like growths and how to treat them',
      orderIndex: 3,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'What Are Fungal Infections?',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Fungal infections in aquarium fish are almost always caused by two genera: Saprolegnia and Achlya. You\'ll recognise them by the distinctive cotton-wool or white fluffy growths on your fish\'s body, mouth, or fins. They look alarming — like someone glued cotton balls to your fish — but they\'re treatable when caught early.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Understanding the Cause',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Fungal infections are almost always SECONDARY. They attack fish that are already stressed, injured, or dealing with poor water quality. The fungus is an opportunist, not the root cause.',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **Physical injuries** — Nipped fins, scrapes from decorations, fights\n• **Poor water quality** — High ammonia, nitrite, or organic waste\n• **Chilling** — Sudden temperature drops suppress the immune system\n• **Unchanged spawning mops or uneaten food** — Organic material fuels fungal spores',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Treatment Plan',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              '**Step 1: Improve water conditions immediately.** Do a 30–50% water change and address the root cause. If there\'s an aggressive tank mate, remove it. If an injury is visible, keep water pristine to prevent further infection.\n\n**Step 2: Apply antifungal treatment.** Over-the-counter antifungal medications containing methylene blue, malachite green, or povidone-iodine are effective. For mild cases, API Fungus Cure or similar products work well. Methylene blue is gentler and safe for most species but will stain your tank sealant blue temporarily.\n\n**Step 3: Salt baths** can help as a supplementary treatment — use 1-3 teaspoons per gallon of aquarium salt. Avoid salt with sensitive scaleless species.\n\n**Step 4: Monitor and maintain.** The cotton-like growth should start to recede within 3–5 days. Continue treatment for the full course recommended on the medication label.',
        ),
        const LessonSection(
          type: LessonSectionType.warning,
          content:
              'Fungal infections on eggs are common and contagious. Remove any white, fuzzy eggs immediately to prevent spread to healthy ones.',
        ),
      ],
      quiz: Quiz(
        id: 'fh_fungal_quiz',
        lessonId: 'fh_fungal',
        questions: [
          const QuizQuestion(
            id: 'fh_fungal_q1',
            question: 'Which two genera cause most fungal infections in aquarium fish?',
            options: [
              'Aeromonas and Pseudomonas',
              'Saprolegnia and Achlya',
              'Ichthyophthirius and Hexamita',
              'Nitrosomonas and Nitrobacter',
            ],
            correctIndex: 1,
            explanation:
                'Saprolegnia and Achlya are the primary fungal culprits. Aeromonas and Pseudomonas are bacterial, not fungal.',
          ),
          const QuizQuestion(
            id: 'fh_fungal_q2',
            question: 'Fungal infections in fish are almost always:',
            options: [
              'Primary infections in healthy fish',
              'Caused by overfeeding alone',
              'Secondary to injury, stress, or poor water quality',
              'Contagious to humans',
            ],
            correctIndex: 2,
            explanation:
                'Fungus is an opportunist. It attacks fish that are already compromised by injuries, stress, or bad water. Fix the root cause!',
          ),
          const QuizQuestion(
            id: 'fh_fungal_q3',
            question: 'What does a fungal infection typically look like on a fish?',
            options: [
              'White salt-like spots',
              'Cotton-wool or fluffy white growths',
              'Red streaks on the body',
              'Black patches on the fins',
            ],
            correctIndex: 1,
            explanation:
                'Fungal infections produce distinctive cotton-wool or fluffy white growths. Salt-like spots are Ich, and red streaks suggest septicaemia.',
          ),
          const QuizQuestion(
            id: 'fh_fungal_q4',
            question: 'What should you do FIRST when treating a fungal infection?',
            options: [
              'Add antifungal medication immediately',
              'Raise temperature to 35°C',
              'Improve water conditions with a water change',
              'Remove all plants from the tank',
            ],
            correctIndex: 2,
            explanation:
                'Always address the root cause first. Clean water and fixing the underlying stressor is step one — medication is step two.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'fh_parasites',
      pathId: 'fish_health',
      title: 'Parasites: Identification & Treatment',
      description: 'Flukes, worms, and other freeloaders',
      orderIndex: 4,
      xpReward: 50,
      estimatedMinutes: 6,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'External Parasites',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'External parasites cause flashing (rubbing against objects), clamped fins, rapid breathing, excess mucus, and visible spots or worms. Unlike Ich, which is a single parasite species, "parasites" covers a wide range of unwelcome visitors. The most common are gill flukes, skin flukes (gyrodactylus), anchor worm (lernea), and fish lice (argulus).',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'How They Get In',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'Parasites are almost always introduced via new fish or plants that weren\'t properly quarantined. This is the single most important reason to quarantine every new addition.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Common Parasites & Treatments',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **Gill flukes & skin flukes** — Microscopic flatworms. Symptoms: rapid gill movement, flashing, mucus. Treat with Praziquantel or Flubendazole.\n• **Anchor worm** — Visible thread-like worms protruding from the fish\'s body. Treat by carefully removing with tweezers + Potassium Permanganate or Dimilin.\n• **Fish lice (Argulus)** — Disc-shaped parasites visible to the naked eye. They move around the fish\'s body. Treat with organophosphate medications or carefully remove manually.\n• **Gill maggots (Ergasilus)** — Attach to gill filaments. Rare but serious. Treat with Praziquantel.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'General Treatment Approach',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              '**Step 1: Identify the parasite.** Look closely at your fish — use a magnifying glass if needed. Visible worms? Anchor worm or lice. Invisible but fish are scratching? Likely flukes.\n\n**Step 2: Isolate affected fish** in a hospital tank for targeted treatment.\n\n**Step 3: Use the correct medication.** Praziquantel is your best all-rounder for flukes and internal tapeworms. For anchor worm and lice, specific treatments like Dimilin or organophosphates are needed.\n\n**Step 4: Treat the whole tank** if the parasite is in the free-swimming stage. For flukes, treat the main tank — they can complete their lifecycle without a fish host.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Epsom salt baths (1 tablespoon per gallon for 15 minutes) can help reduce swelling and discomfort while medications take effect. Never use table salt — it contains anti-caking agents.',
        ),
      ],
      quiz: Quiz(
        id: 'fh_parasites_quiz',
        lessonId: 'fh_parasites',
        questions: [
          const QuizQuestion(
            id: 'fh_para_q1',
            question: 'What is "flashing" in fish?',
            options: [
              'When fish change colour rapidly',
              'When fish rub against objects in the tank',
              'When fish swim upside down',
              'When fish spit out food',
            ],
            correctIndex: 1,
            explanation:
                'Flashing is when fish rub or scrape themselves against tank surfaces. It\'s a classic sign of external parasites causing irritation.',
          ),
          const QuizQuestion(
            id: 'fh_para_q2',
            question: 'Which medication is the best all-rounder for treating flukes?',
            options: [
              'Methylene blue',
              'Copper sulfate',
              'Praziquantel',
              'Amoxicillin',
            ],
            correctIndex: 2,
            explanation:
                'Praziquantel is the go-to medication for flukes and internal tapeworms. Methylene blue is for fungal issues, and amoxicillin is antibacterial.',
          ),
          const QuizQuestion(
            id: 'fh_para_q3',
            question: 'How are parasites most commonly introduced to an aquarium?',
            options: [
              'Through tap water',
              'Via new fish or plants that weren\'t quarantined',
              'From overfeeding',
              'From aquarium lighting',
            ],
            correctIndex: 1,
            explanation:
                'Parasites almost always arrive on new fish or plants. Proper quarantine is your best defence against introducing them.',
          ),
          const QuizQuestion(
            id: 'fh_para_q4',
            question: 'Which parasite is visible as a thread-like worm protruding from the fish?',
            options: [
              'Gill flukes',
              'Anchor worm (Lernea)',
              'Ich',
              'Saprolegnia',
            ],
            correctIndex: 1,
            explanation:
                'Anchor worm appears as a visible thread-like protrusion from the fish\'s body. Flukes are microscopic, Ich causes white spots, and Saprolegnia is fungal.',
          ),
        ],
      ),
    ),

    Lesson(
      id: 'fh_hospital_tank',
      pathId: 'fish_health',
      title: 'Hospital Tank Setup',
      description: 'Treat sick fish without harming your display tank',
      orderIndex: 5,
      xpReward: 50,
      estimatedMinutes: 5,
      sections: [
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Why You Need a Hospital Tank',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'A hospital tank (also called a quarantine or treatment tank) is arguably the most important piece of equipment you\'ll never see in a beautiful aquascape. It lets you medicate sick fish without harming your display tank\'s beneficial bacteria, invertebrates, or plants. Many medications are toxic to shrimp, snails, and the nitrogen cycle bacteria that keep your tank healthy. Treating in your main tank is a last resort.',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Essential Setup',
        ),
        const LessonSection(
          type: LessonSectionType.bulletList,
          content:
              '• **Tank size:** Minimum 20 litres (5 gallons) — larger is better but 20L handles most situations\n• **Bare bottom:** No substrate! This makes waste easy to see and remove, and medication can\'t get absorbed into gravel or sand\n• **Filtration:** A simple sponge filter run by an air pump is ideal. Keep a sponge in your main tank\'s filter to seed it with bacteria, so it\'s always cycled and ready\n• **Heater:** A small, adjustable heater to maintain the right temperature for treatment\n• **Hiding spot:** A PVC pipe or small terracotta pot gives the fish somewhere to feel safe — stressed fish heal slower',
        ),
        const LessonSection(
          type: LessonSectionType.heading,
          content: 'Important Rules',
        ),
        const LessonSection(
          type: LessonSectionType.keyPoint,
          content:
              'NEVER share equipment between your hospital tank and main tank. Nets, siphons, and buckets can transfer disease. Dedicate separate tools and label them clearly.',
        ),
        const LessonSection(
          type: LessonSectionType.text,
          content:
              'Keep the hospital tank bare and simple — no decorations, no plants, no substrate. This isn\'t a display tank; it\'s a medical facility. You need to be able to see every detail of the fish and every speck of waste. Perform daily water changes (25–50%) during treatment to remove medication byproducts and keep water pristine. When treatment is finished, clean everything thoroughly with a bleach solution (10%) and rinse well before storing.',
        ),
        const LessonSection(
          type: LessonSectionType.tip,
          content:
              'Keep a 20-litre tank with a cycled sponge filter ready at all times — even empty. When a fish gets sick, you\'ll be glad you had it set up. It\'s aquarium insurance!',
        ),
      ],
      quiz: Quiz(
        id: 'fh_hospital_quiz',
        lessonId: 'fh_hospital_tank',
        questions: [
          const QuizQuestion(
            id: 'fh_hosp_q1',
            question: 'What is the minimum recommended size for a hospital tank?',
            options: [
              '5 litres (1 gallon)',
              '10 litres (2.5 gallons)',
              '20 litres (5 gallons)',
              '50 litres (13 gallons)',
            ],
            correctIndex: 2,
            explanation:
                'A minimum of 20 litres (5 gallons) is recommended. Smaller tanks are harder to maintain stable water parameters.',
          ),
          const QuizQuestion(
            id: 'fh_hosp_q2',
            question: 'Why should a hospital tank have a bare bottom with no substrate?',
            options: [
              'Substrate makes the tank too heavy',
              'Fish hide in substrate making treatment harder',
              'Waste is easier to see and remove, and medication can\'t be absorbed',
              'Substrate releases ammonia during treatment',
            ],
            correctIndex: 2,
            explanation:
                'A bare bottom lets you see waste clearly and remove it easily. It also prevents substrate from absorbing medications and reducing their effectiveness.',
          ),
          const QuizQuestion(
            id: 'fh_hosp_q3',
            question: 'What should you NEVER do with hospital tank equipment?',
            options: [
              'Use a sponge filter',
              'Heat the water',
              'Share it with your main tank',
              'Keep it running empty',
            ],
            correctIndex: 2,
            explanation:
                'Never share nets, siphons, or buckets between your hospital and main tank — they can transfer disease. Dedicate and label separate tools.',
          ),
          const QuizQuestion(
            id: 'fh_hosp_q4',
            question: 'How do you keep a hospital tank cycled and ready for emergencies?',
            options: [
              'Add bottled bacteria when needed',
              'Keep a sponge filter running in your main tank to seed bacteria',
              'Add fish food daily to build bacteria',
              'Hospital tanks don\'t need to be cycled',
            ],
            correctIndex: 1,
            explanation:
                'Keep a spare sponge filter in your main tank\'s filter compartment. It\'ll be colonised with beneficial bacteria and ready to go when you need it.',
          ),
        ],
      ),
    ),
  ],
);
