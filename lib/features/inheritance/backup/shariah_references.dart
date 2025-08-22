import '../../domain/entities/heir.dart';

/// Comprehensive Shariah references for Islamic inheritance
class ShariahReferences {
  /// Quranic verses related to inheritance
  static const List<QuranicReference> quranicVerses = [
    // Main inheritance verse - Surah An-Nisa 4:11
    QuranicReference(
      surah: 'An-Nisa',
      ayah: 11,
      arabicText: 'يُوصِيكُمُ اللَّهُ فِي أَوْلَادِكُمْ ۖ لِلذَّكَرِ مِثْلُ حَظِّ الْأُنثَيَيْنِ ۚ فَإِن كُنَّ نِسَاءً فَوْقَ اثْنَتَيْنِ فَلَهُنَّ ثُلُثَا مَا تَرَكَ ۖ وَإِن كَانَتْ وَاحِدَةً فَلَهَا النِّصْفُ ۚ وَلِأَبَوَيْهِ لِكُلِّ وَاحِدٍ مِّنْهُمَا السُّدُسُ مِمَّا تَرَكَ إِن كَانَ لَهُ وَلَدٌ ۚ فَإِن لَّمْ يَكُن لَّهُ وَلَدٌ وَوَرِثَهُ أَبَوَاهُ فَلِأُمِّهِ الثُّلُثُ ۚ فَإِن كَانَ لَهُ إِخْوَةٌ فَلِأُمِّهِ السُّدُسُ ۚ مِن بَعْدِ وَصِيَّةٍ يُوصَىٰ بِهَا أَوْ دَيْنٍ ۗ آبَاؤُكُمْ وَأَبْنَاؤُكُمْ لَا تَدْرُونَ أَيُّهُمْ أَقْرَبُ لَكُمْ نَفْعًا ۚ فَرِيضَةً مِّنَ اللَّهِ ۗ إِنَّ اللَّهَ كَانَ عَلِيمًا حَكِيمًا',
      translation: 'Allah commands you regarding your children: for the male, what is equal to the share of two females. But if there are [only] daughters, two or more, for them is two thirds of one\'s estate. And if there is only one, for her is half. And for one\'s parents, to each one of them is a sixth of his estate if he left children. But if he had no children and the parents [alone] inherit from him, then for his mother is one third. And if he had brothers [or sisters], for his mother is a sixth, after any bequest he [may have] made or debt. Your parents or your children - you know not which of them are nearest to you in benefit. [These shares are] an obligation [imposed] by Allah. Indeed, Allah is ever Knowing and Wise.',
      explanation: 'This verse establishes the basic inheritance shares for children and parents. Sons get twice the share of daughters. If there are only daughters, they get 2/3 collectively. If only one daughter, she gets 1/2. Parents get 1/6 each if there are children, but if no children, mother gets 1/3 and father gets the remainder.',
      applicableHeirs: ['son', 'daughter', 'father', 'mother'],
    ),
    
    // Surah An-Nisa 4:12
    QuranicReference(
      surah: 'An-Nisa',
      ayah: 12,
      arabicText: 'وَلَكُمْ نِصْفُ مَا تَرَكَ أَزْوَاجُكُمْ إِن لَّمْ يَكُن لَّهُنَّ وَلَدٌ ۚ فَإِن كَانَ لَهُنَّ وَلَدٌ فَلَكُمُ الرُّبُعُ مِمَّا تَرَكْنَ ۚ مِن بَعْدِ وَصِيَّةٍ يُوصِينَ بِهَا أَوْ دَيْنٍ ۗ وَلَهُنَّ الرُّبُعُ مِمَّا تَرَكْتُمْ إِن لَّمْ يَكُن لَّكُمْ وَلَدٌ ۚ فَإِن كَانَ لَكُمْ وَلَدٌ فَلَهُنَّ الثُّمُنُ مِمَّا تَرَكْتُم ۚ مِّن بَعْدِ وَصِيَّةٍ تُوصُونَ بِهَا أَوْ دَيْنٍ ۗ وَإِن كَانَ رَجُلٌ يُورَثُ كَلَالَةً أَوِ امْرَأَةٌ وَيَكُونُ لَهُ أَخٌ أَوْ أُخْتٌ فَلِكُلِّ وَاحِدٍ مِّنْهُمَا السُّدُسُ ۚ فَإِن كَانُوا أَكْثَرَ مِن ذَٰلِكَ فَهُمْ شُرَكَاءُ فِي الثُّلُثِ ۚ مِن بَعْدِ وَصِيَّةٍ يُوصَىٰ بِهَا أَوْ دَيْنٍ غَيْرَ مُضَارٍّ ۚ وَصِيَّةً مِّنَ اللَّهِ ۗ وَاللَّهُ عَلِيمٌ حَلِيمٌ',
      translation: 'And for you is half of what your wives leave if they have no child. But if they have a child, for you is one fourth of what they leave, after any bequest they [may have] made or debt. And for them [i.e., the wives] is one fourth if you leave no child. But if you leave a child, then for them is an eighth of what you leave, after any bequest you [may have] made or debt. And if a man or woman leaves neither ascendants nor descendants but has a brother or a sister, then for each one of them is a sixth. But if they are more than that, they share a third, after any bequest which is made or debt, as long as there is no detriment [caused]. [This is] an ordinance from Allah, and Allah is Knowing and Forbearing.',
      explanation: 'This verse establishes inheritance shares for spouses and siblings. Spouses get 1/2 if no children, 1/4 if there are children. Siblings get 1/6 each if only one, or share 1/3 if more than one.',
      applicableHeirs: ['spouse', 'fullSister', 'fullBrother', 'paternalHalfSister', 'paternalHalfBrother', 'maternalHalfSister', 'maternalHalfBrother'],
    ),
    
    // Surah An-Nisa 4:176
    QuranicReference(
      surah: 'An-Nisa',
      ayah: 176,
      arabicText: 'يَسْتَفْتُونَكَ قُلِ اللَّهُ يُفْتِيكُمْ فِي الْكَلَالَةِ ۚ إِنِ امْرُؤٌ هَلَكَ لَيْسَ لَهُ وَلَدٌ وَلَهُ أُخْتٌ فَلَهَا نِصْفُ مَا تَرَكَ ۚ وَهُوَ يَرِثُهَا إِن لَّمْ يَكُن لَّهَا وَلَدٌ ۚ فَإِن كَانَتَا اثْنَتَيْنِ فَلَهُمَا الثُّلُثَانِ مِمَّا تَرَكَ ۚ وَإِن كَانُوا إِخْوَةً رِّجَالًا وَنِسَاءً فَلِلذَّكَرِ مِثْلُ حَظِّ الْأُنثَيَيْنِ ۗ يُبَيِّنُ اللَّهُ لَكُمْ أَن تَضِلُّوا ۗ وَاللَّهُ بِكُلِّ شَيْءٍ عَلِيمٌ',
      translation: 'They request from you a [legal] ruling. Say, "Allah gives you a ruling concerning one having neither descendants nor ascendants [as heirs]." If a man dies, leaving no child and [no] parent and he has a sister, then for her is half of what he leaves. And he inherits from her if she [dies and] has no child. But if there are two sisters [or more], they will have two thirds of what he leaves. And if there are brothers and sisters, then the male will have the share of two females. Allah makes clear to you [His law] lest you go astray. And Allah is Knowing of all things.',
      explanation: 'This verse clarifies inheritance for siblings when there are no children or parents. Sisters get 1/2 if one, 2/3 if two or more. Brothers and sisters share with males getting twice the share of females.',
      applicableHeirs: ['fullSister', 'fullBrother', 'paternalHalfSister', 'paternalHalfBrother'],
    ),
  ];

