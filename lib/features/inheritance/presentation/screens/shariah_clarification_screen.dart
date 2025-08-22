import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import '../../domain/entities/heir.dart';
// import '../../data/sources/shariah_references.dart';

/// Hadith authenticity grades
enum HadithGrade {
  sahih,
  hasan,
  daif,
  mawdu,
}

/// Screen explaining Islamic inheritance principles with Quran and Hadith references
class ShariahClarificationScreen extends StatefulWidget {
  const ShariahClarificationScreen({super.key});

  @override
  State<ShariahClarificationScreen> createState() =>
      _ShariahClarificationScreenState();
}

class _ShariahClarificationScreenState extends State<ShariahClarificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Islamic Inheritance Principles',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareClarification(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.green[700],
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Quranic Verses'),
                Tab(text: 'Hadith'),
                Tab(text: 'Principles'),
                Tab(text: 'Examples'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuranicVersesTab(),
                _buildHadithTab(),
                _buildPrinciplesTab(),
                _buildExamplesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranicVersesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          'Quranic Foundation',
          'The inheritance laws are directly derived from the Quran',
          Icons.book,
        ),
        const SizedBox(height: 16),

        // Main inheritance verse
        _buildQuranicVerseCard(
          'Surah An-Nisa 4:11',
          'يُوصِيكُمُ اللَّهُ فِي أَوْلَادِكُمْ ۖ لِلذَّكَرِ مِثْلُ حَظِّ الْأُنثَيَيْنِ ۚ فَإِن كُنَّ نِسَاءً فَوْقَ اثْنَتَيْنِ فَلَهُنَّ ثُلُثَا مَا تَرَكَ ۖ وَإِن كَانَتْ وَاحِدَةً فَلَهَا النِّصْفُ ۚ وَلِأَبَوَيْهِ لِكُلِّ وَاحِدٍ مِّنْهُمَا السُّدُسُ مِمَّا تَرَكَ إِن كَانَ لَهُ وَلَدٌ ۚ فَإِن لَّمْ يَكُن لَّهُ وَلَدٌ وَوَرِثَهُ أَبَوَاهُ فَلِأُمِّهِ الثُّلُثُ ۚ فَإِن كَانَ لَهُ إِخْوَةٌ فَلِأُمِّهِ السُّدُسُ ۚ مِن بَعْدِ وَصِيَّةٍ يُوصَىٰ بِهَا أَوْ دَيْنٍ ۗ آبَاؤُكُمْ وَأَبْنَاؤُكُمْ لَا تَدْرُونَ أَيُّهُمْ أَقْرَبُ لَكُمْ نَفْعًا ۚ فَرِيضَةً مِّنَ اللَّهِ ۗ إِنَّ اللَّهَ كَانَ عَلِيمًا حَكِيمًا',
          'Allah commands you regarding your children: for the male, what is equal to the share of two females. But if there are [only] daughters, two or more, for them is two thirds of one\'s estate. And if there is only one, for her is half. And for one\'s parents, to each one of them is a sixth of his estate if he left children. But if he had no children and the parents [alone] inherit from him, then for his mother is one third. And if he had brothers [or sisters], for his mother is a sixth, after any bequest he [may have] made or debt.',
          'This verse establishes the basic inheritance shares for children and parents. Sons get twice the share of daughters. If there are only daughters, they get 2/3 collectively. If only one daughter, she gets 1/2. Parents get 1/6 each if there are children, but if no children, mother gets 1/3 and father gets the remainder.',
          ['son', 'daughter', 'father', 'mother'],
        ),

        const SizedBox(height: 16),

        // Spouse inheritance verse
        _buildQuranicVerseCard(
          'Surah An-Nisa 4:12',
          'وَلَكُمْ نِصْفُ مَا تَرَكَ أَزْوَاجُكُمْ إِن لَّمْ يَكُن لَّهُنَّ وَلَدٌ ۚ فَإِن كَانَ لَهُنَّ وَلَدٌ فَلَكُمُ الرُّبُعُ مِمَّا تَرَكْنَ ۚ مِن بَعْدِ وَصِيَّةٍ يُوصِينَ بِهَا أَوْ دَيْنٍ ۗ وَلَهُنَّ الرُّبُعُ مِمَّا تَرَكْتُمْ إِن لَّمْ يَكُن لَّكُمْ وَلَدٌ ۚ فَإِن كَانَ لَكُمْ وَلَدٌ فَلَهُنَّ الثُّمُنُ مِمَّا تَرَكْتُم ۚ مِّن بَعْدِ وَصِيَّةٍ تُوصُونَ بِهَا أَوْ دَيْنٍ ۗ وَإِن كَانَ رَجُلٌ يُورَثُ كَلَالَةً أَوِ امْرَأَةٌ وَيَكُونُ لَهُ أَخٌ أَوْ أُخْتٌ فَلِكُلِّ وَاحِدٍ مِّنْهُمَا السُّدُسُ ۚ فَإِن كَانُوا أَكْثَرَ مِن ذَٰلِكَ فَهُمْ شُرَكَاءُ فِي الثُّلُثِ ۚ مِن بَعْدِ وَصِيَّةٍ يُوصَىٰ بِهَا أَوْ دَيْنٍ غَيْرَ مُضَارٍّ ۚ وَصِيَّةً مِّنَ اللَّهِ ۗ وَاللَّهُ عَلِيمٌ حَلِيمٌ',
          'And for you is half of what your wives leave if they have no child. But if they have a child, for you is one fourth of what they leave, after any bequest they [may have] made or debt. And for them [i.e., the wives] is one fourth if you leave no child. But if you leave a child, then for them is an eighth of what you leave, after any bequest you [may have] made or debt.',
          'This verse establishes inheritance shares for spouses and siblings. Spouses get 1/2 if no children, 1/4 if there are children. Siblings get 1/6 each if only one, or share 1/3 if more than one.',
          [
            'spouse',
            'fullSister',
            'fullBrother',
            'paternalHalfSister',
            'paternalHalfBrother',
            'maternalHalfSister',
            'maternalHalfBrother'
          ],
        ),

        const SizedBox(height: 16),

        // Sibling inheritance verse
        _buildQuranicVerseCard(
          'Surah An-Nisa 4:176',
          'يَسْتَفْتُونَكَ قُلِ اللَّهُ يُفْتِيكُمْ فِي الْكَلَالَةِ ۚ إِنِ امْرُؤٌ هَلَكَ لَيْسَ لَهُ وَلَدٌ وَلَهُ أُخْتٌ فَلَهَا نِصْفُ مَا تَرَكَ ۚ وَهُوَ يَرِثُهَا إِن لَّمْ يَكُن لَّهَا وَلَدٌ ۚ فَإِن كَانَتَا اثْنَتَيْنِ فَلَهُمَا الثُّلُثَانِ مِمَّا تَرَكَ ۚ وَإِن كَانُوا إِخْوَةً رِّجَالًا وَنِسَاءً فَلِلذَّكَرِ مِثْلُ حَظِّ الْأُنثَيَيْنِ ۗ يُبَيِّنُ اللَّهُ لَكُمْ أَن تَضِلُّوا ۗ وَاللَّهُ بِكُلِّ شَيْءٍ عَلِيمٌ',
          'They request from you a [legal] ruling. Say, "Allah gives you a ruling concerning one having neither descendants nor ascendants [as heirs]." If a man dies, leaving no child and [no] parent and he has a sister, then for her is half of what he leaves. And he inherits from her if she [dies and] has no child. But if there are two sisters [or more], they will have two thirds of what he leaves. And if there are brothers and sisters, then the male will have the share of two females.',
          'This verse clarifies inheritance for siblings when there are no children or parents. Sisters get 1/2 if one, 2/3 if two or more. Brothers and sisters share with males getting twice the share of females.',
          [
            'fullSister',
            'fullBrother',
            'paternalHalfSister',
            'paternalHalfBrother'
          ],
        ),
      ],
    );
  }

  Widget _buildHadithTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          'Prophetic Guidance',
          'Hadith that clarify and explain inheritance principles',
          Icons.lightbulb,
        ),
        const SizedBox(height: 16),
        _buildHadithCard(
          'Sahih Bukhari 6732',
          'Abu Huraira',
          'قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: إِنَّ اللَّهَ قَدْ أَعْطَى كُلَّ ذِي حَقٍّ حَقَّهُ، فَلَا وَصِيَّةَ لِوَارِثٍ',
          'The Prophet (ﷺ) said: "Allah has given every person who has a right, his right, so there is no bequest for an heir."',
          'This hadith establishes that heirs cannot receive wasiyyah (bequest) as they already have their Quranic shares.',
          HadithGrade.sahih,
          'Sahih Bukhari',
        ),
        const SizedBox(height: 16),
        _buildHadithCard(
          'Sahih Bukhari 6733',
          'Ibn Abbas',
          'قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: أَلْحِقُوا الْفَرَائِضَ بِأَهْلِهَا، فَمَا بَقِيَ فَهُوَ لِأَوْلَى رَجُلٍ ذَكَرٍ',
          'The Prophet (ﷺ) said: "Give the fixed shares to their rightful owners, and whatever remains goes to the nearest male relative."',
          'This hadith establishes the principle of distributing fixed shares first, then residue to Asaba (male agnates).',
          HadithGrade.sahih,
          'Sahih Bukhari',
        ),
        const SizedBox(height: 16),
        _buildHadithCard(
          'Sahih Bukhari 6734',
          'Abu Musa al-Ash\'ari',
          'قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: لَا يَرِثُ الْجَدُّ مَعَ الْأَبِ، وَلَا الْأَخُ مَعَ الْأَبِ',
          'The Prophet (ﷺ) said: "The grandfather does not inherit with the father, and the brother does not inherit with the father."',
          'This hadith establishes blocking rules where closer relatives block more distant ones.',
          HadithGrade.sahih,
          'Sahih Bukhari',
        ),
        const SizedBox(height: 16),
        _buildHadithCard(
          'Sahih Bukhari 6735',
          'Aisha',
          'قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: الْبَنَاتُ شَفِيقَاتٌ، وَإِنَّمَا يَرِثْنَ مَا فَضَلَ عَنْ أَخِيهِنَّ',
          'The Prophet (ﷺ) said: "Daughters are compassionate, and they only inherit what remains after their brothers."',
          'This hadith clarifies that daughters get fixed shares when there are no sons, but become residue heirs when sons exist.',
          HadithGrade.sahih,
          'Sahih Bukhari',
        ),
      ],
    );
  }

  Widget _buildPrinciplesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          'Core Principles',
          'Fundamental principles of Islamic inheritance',
          Icons.rule,
        ),
        const SizedBox(height: 16),
        _buildPrincipleCard(
          'Fixed Shares (Zabiul Furuj)',
          'Quranic heirs with specific fractional shares',
          [
            'Spouse: 1/4 or 1/8',
            'Children: 1/2, 2/3, or residue',
            'Parents: 1/6 or 1/3',
            'Siblings: 1/2, 2/3, or 1/6',
          ],
          Icons.calculate,
        ),
        const SizedBox(height: 16),
        _buildPrincipleCard(
          'Residue Heirs (Asaba)',
          'Male agnates who receive remaining estate',
          [
            'Sons and their descendants',
            'Father and grandfather',
            'Brothers and their descendants',
            'Uncles and their descendants',
          ],
          Icons.male,
        ),
        const SizedBox(height: 16),
        _buildPrincipleCard(
          'Blocking Rules (Hijab)',
          'Closer relatives block more distant ones',
          [
            'Children block siblings',
            'Father blocks grandfather',
            'Mother blocks grandmothers',
            'Sons change daughters to residue',
          ],
          Icons.block,
        ),
        const SizedBox(height: 16),
        _buildPrincipleCard(
          'Aul (Excess)',
          'Proportional reduction when shares exceed 100%',
          [
            'Common denominators: 13, 15, 17, 19, 27',
            'All shares reduced proportionally',
            'Based on scholarly consensus',
            'Ensures fair distribution',
          ],
          Icons.trending_down,
        ),
        const SizedBox(height: 16),
        _buildPrincipleCard(
          'Radd (Shortfall)',
          'Proportional increase when shares less than 100%',
          [
            'Exclude spouse from radd',
            'Distribute among other heirs',
            'Maintain relative proportions',
            'Based on Hadith evidence',
          ],
          Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildExamplesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          'Practical Examples',
          'Real-world inheritance scenarios',
          Icons.calculate,
        ),
        const SizedBox(height: 16),
        _buildExampleCard(
          'Example 1: Nuclear Family',
          'Husband + Wife + 2 Sons + 1 Daughter',
          'Estate: \$300,000',
          [
            'Wife: \$37,500 (1/8)',
            'Sons: \$175,000 each (2/3 in 2:1 ratio)',
            'Daughter: \$87,500 (1/3)',
          ],
          'Total: \$300,000 ✓',
        ),
        const SizedBox(height: 16),
        _buildExampleCard(
          'Example 2: Aul Case',
          'Wife + Father + Mother + 2 Daughters',
          'Estate: \$240,000',
          [
            'Wife: \$30,000 (3/24 → 3/27)',
            'Father: \$40,000 (4/24 → 4/27)',
            'Mother: \$40,000 (4/24 → 4/27)',
            'Daughters: \$65,000 each (16/24 → 16/27)',
          ],
          'Aul 27 applied - Total: \$240,000 ✓',
        ),
        const SizedBox(height: 16),
        _buildExampleCard(
          'Example 3: Radd Case',
          'Mother + Daughter + Wife',
          'Estate: \$120,000',
          [
            'Mother: \$26,250 (1/6 + radd)',
            'Daughter: \$78,750 (1/2 + radd)',
            'Wife: \$15,000 (1/8 - no radd)',
          ],
          'Radd applied - Total: \$120,000 ✓',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranicVerseCard(
    String reference,
    String arabicText,
    String translation,
    String explanation,
    List<String> applicableHeirs,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reference,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(arabicText),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              arabicText,
              style: const TextStyle(
                fontSize: 18,
                height: 1.8,
                fontFamily: 'Amiri',
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Translation:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              translation,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Explanation:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              explanation,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: applicableHeirs
                  .map((heir) => Chip(
                        label: Text(heir),
                        backgroundColor: Colors.green[50],
                        labelStyle: TextStyle(color: Colors.green[700]),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithCard(
    String hadithNumber,
    String narrator,
    String arabicText,
    String translation,
    String explanation,
    HadithGrade grade,
    String source,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGradeColor(grade),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hadithNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    grade.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  source,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Narrated by: $narrator',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              arabicText,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
                fontFamily: 'Amiri',
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Translation:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              translation,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Explanation:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              explanation,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipleCard(
    String title,
    String description,
    List<String> points,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            ...points
                .map((point) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: TextStyle(color: Colors.green[700])),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    String title,
    String scenario,
    String estate,
    List<String> shares,
    String total,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scenario,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                estate,
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...shares
                .map((share) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        share,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ))
                .toList(),
            const SizedBox(height: 8),
            Text(
              total,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(HadithGrade grade) {
    switch (grade) {
      case HadithGrade.sahih:
        return Colors.green;
      case HadithGrade.hasan:
        return Colors.orange;
      case HadithGrade.daif:
        return Colors.red;
      case HadithGrade.mawdu:
        return Colors.grey;
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arabic text copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareClarification() {
    // Implementation for sharing clarification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
