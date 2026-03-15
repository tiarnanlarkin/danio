// Story content for interactive narrative scenarios
// Educational stories across different difficulty levels

library;

import '../models/story.dart';

class Stories {
  // ==========================================
  // BEGINNER STORIES
  // ==========================================

  static const Story newTankSetup = Story(
    id: 'new_tank_setup',
    title: 'New Tank Setup',
    description:
        'Guide your first aquarium through the cycling process and prepare it for fish',
    difficulty: StoryDifficulty.beginner,
    estimatedMinutes: 8,
    xpReward: 75,
    thumbnailImage: '🐟',
    scenes: [
      StoryScene(
        id: 'intro',
        text:
            'You have just bought your first aquarium! A beautiful 20-gallon tank sits empty on its stand. Your friend Alex, an experienced aquarist, stops by to help you set it up.\n\n"Excited to get fish?" Alex asks with a knowing smile. "First things first - we need to cycle this tank. What is your first step?"',
        choices: [
          StoryChoice(
            id: 'fill_add_fish',
            text: 'Fill it with water and add fish immediately',
            nextSceneId: 'bad_start',
            isCorrect: false,
            feedback: 'Not quite! Adding fish immediately can be dangerous.',
          ),
          StoryChoice(
            id: 'fill_cycle',
            text: 'Fill it, add dechlorinator, and start cycling',
            nextSceneId: 'cycling_begins',
            isCorrect: true,
            feedback: 'Perfect! You understand the importance of cycling.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'add_substrate',
            text: 'Add substrate and decorations first',
            nextSceneId: 'setup_first',
            isCorrect: true,
            feedback: 'Good thinking! Setting up first is smart.',
            xpModifier: 5,
          ),
        ],
      ),
      StoryScene(
        id: 'bad_start',
        text:
            'Alex shakes their head. "That would be New Tank Syndrome - the ammonia from fish waste would spike before beneficial bacteria establish. Your fish could die within days."\n\n"Let\'s do this right," Alex suggests. What should you do?',
        choices: [
          StoryChoice(
            id: 'learn_cycle',
            text: 'Learn about the nitrogen cycle first',
            nextSceneId: 'cycling_begins',
            isCorrect: true,
            feedback: 'Great decision! Knowledge is power.',
          ),
        ],
      ),
      StoryScene(
        id: 'setup_first',
        text:
            'You carefully add substrate, arrange rocks and driftwood, and install the filter and heater. Alex nods approvingly.\n\n"Now fill it up with dechlorinated water," Alex says. "Then we\'ll add bacteria starter to begin cycling."',
        choices: [
          StoryChoice(
            id: 'continue_setup',
            text: 'Fill the tank and add bacteria starter',
            nextSceneId: 'cycling_begins',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'cycling_begins',
        text:
            'Week 1: Your tank is running! Alex helps you test the water. "We need to add an ammonia source to feed the bacteria that will colonize your filter," Alex explains.\n\nWhat\'s the best approach?',
        choices: [
          StoryChoice(
            id: 'ghost_feeding',
            text: 'Add fish food daily (fishless cycling)',
            nextSceneId: 'week_two',
            isCorrect: true,
            feedback: 'Perfect! Fishless cycling is humane and effective.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'hardy_fish',
            text: 'Add a few hardy fish to produce ammonia',
            nextSceneId: 'fish_in_cycle',
            isCorrect: false,
            feedback: 'This works but stresses fish. Fishless is better.',
          ),
          StoryChoice(
            id: 'pure_ammonia',
            text: 'Add pure ammonia solution',
            nextSceneId: 'week_two',
            isCorrect: true,
            feedback: 'Excellent! This gives precise control.',
            xpModifier: 15,
          ),
        ],
      ),
      StoryScene(
        id: 'fish_in_cycle',
        text:
            'You add a few zebra danios. They swim around, but Alex warns you: "You\'ll need to do daily water changes to keep ammonia safe. It\'s more work and stressful for the fish."\n\nAfter a week of daily testing and water changes, the cycle progresses...',
        choices: [
          StoryChoice(
            id: 'continue_fish_cycle',
            text: 'Continue with daily monitoring',
            nextSceneId: 'week_two',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'week_two',
        text:
            'Week 2-3: Your tests show ammonia dropping and nitrite rising! "The first bacteria colony is working," Alex explains. "Now we wait for nitrite-consuming bacteria."\n\nYou\'re getting impatient. What do you do?',
        choices: [
          StoryChoice(
            id: 'be_patient',
            text: 'Wait patiently and keep testing',
            nextSceneId: 'cycle_complete',
            isCorrect: true,
            feedback: 'Patience is crucial in fishkeeping!',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'add_more_bacteria',
            text: 'Add more bacteria starter to speed things up',
            nextSceneId: 'cycle_complete',
            isCorrect: true,
            feedback: 'This can help, but patience is still needed.',
            xpModifier: 5,
          ),
          StoryChoice(
            id: 'add_fish_now',
            text: 'The water looks clear - add fish now',
            nextSceneId: 'nitrite_spike',
            isCorrect: false,
            feedback: 'Clear water doesn\'t mean it\'s safe!',
          ),
        ],
      ),
      StoryScene(
        id: 'nitrite_spike',
        text:
            'The fish you added become lethargic within hours. Alex tests the water: "Nitrite is at 2ppm - that\'s toxic!"\n\nYou do an emergency 50% water change. "This is why we test," Alex says gently. The cycle needs more time.',
        choices: [
          StoryChoice(
            id: 'learn_lesson',
            text: 'Let the cycle finish properly',
            nextSceneId: 'cycle_complete',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'cycle_complete',
        text:
            'Week 4-6: Success! Your tests show:\n• Ammonia: 0 ppm\n• Nitrite: 0 ppm\n• Nitrate: 20 ppm\n\n"Your tank is cycled!" Alex celebrates. "Those nitrates prove the full nitrogen cycle is working. Now you can add fish slowly."\n\nHow many fish will you add first?',
        choices: [
          StoryChoice(
            id: 'slow_stock',
            text: 'Just 3-4 small fish to start',
            nextSceneId: 'success_ending',
            isCorrect: true,
            feedback: 'Perfect! Slow stocking prevents mini-cycles.',
            xpModifier: 15,
          ),
          StoryChoice(
            id: 'full_stock',
            text: 'Fill the tank - it\'s ready!',
            nextSceneId: 'careful_ending',
            isCorrect: false,
            feedback: 'This might overwhelm the bacteria colony.',
          ),
        ],
      ),
      StoryScene(
        id: 'success_ending',
        text:
            'Three weeks later, your tank is thriving! You have slowly added fish, and everyone is healthy and active. The water parameters stay perfect.\n\n"You did great," Alex says proudly. "You have the patience to be an excellent fishkeeper."\n\n🎉 Congratulations! You have successfully cycled your first tank!',
        choices: [],
        isFinalScene: true,
        successMessage:
            'You\'ve mastered the nitrogen cycle - the foundation of fishkeeping!',
      ),
      StoryScene(
        id: 'careful_ending',
        text:
            'You stock the tank fully. Initially it seems fine, but after a few days you notice cloudy water and stressed fish. Tests show a mini-cycle starting.\n\nYou do water changes and reduce feeding. Alex helps you through it, and eventually the bacteria catch up.\n\n"You made it work," Alex says, "but slow stocking is easier on everyone."\n\n✓ Tank cycled - lessons learned!',
        choices: [],
        isFinalScene: true,
        successMessage: 'Success! Though patience would have made it smoother.',
      ),
    ],
  );

  static const Story firstFish = Story(
    id: 'first_fish',
    title: 'Choosing Your First Fish',
    description:
        'Navigate the fish store and choose compatible species for your beginner tank',
    difficulty: StoryDifficulty.beginner,
    estimatedMinutes: 6,
    xpReward: 60,
    thumbnailImage: '🐠',
    scenes: [
      StoryScene(
        id: 'intro',
        text:
            'Your tank has been cycled for a week - it\'s time to get fish! You walk into Aquatic Dreams, a local fish store. The rows of colorful tanks are mesmerizing.\n\nThe shop owner, Maria, greets you. "First tank?" she asks with a warm smile. "What size is it?"',
        choices: [
          StoryChoice(
            id: 'answer_size',
            text: '"It\'s a 20-gallon freshwater tank"',
            nextSceneId: 'store_tour',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'store_tour',
        text:
            '"Perfect starter size!" Maria leads you through the store. You pass stunning bettas, schools of neon tetras, and interesting bottom-feeders.\n\n"What catches your eye?" Maria asks. Several tanks appeal to you:',
        choices: [
          StoryChoice(
            id: 'choose_betta',
            text: 'The beautiful betta fish',
            nextSceneId: 'betta_choice',
            isCorrect: true,
            feedback: 'Bettas make great starter fish!',
          ),
          StoryChoice(
            id: 'choose_goldfish',
            text: 'The cute goldfish',
            nextSceneId: 'goldfish_warning',
            isCorrect: false,
            feedback: 'Goldfish need bigger tanks and cold water.',
          ),
          StoryChoice(
            id: 'choose_tetras',
            text: 'The schooling neon tetras',
            nextSceneId: 'tetra_choice',
            isCorrect: true,
            feedback: 'Tetras are excellent community fish!',
          ),
          StoryChoice(
            id: 'choose_cichlids',
            text: 'The colorful cichlids',
            nextSceneId: 'cichlid_warning',
            isCorrect: false,
            feedback: 'Most cichlids are too aggressive for beginners.',
          ),
        ],
      ),
      StoryScene(
        id: 'goldfish_warning',
        text:
            'Maria shakes her head gently. "Goldfish are cold-water fish and produce massive waste. A single fancy goldfish needs at least 20 gallons, and common goldfish need 40+ gallons."\n\n"For a tropical 20-gallon, let me show you better options."',
        choices: [
          StoryChoice(
            id: 'see_options',
            text: 'Look at other fish',
            nextSceneId: 'store_tour',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'cichlid_warning',
        text:
            '"Those African cichlids are beautiful," Maria says, "but they\'re aggressive and need hard, alkaline water. They\'re really for experienced keepers with specific setups."\n\n"Let me show you friendlier options for a community tank."',
        choices: [
          StoryChoice(
            id: 'see_options',
            text: 'Explore community fish',
            nextSceneId: 'store_tour',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'betta_choice',
        text:
            'You pick a gorgeous blue betta with flowing fins. "Great choice!" Maria says. "Bettas are perfect for beginners. But remember - only ONE male betta per tank."\n\n"What would you like to add with your betta?"',
        choices: [
          StoryChoice(
            id: 'betta_alone',
            text: 'Keep the betta alone',
            nextSceneId: 'betta_solo_tank',
            isCorrect: true,
            feedback: 'Bettas can thrive alone!',
            xpModifier: 5,
          ),
          StoryChoice(
            id: 'add_cories',
            text: 'Add corydoras catfish',
            nextSceneId: 'good_community',
            isCorrect: true,
            feedback: 'Perfect! Cories are betta-compatible.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'add_guppies',
            text: 'Add colorful guppies',
            nextSceneId: 'risky_combo',
            isCorrect: false,
            feedback: 'Risky - bettas often nip guppy fins.',
          ),
        ],
      ),
      StoryScene(
        id: 'tetra_choice',
        text:
            '"Neon tetras!" Maria smiles. "They\'re peaceful, beautiful, and easy to care for. But tetras are schooling fish - you need at least 6."\n\nShe nets six neon tetras. "What else interests you?"',
        choices: [
          StoryChoice(
            id: 'add_cories',
            text: 'Corydoras for the bottom',
            nextSceneId: 'good_community',
            isCorrect: true,
            feedback: 'Excellent community planning!',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'add_more_tetras',
            text: 'Different tetra species',
            nextSceneId: 'multi_tetra',
            isCorrect: true,
            feedback: 'Multi-species tetra tanks are beautiful!',
            xpModifier: 5,
          ),
          StoryChoice(
            id: 'add_pleco',
            text: 'A plecostomus for algae',
            nextSceneId: 'pleco_warning',
            isCorrect: false,
            feedback: 'Common plecos get too large!',
          ),
        ],
      ),
      StoryScene(
        id: 'betta_solo_tank',
        text:
            'You set up a beautiful betta-only tank with silk plants and a smooth cave. Your betta, which you name Azure, explores every corner and builds a bubble nest.\n\n"He\'s happy," Maria notes on your follow-up visit. "Solo bettas often show the best personality."\n\n🎉 Perfect betta setup!',
        choices: [],
        isFinalScene: true,
        successMessage: 'Your betta is thriving in his personal paradise!',
      ),
      StoryScene(
        id: 'risky_combo',
        text:
            'You add the guppies, but within two days, you notice they have torn fins. The betta has been nipping them at night.\n\nMaria helps you return the guppies. "Bettas are unpredictable with flashy tank mates," she explains. "Let\'s try snails or shrimp instead."',
        choices: [
          StoryChoice(
            id: 'add_snails',
            text: 'Add nerite snails',
            nextSceneId: 'peaceful_ending',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'good_community',
        text:
            'You add six corydoras catfish to go with your schooling fish. They immediately start sifting through the substrate, looking adorable.\n\n"Perfect combination," Maria approves. "Peaceful mid-level swimmers and bottom feeders. Watch them thrive!"',
        choices: [
          StoryChoice(
            id: 'maybe_snail',
            text: 'Add a nerite snail for algae control',
            nextSceneId: 'complete_community',
            isCorrect: true,
            feedback: 'Great finishing touch!',
            xpModifier: 5,
          ),
          StoryChoice(
            id: 'done_stocking',
            text: 'That\'s enough for now',
            nextSceneId: 'peaceful_ending',
            isCorrect: true,
            feedback: 'Wise restraint!',
          ),
        ],
      ),
      StoryScene(
        id: 'multi_tetra',
        text:
            'You add ember tetras and cardinal tetras, creating a vibrant mixed school. They swim together beautifully.\n\n"Some aquarists worry about mixing species," Maria says, "but peaceful tetras often school together. Looking good!"',
        choices: [
          StoryChoice(
            id: 'add_bottom',
            text: 'Add bottom feeders',
            nextSceneId: 'good_community',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'pleco_warning',
        text:
            '"That\'s a common pleco," Maria warns. "They can grow to 18 inches (45cm+)! Way too big for a 20-gallon."\n\nShe shows you smaller alternatives: "Bristlenose plecos stay under 5 inches, or consider otocinclus catfish."',
        choices: [
          StoryChoice(
            id: 'bristlenose',
            text: 'Choose a bristlenose pleco',
            nextSceneId: 'good_community',
            isCorrect: true,
            feedback: 'Much better size!',
          ),
          StoryChoice(
            id: 'otos',
            text: 'Choose otocinclus catfish',
            nextSceneId: 'good_community',
            isCorrect: true,
            feedback: 'Great algae eaters!',
          ),
        ],
      ),
      StoryScene(
        id: 'complete_community',
        text:
            'Two months later, your tank is a masterpiece! Tetras school gracefully, corydoras play in the sand, and your nerite snail keeps the glass spotless.\n\nMaria visits and gasps: "This is magazine-worthy! You\'ve built a perfect beginner community tank."\n\n🎉 Master aquarist in the making!',
        choices: [],
        isFinalScene: true,
        successMessage: 'You\'ve created a thriving, compatible community!',
      ),
      StoryScene(
        id: 'peaceful_ending',
        text:
            'Your tank settles into a peaceful routine. The fish are active and healthy, displaying vibrant colors. You\'ve learned to feed properly and maintain water quality.\n\n"You\'ve got this," Maria says on your next visit. "Ready for your next tank?"\n\n✓ First fish - success!',
        choices: [],
        isFinalScene: true,
        successMessage: 'Your first fish are happy and healthy!',
      ),
    ],
  );

  static const Story waterChangeDay = Story(
    id: 'water_change_day',
    title: 'Water Change Day',
    description:
        'Learn the proper routine for weekly maintenance and water changes',
    difficulty: StoryDifficulty.beginner,
    estimatedMinutes: 5,
    xpReward: 50,
    thumbnailImage: '💧',
    scenes: [
      StoryScene(
        id: 'intro',
        text:
            'It\'s Sunday morning - your weekly water change day! Your 20-gallon tank has been running smoothly for a month. You check your notes: last water change was 7 days ago.\n\nWhat\'s your first step?',
        choices: [
          StoryChoice(
            id: 'test_first',
            text: 'Test water parameters first',
            nextSceneId: 'testing',
            isCorrect: true,
            feedback: 'Great! Always test before water changes.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'just_change',
            text: 'Start removing water immediately',
            nextSceneId: 'premature_change',
            isCorrect: false,
            feedback: 'Testing first helps you know what\'s needed.',
          ),
        ],
      ),
      StoryScene(
        id: 'testing',
        text:
            'You test the water:\n• Ammonia: 0 ppm ✓\n• Nitrite: 0 ppm ✓\n• Nitrate: 30 ppm (was 10ppm last week)\n• pH: 7.2 ✓\n\n"Nitrate is building up as expected," you note. Time for the water change!',
        choices: [
          StoryChoice(
            id: 'prepare_change',
            text: 'Prepare for water change',
            nextSceneId: 'water_removal',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'premature_change',
        text:
            'You start removing water, but then wonder - how much should you remove? And what are the current parameters?\n\nYou stop and test the water first. Knowledge is power!',
        choices: [
          StoryChoice(
            id: 'test_now',
            text: 'Check parameters',
            nextSceneId: 'testing',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'water_removal',
        text:
            'Time to remove water! You have a gravel vacuum and buckets ready. How much water will you change?',
        choices: [
          StoryChoice(
            id: 'change_25',
            text: '25% (5 gallons)',
            nextSceneId: 'good_amount',
            isCorrect: true,
            feedback: 'Perfect! 25% weekly is ideal.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'change_50',
            text: '50% (10 gallons)',
            nextSceneId: 'big_change',
            isCorrect: true,
            feedback: 'This works for high nitrates!',
            xpModifier: 5,
          ),
          StoryChoice(
            id: 'change_10',
            text: '10% (2 gallons)',
            nextSceneId: 'too_small',
            isCorrect: false,
            feedback: 'Too small - nitrates won\'t drop much.',
          ),
        ],
      ),
      StoryScene(
        id: 'good_amount',
        text:
            'You use the gravel vacuum to remove 5 gallons, vacuuming the substrate as you go. Debris and mulm get sucked up - gross but satisfying!\n\nThe fish seem curious about the vacuum. What\'s next?',
        choices: [
          StoryChoice(
            id: 'prepare_new',
            text: 'Prepare replacement water',
            nextSceneId: 'new_water_prep',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'big_change',
        text:
            'You remove 10 gallons - a big change! This will really crash those nitrates. You vacuum heavily, getting deep into the gravel.\n\n"Easy on the beneficial bacteria," you remind yourself as you work.',
        choices: [
          StoryChoice(
            id: 'prepare_new',
            text: 'Prepare replacement water',
            nextSceneId: 'new_water_prep',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'too_small',
        text:
            'You remove just 2 gallons. But thinking about it - that\'s only 10%. Your nitrates won\'t drop much.\n\nYou decide to remove more water. Better to do it right!',
        choices: [
          StoryChoice(
            id: 'remove_more',
            text: 'Remove 3 more gallons (25% total)',
            nextSceneId: 'good_amount',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'new_water_prep',
        text:
            'You fill buckets with tap water. Before adding it to the tank, you need to treat it. What do you add?',
        choices: [
          StoryChoice(
            id: 'dechlorinator',
            text: 'Dechlorinator/water conditioner',
            nextSceneId: 'temp_check',
            isCorrect: true,
            feedback: 'Essential! Chlorine kills beneficial bacteria.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'nothing',
            text: 'Nothing - tap water is fine',
            nextSceneId: 'chlorine_danger',
            isCorrect: false,
            feedback: 'Chlorine in tap water is toxic!',
          ),
          StoryChoice(
            id: 'let_sit',
            text: 'Let it sit 24 hours to dechlorinate',
            nextSceneId: 'old_method',
            isCorrect: false,
            feedback:
                'This works but dechlorinator is faster and handles chloramine.',
          ),
        ],
      ),
      StoryScene(
        id: 'chlorine_danger',
        text:
            'Wait! Tap water contains chlorine and possibly chloramine - both toxic to fish and beneficial bacteria.\n\nYou quickly add water conditioner before adding the water to your tank. Crisis averted!',
        choices: [
          StoryChoice(
            id: 'now_temp',
            text: 'Check water temperature',
            nextSceneId: 'temp_check',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'old_method',
        text:
            'Letting water sit works for chlorine, but not for chloramine (which many cities now use). Plus it takes 24 hours!\n\n"Water conditioner is faster and safer," you realize, adding some.',
        choices: [
          StoryChoice(
            id: 'continue',
            text: 'Continue with water change',
            nextSceneId: 'temp_check',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'temp_check',
        text:
            'Before adding the new water, you check temperature:\n• Tank water: 76°F (24°C)\n• New water: 65°F (18°C)\n\nThat\'s an 11°F (6°C) difference! What do you do?',
        choices: [
          StoryChoice(
            id: 'warm_it',
            text: 'Warm the new water to match tank temp',
            nextSceneId: 'perfect_match',
            isCorrect: true,
            feedback: 'Excellent! Temperature matching prevents shock.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'add_slow',
            text: 'Add it slowly - fish will adjust',
            nextSceneId: 'slow_add',
            isCorrect: false,
            feedback: 'Even slow addition can shock fish.',
          ),
        ],
      ),
      StoryScene(
        id: 'perfect_match',
        text:
            'You add hot water to warm the new water to 76°F (24°C). Perfect match!\n\nYou slowly pour the water back into the tank, aiming for the decorations to diffuse the flow. The fish seem unbothered.',
        choices: [
          StoryChoice(
            id: 'finish_up',
            text: 'Complete the water change',
            nextSceneId: 'completion',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'slow_add',
        text:
            'You start adding the cold water slowly. Your fish immediately hide and seem stressed - even gradual temperature changes can shock them.\n\nYou stop and warm the remaining water to tank temperature.',
        choices: [
          StoryChoice(
            id: 'fix_temp',
            text: 'Match temperature properly',
            nextSceneId: 'perfect_match',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'completion',
        text:
            'Water change complete! Your tank looks crystal clear. You test the water again:\n• Nitrate: 15 ppm (down from 30!)\n\nThe fish come out to explore, more active than before. You take notes in your maintenance log.\n\n✓ Perfect water change routine!',
        choices: [],
        isFinalScene: true,
        successMessage:
            'You\'ve mastered the weekly water change - the key to fishkeeping success!',
      ),
    ],
  );

  // ==========================================
  // INTERMEDIATE STORIES
  // ==========================================

  static const Story algaeOutbreak = Story(
    id: 'algae_outbreak',
    title: 'Algae Outbreak',
    description:
        'Diagnose and solve an algae problem through systematic troubleshooting',
    difficulty: StoryDifficulty.intermediate,
    estimatedMinutes: 7,
    xpReward: 85,
    thumbnailImage: '🔬',
    minLevel: 2,
    scenes: [
      StoryScene(
        id: 'intro',
        text:
            'You return from a week-long vacation to find your beautiful planted tank has turned into a green nightmare! Glass covered in algae, plants coated in hair algae, and the water has a green tint.\n\nYour tank sitter apologetically admits: "I might have overfed them..."\n\nWhat\'s your first move?',
        choices: [
          StoryChoice(
            id: 'assess_damage',
            text: 'Test water and assess the situation',
            nextSceneId: 'testing',
            isCorrect: true,
            feedback: 'Good! Understand the problem first.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'blackout',
            text: 'Do a 3-day blackout immediately',
            nextSceneId: 'hasty_blackout',
            isCorrect: false,
            feedback: 'Blackouts work, but understand the cause first!',
          ),
          StoryChoice(
            id: 'chemicals',
            text: 'Buy algaecide from the fish store',
            nextSceneId: 'chemical_warning',
            isCorrect: false,
            feedback: 'Chemicals treat symptoms, not causes.',
          ),
        ],
      ),
      StoryScene(
        id: 'testing',
        text:
            'You test the water:\n• Ammonia: 0.25 ppm (elevated!)\n• Nitrite: 0 ppm\n• Nitrate: 80 ppm (way too high!)\n• Phosphate: 3 ppm (very high!)\n\n"Overfeeding spiked nutrients," you realize. "Classic algae fuel." What algae types do you see?',
        choices: [
          StoryChoice(
            id: 'identify_algae',
            text: 'Green hair algae and green water',
            nextSceneId: 'action_plan',
            isCorrect: true,
            feedback: 'Correct identification is key!',
          ),
        ],
      ),
      StoryScene(
        id: 'hasty_blackout',
        text:
            'You cover the tank completely for a blackout. After 3 days, you uncover it...\n\nThe algae is somewhat reduced, but it\'s already growing back! Without addressing the root cause (excess nutrients), it will return.\n\n"I need to fix the underlying problem," you realize.',
        choices: [
          StoryChoice(
            id: 'test_now',
            text: 'Test water parameters',
            nextSceneId: 'testing',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'chemical_warning',
        text:
            'You almost buy algaecide, but read reviews: "Killed all my plants!" and "Fish gasping after use!"\n\nChemicals can harm plants and fish while only treating the symptom. Better to fix the root cause.',
        choices: [
          StoryChoice(
            id: 'better_approach',
            text: 'Take a systematic approach',
            nextSceneId: 'testing',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'action_plan',
        text:
            'You develop a battle plan:\n1. Massive water changes to reduce nutrients\n2. Reduce light duration\n3. Manual removal of algae\n4. Add fast-growing plants as competitors\n\nWhat do you tackle first?',
        choices: [
          StoryChoice(
            id: 'water_change',
            text: '50% water change immediately',
            nextSceneId: 'big_change',
            isCorrect: true,
            feedback: 'Great! Dilution is the solution.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'reduce_light',
            text: 'Reduce lighting first',
            nextSceneId: 'lighting_fix',
            isCorrect: true,
            feedback: 'Good thinking - cut the fuel supply.',
            xpModifier: 5,
          ),
        ],
      ),
      StoryScene(
        id: 'big_change',
        text:
            'You do a massive 50% water change, vacuuming deep into the substrate. Tons of detritus comes out!\n\nYou test again:\n• Nitrate: 40 ppm (better!)\n• Phosphate: 1.5 ppm (improving!)\n\n"One water change won\'t fix this," you note. "I\'ll need to do several."',
        choices: [
          StoryChoice(
            id: 'continue_plan',
            text: 'Adjust lighting next',
            nextSceneId: 'lighting_fix',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'lighting_fix',
        text:
            'Your light was on 10 hours a day. You reduce it to 6 hours and lower intensity by 30%.\n\n"Less light means less algae growth," you reason. "But my plants still need enough to thrive."\n\nWhat else can help?',
        choices: [
          StoryChoice(
            id: 'add_plants',
            text: 'Add fast-growing plants',
            nextSceneId: 'plant_competition',
            isCorrect: true,
            feedback: 'Excellent! Plants outcompete algae.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'manual_removal',
            text: 'Manually remove algae',
            nextSceneId: 'removal',
            isCorrect: true,
            feedback: 'Manual removal gives immediate results.',
            xpModifier: 5,
          ),
          StoryChoice(
            id: 'add_algae_eaters',
            text: 'Add algae-eating fish/shrimp',
            nextSceneId: 'cleanup_crew',
            isCorrect: true,
            feedback: 'Natural cleanup crew helps!',
            xpModifier: 5,
          ),
        ],
      ),
      StoryScene(
        id: 'plant_competition',
        text:
            'You add fast-growing stem plants: water sprite, hornwort, and rotala. They\'ll compete with algae for nutrients.\n\n"These will suck up excess nitrates and phosphates," you say. They\'re already pearling oxygen!',
        choices: [
          StoryChoice(
            id: 'next_step',
            text: 'Add cleanup crew',
            nextSceneId: 'cleanup_crew',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'removal',
        text:
            'You spend an hour manually removing hair algae with a toothbrush and scraping glass. It\'s tedious but effective - you remove TONS of algae.\n\n"This gives me a head start," you think. "But I need to prevent regrowth."',
        choices: [
          StoryChoice(
            id: 'biological_help',
            text: 'Add biological helpers',
            nextSceneId: 'cleanup_crew',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'cleanup_crew',
        text:
            'You add:\n• 10 Amano shrimp (hair algae specialists)\n• 5 Otocinclus catfish (diatom/soft algae)\n• 2 Nerite snails (glass cleaning)\n\nThey get to work immediately! The shrimp are visibly eating hair algae.\n\nWhat\'s your ongoing strategy?',
        choices: [
          StoryChoice(
            id: 'maintenance_plan',
            text: 'Establish a prevention routine',
            nextSceneId: 'prevention',
            isCorrect: true,
            feedback: 'Prevention is everything!',
            xpModifier: 10,
          ),
        ],
      ),
      StoryScene(
        id: 'prevention',
        text:
            'You establish new habits:\n• 25% water changes twice weekly (temporarily)\n• Feed less - fish get small meals\n• 6-hour light period\n• Dose fertilizers precisely\n• Trim and remove dead plant matter weekly\n\nAfter 3 weeks, your tank is transformed!',
        choices: [
          StoryChoice(
            id: 'success',
            text: 'Check the results',
            nextSceneId: 'success_ending',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'success_ending',
        text:
            'One month later:\n• Algae: 95% gone\n• Water: Crystal clear\n• Plants: Lush and healthy\n• Nitrate: 15 ppm (stable)\n\nThe cleanup crew maintains things, and your new routine prevents outbreaks. The tank looks better than ever!\n\n🎉 You\'ve mastered algae control through systematic problem-solving!',
        choices: [],
        isFinalScene: true,
        successMessage:
            'Algae defeated! You understand cause, not just treatment.',
      ),
    ],
  );

  static const Story plantParadise = Story(
    id: 'plant_paradise',
    title: 'Plant Paradise',
    description:
        'Set up your first planted tank with proper substrate, lighting, and CO2',
    difficulty: StoryDifficulty.intermediate,
    estimatedMinutes: 8,
    xpReward: 90,
    thumbnailImage: '🌱',
    minLevel: 3,
    prerequisites: ['new_tank_setup'],
    scenes: [
      StoryScene(
        id: 'intro',
        text:
            'Inspired by stunning aquascapes online, you decide to upgrade from plastic plants to a real planted tank. You\'ve been researching for weeks.\n\nYour 20-gallon tank awaits transformation. Where do you start?',
        choices: [
          StoryChoice(
            id: 'plan_first',
            text: 'Plan the aquascape design',
            nextSceneId: 'planning',
            isCorrect: true,
            feedback: 'Planning prevents expensive mistakes!',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'buy_plants',
            text: 'Go buy plants immediately',
            nextSceneId: 'cart_before_horse',
            isCorrect: false,
            feedback: 'You need proper substrate and equipment first!',
          ),
        ],
      ),
      StoryScene(
        id: 'planning',
        text:
            'You sketch out a design: sloping substrate, driftwood focal point, carpet in front, stem plants in back.\n\n"Dutch style or Iwagumi?" you wonder. You decide on a Nature Aquarium style with hardscape.\n\nWhat substrate will you use?',
        choices: [
          StoryChoice(
            id: 'aquasoil',
            text: 'Nutrient-rich aqua soil',
            nextSceneId: 'good_substrate',
            isCorrect: true,
            feedback: 'Premium choice! Plants will thrive.',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'gravel_tabs',
            text: 'Regular gravel with root tabs',
            nextSceneId: 'budget_substrate',
            isCorrect: true,
            feedback: 'Budget-friendly and works well!',
            xpModifier: 5,
          ),
          StoryChoice(
            id: 'regular_gravel',
            text: 'Regular gravel only',
            nextSceneId: 'poor_substrate',
            isCorrect: false,
            feedback: 'Plants need nutrients from substrate!',
          ),
        ],
      ),
      StoryScene(
        id: 'cart_before_horse',
        text:
            'You buy gorgeous plants, but realize - you still have gravel substrate and basic lighting!\n\nThe plants won\'t thrive without proper substrate, light, and nutrients. You quickly return them and research equipment.',
        choices: [
          StoryChoice(
            id: 'plan_now',
            text: 'Plan the setup properly',
            nextSceneId: 'planning',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'good_substrate',
        text:
            'You buy premium aqua soil that slowly releases nutrients. As you layer it (3 inches deep, sloped higher in back), the rich brown substrate looks promising.\n\n"This will buffer pH and feed root-feeders," you note.',
        choices: [
          StoryChoice(
            id: 'lighting_next',
            text: 'Choose lighting',
            nextSceneId: 'lighting_choice',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'budget_substrate',
        text:
            'You use regular aquarium gravel but add Osmocote root tabs under areas where you\'ll plant heavy root feeders.\n\n"Not as fancy as aqua soil," you think, "but it\'ll work with proper dosing."',
        choices: [
          StoryChoice(
            id: 'lighting_next',
            text: 'Choose lighting',
            nextSceneId: 'lighting_choice',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'poor_substrate',
        text:
            'You set up regular gravel, but researching planted tank guides, everyone emphasizes nutrient-rich substrate.\n\nYou decide to invest in proper substrate or at least add root tabs. Plants are worth it!',
        choices: [
          StoryChoice(
            id: 'fix_substrate',
            text: 'Get appropriate substrate',
            nextSceneId: 'planning',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'lighting_choice',
        text:
            'Your basic LED light won\'t cut it for demanding plants. You research options:\n\n• High-light LED (expensive, grows anything, needs CO2)\n• Medium-light LED (affordable, grows most plants)\n• Keep basic light (easy plants only)\n\nWhat do you choose?',
        choices: [
          StoryChoice(
            id: 'high_light',
            text: 'High-light LED with CO2 injection',
            nextSceneId: 'high_tech',
            isCorrect: true,
            feedback: 'High tech setup! Challenging but rewarding.',
            xpModifier: 15,
          ),
          StoryChoice(
            id: 'medium_light',
            text: 'Medium-light LED, no CO2',
            nextSceneId: 'low_tech',
            isCorrect: true,
            feedback: 'Smart choice! Low-tech can be beautiful.',
            xpModifier: 10,
          ),
        ],
      ),
      StoryScene(
        id: 'high_tech',
        text:
            'You invest in a high-PAR LED and CO2 system! Setting up the CO2:\n• Pressurized cylinder\n• Regulator with solenoid\n• Diffuser\n• Drop checker\n\n"This is complex," you realize, "but it unlocks the most demanding plants!"',
        choices: [
          StoryChoice(
            id: 'tune_co2',
            text: 'Dial in CO2 levels (30ppm target)',
            nextSceneId: 'plant_selection_high',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'low_tech',
        text:
            'You buy a quality medium-light LED. No CO2 means easier maintenance, slower growth, and less algae risk.\n\n"Low-tech planted tanks can be stunning," you remind yourself. "Just choose appropriate plants."',
        choices: [
          StoryChoice(
            id: 'pick_plants',
            text: 'Select plants',
            nextSceneId: 'plant_selection_low',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'plant_selection_high',
        text:
            'With high light and CO2, you can grow demanding species!\n\nYou select:\n• Monte Carlo (carpet)\n• Rotala macrandra (red stems)\n• Bucephalandra (detail plant)\n• Pogostemon helferi (texture)\n\n"These need precision care," you note.',
        choices: [
          StoryChoice(
            id: 'plant_setup',
            text: 'Plant the aquascape',
            nextSceneId: 'planting_high_tech',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'plant_selection_low',
        text:
            'For low-tech success, you choose:\n• Java fern (easy, epiphyte)\n• Anubias nana (bulletproof)\n• Cryptocoryne wendtii (low-light champion)\n• Java moss (versatile)\n\n"These will thrive without CO2," you confirm.',
        choices: [
          StoryChoice(
            id: 'plant_setup',
            text: 'Aquascape the tank',
            nextSceneId: 'planting_low_tech',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'planting_high_tech',
        text:
            'You spend hours planting:\n• Carpet plants with tweezers (tedious!)\n• Stems in groups of 3-5\n• Hardscape plants attached with thread\n\nWeek 1: Some melting (expected transition). You dose fertilizers daily and fine-tune CO2.',
        choices: [
          StoryChoice(
            id: 'maintenance',
            text: 'Establish maintenance routine',
            nextSceneId: 'high_tech_maintenance',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'planting_low_tech',
        text:
            'Your low-tech setup comes together beautifully:\n• Java fern/anubias tied to driftwood\n• Crypts planted in substrate\n• Java moss wedged in rock crevices\n\nNo melting! These hardy plants adapt quickly.',
        choices: [
          StoryChoice(
            id: 'maintenance',
            text: 'Establish care routine',
            nextSceneId: 'low_tech_maintenance',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'high_tech_maintenance',
        text:
            'High-tech demands precision:\n• Daily fertilizer dosing (NPK + micros)\n• Weekly 50% water changes\n• CO2 monitoring (drop checker stays green)\n• Trimming every week (plants grow FAST!)\n\nAfter 6 weeks, your carpet is filling in beautifully!',
        choices: [
          StoryChoice(
            id: 'see_results',
            text: 'Admire the results',
            nextSceneId: 'high_tech_success',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'low_tech_maintenance',
        text:
            'Low-tech is forgiving:\n• Weekly liquid fertilizer\n• 25% water changes weekly\n• Occasional trimming (slow growth)\n• Clean glass as needed\n\n"This is relaxing, not stressful!" you realize.',
        choices: [
          StoryChoice(
            id: 'see_results',
            text: 'Enjoy the tank',
            nextSceneId: 'low_tech_success',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'high_tech_success',
        text:
            '3 months later: Your tank is jaw-dropping!\n• Carpet: Fully grown, lush green\n• Red plants: Vibrant crimson\n• Growth: Pearling oxygen visibly\n• Water: Crystal clear\n\nYou enter it in an aquascaping contest and place in the top 10!\n\n🎉 High-tech planted tank mastery!',
        choices: [],
        isFinalScene: true,
        successMessage: 'You\'ve created a world-class planted aquarium!',
      ),
      StoryScene(
        id: 'low_tech_success',
        text:
            '3 months later: Your tank is a peaceful paradise!\n• Plants: Healthy, dark green, zero algae\n• Maintenance: 30 minutes weekly\n• Fish: Thriving in the planted environment\n• Vibe: Natural, zen-like\n\n"This is sustainable long-term," you think contentedly.\n\n✓ Beautiful low-tech planted tank achieved!',
        choices: [],
        isFinalScene: true,
        successMessage:
            'You\'ve mastered the art of sustainable planted aquariums!',
      ),
    ],
  );

  // ==========================================
  // ADVANCED STORIES
  // ==========================================

  static const Story breedingProject = Story(
    id: 'breeding_project',
    title: 'Breeding Project',
    description: 'Set up a breeding program for your favorite species',
    difficulty: StoryDifficulty.advanced,
    estimatedMinutes: 10,
    xpReward: 100,
    thumbnailImage: '🥚',
    minLevel: 4,
    scenes: [
      StoryScene(
        id: 'intro',
        text:
            'Your pair of German Blue Rams have been displaying courtship behavior for weeks. You decide to set up a proper breeding tank.\n\n"Time to try breeding!" you tell your aquarist friend Jamie.\n\n"Cichlid breeding is challenging but rewarding," Jamie says. "Let\'s do this right."\n\nWhat\'s your first step?',
        choices: [
          StoryChoice(
            id: 'research',
            text: 'Research Ram breeding requirements',
            nextSceneId: 'research_phase',
            isCorrect: true,
            feedback: 'Knowledge is power in breeding!',
            xpModifier: 15,
          ),
          StoryChoice(
            id: 'setup_tank',
            text: 'Set up a breeding tank immediately',
            nextSceneId: 'hasty_setup',
            isCorrect: false,
            feedback: 'Research first - breeding has specific needs!',
          ),
        ],
      ),
      StoryScene(
        id: 'research_phase',
        text:
            'You research extensively:\n• Rams prefer 82-86°F for breeding\n• Need soft, acidic water (pH 6.0-6.5)\n• Prefer flat stones for egg-laying\n• Extremely protective parents\n\n"Water chemistry is critical," you note. What will you use for breeding water?',
        choices: [
          StoryChoice(
            id: 'ro_water',
            text: 'RO water remineralized precisely',
            nextSceneId: 'perfect_water',
            isCorrect: true,
            feedback: 'Professional approach!',
            xpModifier: 15,
          ),
          StoryChoice(
            id: 'peat_soften',
            text: 'Peat-filtered water',
            nextSceneId: 'good_water',
            isCorrect: true,
            feedback: 'Old-school method that works!',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'tap_water',
            text: 'Regular tap water',
            nextSceneId: 'wrong_water',
            isCorrect: false,
            feedback: 'Most tap water is too hard for Ram breeding.',
          ),
        ],
      ),
      StoryScene(
        id: 'hasty_setup',
        text:
            'You set up a tank quickly with normal parameters. After introducing the pair, they seem stressed and won\'t breed.\n\nJamie tests the water: "pH 7.6, hard water. Rams need soft, acidic conditions for breeding."\n\nTime to research properly!',
        choices: [
          StoryChoice(
            id: 'do_research',
            text: 'Study Ram breeding requirements',
            nextSceneId: 'research_phase',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'perfect_water',
        text:
            'You invest in an RO unit and remineralization salts. Creating perfect water:\n• RO water base\n• GH: 4-5 dGH\n• KH: 1-2 dKH\n• pH: 6.2\n• Temp: 84°F\n\n"This is breeding-grade water," Jamie confirms. "Now the tank setup."',
        choices: [
          StoryChoice(
            id: 'tank_setup',
            text: 'Set up the breeding tank',
            nextSceneId: 'tank_setup',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'good_water',
        text:
            'You create a peat filter setup that gradually acidifies and softens the water. After a week:\n• pH: 6.4\n• Water is tinted amber (tannins)\n• Soft like rainwater\n\n"Not as precise as RO," Jamie says, "but Rams should like this."',
        choices: [
          StoryChoice(
            id: 'tank_setup',
            text: 'Set up the breeding tank',
            nextSceneId: 'tank_setup',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'wrong_water',
        text:
            'You try using tap water (pH 7.8, very hard). The Rams never spawn despite months of trying.\n\nJamie explains: "In hard water, Ram eggs won\'t develop properly. You need to match their natural Amazon water chemistry."\n\nYou invest in proper water treatment.',
        choices: [
          StoryChoice(
            id: 'fix_water',
            text: 'Create proper breeding water',
            nextSceneId: 'research_phase',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'tank_setup',
        text:
            'Setting up the 20-gallon breeding tank:\n• Bare bottom or sand?\n• Sponge filter (fry-safe)\n• Flat stones for spawning\n• Minimal decor (easy viewing)\n• Heater set to 84°F\n\nWhat substrate do you choose?',
        choices: [
          StoryChoice(
            id: 'bare_bottom',
            text: 'Bare bottom for easy cleaning',
            nextSceneId: 'conditioning',
            isCorrect: true,
            feedback: 'Practical for raising fry!',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'fine_sand',
            text: 'Fine sand (natural for Rams)',
            nextSceneId: 'conditioning',
            isCorrect: true,
            feedback: 'Rams appreciate natural setup!',
            xpModifier: 10,
          ),
        ],
      ),
      StoryScene(
        id: 'conditioning',
        text:
            'Tank ready! Now you condition the breeding pair:\n• High-protein foods (bloodworms, brine shrimp)\n• Multiple small feedings daily\n• Separate male/female temporarily to build desire\n\nAfter 2 weeks, they\'re in peak condition. Time to introduce them!',
        choices: [
          StoryChoice(
            id: 'introduce',
            text: 'Add the pair to breeding tank',
            nextSceneId: 'courtship',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'courtship',
        text:
            'Day 1-3: The Rams display stunning courtship!\n• Color intensifies (male shows iridescent blue)\n• They clean a flat stone together\n• Practice spawning motions\n\nDay 4: Morning check - EGGS! About 150 tiny eggs on the stone. What do you do?',
        choices: [
          StoryChoice(
            id: 'leave_parents',
            text: 'Let parents raise the eggs',
            nextSceneId: 'parent_raising',
            isCorrect: true,
            feedback: 'Natural parenting can work!',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'artificial',
            text: 'Remove eggs to hatchery tumbler',
            nextSceneId: 'artificial_raising',
            isCorrect: true,
            feedback: 'Higher survival rate with artificial raising.',
            xpModifier: 5,
          ),
        ],
      ),
      StoryScene(
        id: 'parent_raising',
        text:
            'You let the parents care for the eggs. They\'re devoted - fanning constantly, removing dead eggs.\n\nDay 3: Eggs hatch into wrigglers! Parents move them to pits they dug in the sand.\n\nDay 7: Free-swimming fry! But the parents seem stressed by your presence. What\'s your approach?',
        choices: [
          StoryChoice(
            id: 'minimal_disturbance',
            text: 'Minimal disturbance, observe from distance',
            nextSceneId: 'successful_raising',
            isCorrect: true,
            feedback: 'Reducing stress is key!',
            xpModifier: 10,
          ),
          StoryChoice(
            id: 'active_management',
            text: 'Actively feed and manage',
            nextSceneId: 'parent_stress',
            isCorrect: false,
            feedback: 'Too much interference can cause parents to eat fry!',
          ),
        ],
      ),
      StoryScene(
        id: 'artificial_raising',
        text:
            'You carefully move the egg-covered stone to a tumbler with methylene blue (prevents fungus).\n\nDay 3: Perfect hatch rate! Wrigglers absorb yolk sacs.\nDay 7: Free-swimming!\n\nYou start feeding infusoria, then baby brine shrimp. Survival rate: 85%!',
        choices: [
          StoryChoice(
            id: 'grow_out',
            text: 'Move fry to grow-out tank',
            nextSceneId: 'growing_fry',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'parent_stress',
        text:
            'Your frequent tank openings and feeding stress the parents. One morning, you find them eating the fry!\n\n"This happens," Jamie consoles. "New parents often fail first spawn. Let them try again - experience helps."',
        choices: [
          StoryChoice(
            id: 'second_attempt',
            text: 'Recondition and try again',
            nextSceneId: 'second_spawn',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'second_spawn',
        text:
            'You recondition the pair and they spawn again 3 weeks later. This time you know to minimize disturbance.\n\nThe parents successfully raise 30 fry to free-swimming stage! "Experience matters," you note.',
        choices: [
          StoryChoice(
            id: 'raise_fry',
            text: 'Raise the fry',
            nextSceneId: 'growing_fry',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'successful_raising',
        text:
            'The parents raise 40 healthy fry! You minimize disturbance and they prove to be excellent parents.\n\nAt 3 weeks, you move fry to a grow-out tank so parents can spawn again.',
        choices: [
          StoryChoice(
            id: 'grow_out',
            text: 'Raise fry to sale size',
            nextSceneId: 'growing_fry',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'growing_fry',
        text:
            '8 weeks of intensive feeding:\n• Week 1-2: Baby brine shrimp 3x daily\n• Week 3-4: Finely crushed flakes\n• Week 5+: Normal foods, sized appropriately\n• Water changes: 25% daily!\n\nThe fry grow to 0.5 inches. Time to find them homes!',
        choices: [
          StoryChoice(
            id: 'sell_fry',
            text: 'Sell to local fish store',
            nextSceneId: 'breeding_success',
            isCorrect: true,
          ),
          StoryChoice(
            id: 'hobbyist_network',
            text: 'Sell through aquarium club',
            nextSceneId: 'breeding_success',
            isCorrect: true,
          ),
        ],
      ),
      StoryScene(
        id: 'breeding_success',
        text:
            '3 months after first spawn:\n• Raised 40+ healthy juvenile Rams\n• Recouped equipment costs\n• Gained invaluable experience\n• Your parent pair spawns every 3-4 weeks now\n\n"You\'re a breeder now," Jamie says proudly. "Ready for more challenging species?"\n\n🎉 Successful breeding program established!',
        choices: [],
        isFinalScene: true,
        successMessage:
            'You\'ve mastered the art and science of fish breeding!',
      ),
    ],
  );

  // ==========================================
  // ALL STORIES LIST
  // ==========================================

  static final List<Story> allStories = [
    // Beginner stories
    newTankSetup,
    firstFish,
    waterChangeDay,

    // Intermediate stories
    algaeOutbreak,
    plantParadise,

    // Advanced stories
    breedingProject,
  ];

  /// Get story by ID
  static Story? getById(String id) {
    try {
      return allStories.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get stories by difficulty
  static List<Story> getByDifficulty(StoryDifficulty difficulty) {
    return allStories.where((s) => s.difficulty == difficulty).toList();
  }

  /// Get unlocked stories for a user
  static List<Story> getUnlockedStories(
    List<String> completedStories,
    int userLevel,
  ) {
    return allStories.where((story) {
      // Check level requirement
      if (userLevel < story.minLevel) return false;

      // Check prerequisites
      if (story.prerequisites.isNotEmpty) {
        return story.prerequisites.every(
          (prereq) => completedStories.contains(prereq),
        );
      }

      return true;
    }).toList();
  }

  /// Get locked stories for display
  static List<Story> getLockedStories(
    List<String> completedStories,
    int userLevel,
  ) {
    return allStories.where((story) {
      if (userLevel < story.minLevel) return true;

      if (story.prerequisites.isNotEmpty) {
        return !story.prerequisites.every(
          (prereq) => completedStories.contains(prereq),
        );
      }

      return false;
    }).toList();
  }
}