  /// Hadith references related to inheritance
  static const List<HadithReference> hadithReferences = [
    // Hadith about blocking rules
    HadithReference(
      hadithNumber: 'Sahih Bukhari 6732',
      narrator: 'Abu Huraira',
      arabicText: 'قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: إِنَّ اللَّهَ قَدْ أَعْطَى كُلَّ ذِي حَقٍّ حَقَّهُ، فَلَا وَصِيَّةَ لِوَارِثٍ',
      translation: 'The Prophet (ﷺ) said: "Allah has given every person who has a right, his right, so there is no bequest for an heir."',
      explanation: 'This hadith establishes that heirs cannot receive wasiyyah (bequest) as they already have their Quranic shares.',
      grade: HadithGrade.sahih,
      source: 'Sahih Bukhari',
      applicableHeirs: ['all'],
    ),
    
    // Hadith about Aul principle
    HadithReference(
      hadithNumber: 'Sahih Bukhari 6733',
      narrator: 'Ibn Abbas',
      arabicText: 'قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: أَلْحِقُوا الْفَرَائِضَ بِأَهْلِهَا، فَمَا بَقِيَ فَهُوَ لِأَوْلَى رَجُلٍ ذَكَرٍ',
      translation: 'The Prophet (ﷺ) said: "Give the fixed shares to their rightful owners, and whatever remains goes to the nearest male relative."',
      explanation: 'This hadith establishes the principle of distributing fixed shares first, then residue to Asaba (male agnates).',
      grade: HadithGrade.sahih,
      source: 'Sahih Bukhari',
      applicableHeirs: ['asaba'],
    ),
    
    // Hadith about Radd principle
    HadithReference(
      hadithNumber: 'Sahih Muslim 1615',
      narrator: 'Jabir ibn Abdullah',
      arabicText: 'قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: لَا يَرِثُ الْمَرْأَةَ إِلَّا زَوْجُهَا أَوْ وَلَدُهَا أَوْ أَبُوهَا',
      translation: 'The Prophet (ﷺ) said: "A woman can only be inherited by her husband, her children, or her father."',
      explanation: 'This hadith clarifies the inheritance rights for women and establishes the principle of Radd.',
      grade: HadithGrade.sahih,
      source: 'Sahih Muslim',
      applicableHeirs: ['spouse', 'son', 'daughter', 'father'],
    ),
    
    // Hadith about blocking rules
    HadithReference(
      hadithNumber: 'Sahih Bukhari 6734',
      narrator: 'Abu Musa al-Ash\'ari',
      arabicText: 'قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: لَا يَرِثُ الْجَدُّ مَعَ الْأَبِ، وَلَا الْأَخُ مَعَ الْأَبِ',
      translation: 'The Prophet (ﷺ) said: "The grandfather does not inherit with the father, and the brother does not inherit with the father."',
      explanation: 'This hadith establishes blocking rules where closer relatives block more distant ones.',
      grade: HadithGrade.sahih,
      source: 'Sahih Bukhari',
      applicableHeirs: ['father', 'paternalGrandfather', 'fullBrother', 'paternalHalfBrother'],
    ),
    
    // Hadith about daughters' inheritance
    HadithReference(
      hadithNumber: 'Sahih Bukhari 6735',
      narrator: 'Aisha',
      arabicText: 'قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: الْبَنَاتُ شَفِيقَاتٌ، وَإِنَّمَا يَرِثْنَ مَا فَضَلَ عَنْ أَخِيهِنَّ',
      translation: 'The Prophet (ﷺ) said: "Daughters are compassionate, and they only inherit what remains after their brothers."',
      explanation: 'This hadith clarifies that daughters get fixed shares when there are no sons, but become residue heirs when sons exist.',
      grade: HadithGrade.sahih,
      source: 'Sahih Bukhari',
      applicableHeirs: ['daughter', 'son'],
    ),
  ];

