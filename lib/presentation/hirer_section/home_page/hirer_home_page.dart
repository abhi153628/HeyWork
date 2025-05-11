import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hey_work/main.dart';
import '../common/floating_action_button.dart';
import '../job_catogory.dart';
import '../settings_screen/settings_page.dart';
import '../widgets/category_chips.dart';
import '../widgets/worker_type_bottom_sheet.dart';

//! S E A R C H  B A R  W I D G E T
class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Theme.of(context) to get app theme colors if available
    final appThemeBackgroundGrey = Colors.grey[200]; // Fallback color

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: appThemeBackgroundGrey,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            'Start a job search',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          const Icon(
            Icons.search,
            color: Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }
}

//! M A I N  H O M E  P A G E
class HirerHomePage extends StatefulWidget {
  const HirerHomePage({Key? key}) : super(key: key);

  @override
  State<HirerHomePage> createState() => _HirerHomePageState();
}

class _HirerHomePageState extends State<HirerHomePage> {
  String _selectedIndustry = '';
  List<JobCategoryInfo> _jobCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIndustry();
  }

  // Load the user's industry from Firestore
  Future<void> _loadUserIndustry() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
            .instance
            .collection('hirers')
            .doc(user.uid)
            .get();

        if (doc.exists &&
            doc.data() != null &&
            doc.data()!.containsKey('businessType')) {
          setState(() {
            _selectedIndustry = doc.data()!['businessType'];
            _jobCategories =
                JobCategoryManager.getFilledJobCategories(_selectedIndustry);
          });
        } else {
          // If no industry is set, use common categories
          setState(() {
            _selectedIndustry = 'General';
            _jobCategories = JobCategoryManager.commonJobCategories;
          });
        }
      }
    } catch (e) {
      print('Error loading user industry: $e');
      // Fallback to common categories
      setState(() {
        _selectedIndustry = 'General';
        _jobCategories = JobCategoryManager.commonJobCategories;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final searchBarPadding = screenWidth * 0.03;

    return Scaffold(
      //! A P P - B A R
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'heywork',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2020F0)),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ));
            },
          ),
        ],
      ),

      //! B O D Y
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) => false,
              child: Stack(
                children: [
                  //! S C R O L L A B L E  C O N T E N T
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(height: 70), // Space for search bar
                      ),
                      SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            //! I N D U S T R Y  T I T L E
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                'Jobs for $_selectedIndustry',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            //! J O B  C A T E G O R I E S
                            _buildJobCategoriesSection(),

                            const SizedBox(height: 24),

                            //! C A T E G O R Y  H E A D E R
                            const CategoriesHeader(),

                            const SizedBox(height: 16),

                            //! C A T E G O R Y  C H I P S
                            const CategoryChips(),

                            const SizedBox(height: 72), // Space for FAB
                          ]),
                        ),
                      ),
                    ],
                  ),

                  //! F L O A T I N G  S E A R C H  B A R
                  Positioned(
                    top: 0,
                    left: searchBarPadding,
                    right: searchBarPadding,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 0,
                      child: SearchBar(),
                    ),
                  ),
                ],
              ),
            ),

      //! F L O A T I N G  A C T I O N  B U T T O N
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const FloatingNewButton(),
    );
  }

  // Build the job categories section with dynamic categories based on industry
  Widget _buildJobCategoriesSection() {
    // Split job categories into rows of 4
    List<List<JobCategoryInfo>> categoryRows = [];
    for (var i = 0; i < _jobCategories.length; i += 4) {
      int end =
          (i + 4 <= _jobCategories.length) ? i + 4 : _jobCategories.length;
      categoryRows.add(_jobCategories.sublist(i, end));
    }

    return Column(
      children: [
        for (var row in categoryRows)
          Column(
            children: [
              _buildJobCategoryRow(row),
              const SizedBox(height: 16),
            ],
          ),
      ],
    );
  }

  // Build a row of job categories
  Widget _buildJobCategoryRow(List<JobCategoryInfo> categories) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth =
        screenWidth - (32 + (3 * 12)); // horizontal padding + gaps
    final itemWidth = availableWidth / 4; // 4 items per row

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((category) {
        return _buildJobCategoryCard(
          icon: category.icon,
          title: category.title,
          width: itemWidth,
        );
      }).toList(),
    );
  }

  // Build individual job category card
  Widget _buildJobCategoryCard({
    required IconData icon,
    required String title,
    required double width,
  }) {
    final cardSize = width * 0.9; // Slightly smaller than width allocation

    return GestureDetector(
      onTap: () {
        // Show the bottom sheet when a category is tapped
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => WorkerTypeBottomSheet(
            jobCategory: title.replaceAll('\n', ' '),
          ),
        );
      },
      child: Column(
        children: [
          // Card container
          Container(
            width: cardSize,
            height: cardSize, // Square container
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: cardSize * 0.4, // Icon size proportional to card
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Text label with fixed height & ellipsis
          SizedBox(
            width: cardSize,
            height: 32, // Fixed height for title
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2, // Tight line height for better layout
                  letterSpacing: -0.2),
            ),
          ),
        ],
      ),
    );
  }
}