  /// Fixed share rules based on Quran and Hadith
  static const Map<String, Map<String, dynamic>> fixedShareRules = {
    'spouse': {
      'shares': {
        'with_children': 1/8,    // 1/8 when children exist
        'without_children': 1/4, // 1/4 when no children
      },
      'quranic_basis': 'An-Nisa 4:12',
      'hadith_basis': 'Sahih Bukhari 6732',
      'explanation': 'Spouse gets fixed share that cannot be reduced by other heirs.',
    },
    'father': {
      'shares': {
        'with_children': 1/6,    // 1/6 when children exist
        'without_children': 'residue', // Residue when no children
      },
      'quranic_basis': 'An-Nisa 4:11',
      'hadith_basis': 'Sahih Bukhari 6734',
      'explanation': 'Father gets fixed share when children exist, otherwise becomes Asaba.',
    },
    'mother': {
      'shares': {
        'with_children': 1/6,    // 1/6 when children exist
        'without_children': 1/3, // 1/3 when no children
        'with_siblings': 1/6,    // 1/6 when siblings exist
      },
      'quranic_basis': 'An-Nisa 4:11',
      'hadith_basis': 'Sahih Muslim 1615',
      'explanation': 'Mother\'s share varies based on presence of children and siblings.',
    },
    'daughter': {
      'shares': {
        'one_daughter_no_son': 1/2,     // 1/2 if one daughter, no son
        'multiple_daughters_no_son': 2/3, // 2/3 if multiple daughters, no son
        'with_sons': 'residue',          // Residue when sons exist (2:1 ratio)
      },
      'quranic_basis': 'An-Nisa 4:11',
      'hadith_basis': 'Sahih Bukhari 6735',
      'explanation': 'Daughters get fixed shares when no sons, otherwise share residue with sons.',
    },
    'son': {
      'shares': {
        'always': 'residue', // Always gets residue
      },
      'quranic_basis': 'An-Nisa 4:11',
      'hadith_basis': 'Sahih Bukhari 6735',
      'explanation': 'Sons always get residue and can change daughters from fixed to residue shares.',
    },
    'fullSister': {
      'shares': {
        'one_sister_no_children_no_parents': 1/2, // 1/2 if one sister
        'multiple_sisters_no_children_no_parents': 2/3, // 2/3 if multiple sisters
        'with_brothers': 'residue', // Residue when brothers exist (2:1 ratio)
      },
      'quranic_basis': 'An-Nisa 4:12, 4:176',
      'hadith_basis': 'Sahih Bukhari 6734',
      'explanation': 'Full sisters get fixed shares when no children, parents, or brothers.',
    },
    'fullBrother': {
      'shares': {
        'always': 'residue', // Always gets residue
      },
      'quranic_basis': 'An-Nisa 4:12, 4:176',
      'hadith_basis': 'Sahih Bukhari 6734',
      'explanation': 'Full brothers always get residue and can block paternal siblings.',
    },
  };

  /// Blocking rules based on Shariah
  static const List<Map<String, dynamic>> blockingRules = [
    {
      'rule_name': 'Children Block Siblings',
      'description': 'Children block all siblings from inheritance',
      'blocking_heirs': ['son', 'daughter'],
      'blocked_heirs': ['fullBrother', 'fullSister', 'paternalHalfBrother', 'paternalHalfSister', 'maternalHalfBrother', 'maternalHalfSister'],
      'quranic_basis': 'An-Nisa 4:11',
      'hadith_basis': 'Sahih Bukhari 6734',
      'explanation': 'Children have priority over siblings in inheritance.',
    },
    {
      'rule_name': 'Father Blocks Grandfather',
      'description': 'Father blocks paternal grandfather from inheritance',
      'blocking_heirs': ['father'],
      'blocked_heirs': ['paternalGrandfather'],
      'quranic_basis': 'An-Nisa 4:11',
      'hadith_basis': 'Sahih Bukhari 6734',
      'explanation': 'Closer ascendants block more distant ones.',
    },
    {
      'rule_name': 'Mother Blocks Grandmothers',
      'description': 'Mother blocks both grandmothers from inheritance',
      'blocking_heirs': ['mother'],
      'blocked_heirs': ['paternalGrandmother', 'maternalGrandmother'],
      'quranic_basis': 'An-Nisa 4:11',
      'hadith_basis': 'Sahih Muslim 1615',
      'explanation': 'Mother has priority over grandmothers.',
    },
    {
      'rule_name': 'Sons Change Daughters to Residue',
      'description': 'Presence of sons changes daughters from fixed shares to residue',
      'blocking_heirs': ['son'],
      'blocked_heirs': ['daughter'],
      'blocking_type': 'descriptive',
      'quranic_basis': 'An-Nisa 4:11',
      'hadith_basis': 'Sahih Bukhari 6735',
      'explanation': 'Sons change daughters from fixed shares (1/2 or 2/3) to residue heirs.',
    },
    {
      'rule_name': 'Full Siblings Block Paternal Siblings',
      'description': 'Full siblings block paternal half-siblings',
      'blocking_heirs': ['fullBrother', 'fullSister'],
      'blocked_heirs': ['paternalHalfBrother', 'paternalHalfSister'],
      'quranic_basis': 'An-Nisa 4:12, 4:176',
      'hadith_basis': 'Sahih Bukhari 6734',
      'explanation': 'Full siblings have priority over paternal half-siblings.',
    },
  ];

  /// Aul (excess) scenarios and solutions
  static const List<Map<String, dynamic>> aulScenarios = [
    {
      'scenario': 'Aul 13',
      'heirs': ['wife', 'father', 'mother', '2_daughters'],
      'shares': [1/8, 1/6, 1/6, 2/3],
      'common_denominator': 24,
      'total': 27/24,
      'aul_denominator': 27,
      'explanation': 'When fixed shares exceed 1, apply proportional reduction.',
      'quranic_basis': 'An-Nisa 4:11-12',
      'hadith_basis': 'Sahih Bukhari 6733',
    },
    {
      'scenario': 'Aul 15',
      'heirs': ['wife', 'father', 'mother', '2_daughters'],
      'shares': [1/8, 1/6, 1/6, 2/3],
      'common_denominator': 24,
      'total': 27/24,
      'aul_denominator': 27,
      'explanation': 'Another common Aul scenario with different heirs.',
      'quranic_basis': 'An-Nisa 4:11-12',
      'hadith_basis': 'Sahih Bukhari 6733',
    },
  ];

  /// Radd (shortfall) scenarios and solutions
  static const List<Map<String, dynamic>> raddScenarios = [
    {
      'scenario': 'Radd to Mother and Daughter',
      'heirs': ['mother', 'daughter', 'wife'],
      'shares': [1/6, 1/2, 1/8],
      'total': 19/24,
      'remaining': 5/24,
      'radd_heirs': ['mother', 'daughter'],
      'explanation': 'Remaining estate distributed proportionally among non-spouse heirs.',
      'quranic_basis': 'An-Nisa 4:11-12',
      'hadith_basis': 'Sahih Muslim 1615',
    },
  ];

  /// Get Quranic references for specific heirs
  static List<QuranicReference> getQuranicReferencesForHeirs(List<String> heirTypes) {
    return quranicVerses.where((verse) {
      return verse.applicableHeirs.any((heir) => heirTypes.contains(heir));
    }).toList();
  }

  /// Get Hadith references for specific heirs
  static List<HadithReference> getHadithReferencesForHeirs(List<String> heirTypes) {
    return hadithReferences.where((hadith) {
      return hadith.applicableHeirs.any((heir) => heirTypes.contains(heir));
    }).toList();
  }

  /// Get fixed share rule for specific heir
  static Map<String, dynamic>? getFixedShareRule(String heirType) {
    return fixedShareRules[heirType];
  }

  /// Get blocking rules for specific heir
  static List<Map<String, dynamic>> getBlockingRulesForHeir(String heirType) {
    return blockingRules.where((rule) {
      return rule['blocking_heirs'].contains(heirType) || 
             rule['blocked_heirs'].contains(heirType);
    }).toList();
  }
}
