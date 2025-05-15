import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/presentation/hirer_section/job_managment_screen/job_managment_screen.dart';

import '../common/floating_action_button.dart';
import '../job_catogory.dart';
import '../settings_screen/settings_page.dart';
import '../widgets/category_chips.dart';
import '../widgets/worker_type_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../jobs_posted/job_detail_screen.dart';
import '../jobs/posted_jobs.dart';


//! S E A R C H  B A R  W I D G E T
class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Theme.of(context) to get app theme colors if available
    final appThemeBackgroundGrey = Colors.grey[200]; // Fallback color

    return GestureDetector(
      onTap: () => _showJobCategoriesSearchSheet(context),
      child: Container(
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
      ),
    );
  }

  // Show the job categories search sheet
  void _showJobCategoriesSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Get the available screen height minus the status bar height
        final statusBarHeight = MediaQuery.of(context).padding.top;
        final screenHeight = MediaQuery.of(context).size.height - statusBarHeight;
        
        // Use almost full screen height (95%)
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: JobCategoriesSearchSheet(),
        );
      },
    );
  }
}

//! J O B  C A T E G O R I E S  S E A R C H  S H E E T
class JobCategoriesSearchSheet extends StatefulWidget {
  const JobCategoriesSearchSheet({Key? key}) : super(key: key);

  @override
  State<JobCategoriesSearchSheet> createState() => _JobCategoriesSearchSheetState();
}

class _JobCategoriesSearchSheetState extends State<JobCategoriesSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredJobs = [];
  final List<Map<String, dynamic>> _allJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load all job categories
  void _loadAllJobs() {
    setState(() {
      _isLoading = true;
    });

    // Combine general and industry jobs
    _allJobs.addAll([
      // General Jobs
      {'name': 'Cleaner', 'category': 'General', 'icon': Icons.cleaning_services},
      {'name': 'Helper', 'category': 'General', 'icon': Icons.support},
      {'name': 'Delivery Boy', 'category': 'General', 'icon': Icons.delivery_dining},
      {'name': 'Receptionist', 'category': 'General', 'icon': Icons.record_voice_over},
      {'name': 'Security Guard', 'category': 'General', 'icon': Icons.security},
      {'name': 'Driver', 'category': 'General', 'icon': Icons.drive_eta},
      {'name': 'Kitchen Helper', 'category': 'General', 'icon': Icons.restaurant},
      {'name': 'Office Boy', 'category': 'General', 'icon': Icons.business_center},
      
      // Restaurants & Food Services
      {'name': 'Waiter', 'category': 'Restaurants & Food Services', 'icon': Icons.restaurant},
      {'name': 'Cook', 'category': 'Restaurants & Food Services', 'icon': Icons.restaurant_menu},
      {'name': 'Dishwasher', 'category': 'Restaurants & Food Services', 'icon': Icons.cleaning_services},
      
      // Hospitality & Hotels
      {'name': 'Housekeeper', 'category': 'Hospitality & Hotels', 'icon': Icons.hotel},
      {'name': 'Room Boy', 'category': 'Hospitality & Hotels', 'icon': Icons.bed},
      {'name': 'Bellboy', 'category': 'Hospitality & Hotels', 'icon': Icons.luggage},
      
      // Construction
      {'name': 'Mason', 'category': 'Construction & Civil Work', 'icon': Icons.construction},
      {'name': 'Electrician', 'category': 'Construction & Civil Work', 'icon': Icons.electrical_services},
      {'name': 'Plumber', 'category': 'Construction & Civil Work', 'icon': Icons.plumbing},
      {'name': 'Painter', 'category': 'Construction & Civil Work', 'icon': Icons.format_paint},
      
      // Home Services
      {'name': 'Maid', 'category': 'Home Services', 'icon': Icons.home},
      {'name': 'Cook', 'category': 'Home Services', 'icon': Icons.dinner_dining},
      {'name': 'Gardener', 'category': 'Home Services', 'icon': Icons.yard},
      {'name': 'Babysitter', 'category': 'Home Services', 'icon': Icons.child_care},
    ]);

    _filteredJobs = List.from(_allJobs);
    
    setState(() {
      _isLoading = false;
    });
  }

  // Filter jobs based on search query
  void _filterJobs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredJobs = List.from(_allJobs);
      });
      return;
    }

    setState(() {
      _filteredJobs = _allJobs.where((job) {
        final nameMatch = job['name'].toString().toLowerCase().contains(query.toLowerCase());
        final categoryMatch = job['category'].toString().toLowerCase().contains(query.toLowerCase());
        return nameMatch || categoryMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard height to adjust for it
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      // No fixed height - will be determined by FractionallySizedBox
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Padding(
        // Add bottom padding when keyboard is visible
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: Column(
          children: [
            // Handle and title
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF0011C9).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
              child: Row(
                children: [
                  Text(
                    'Search Jobs',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Search input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search job categories...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterJobs('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onChanged: _filterJobs,
              ),
            ),
            
            // Job categories list - Now in Expanded to take remaining height
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredJobs.isEmpty
                      ? Center(
                          child: Text(
                            'No jobs found',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.all(16.w),
                          children: [
                            // Group by category
                            ..._getCategorizedJobs().entries.map((entry) {
                              return _buildCategorySection(
                                title: entry.key,
                                jobs: entry.value,
                              );
                            }).toList(),
                            // Add extra padding at the bottom when keyboard is visible
                            SizedBox(height: keyboardHeight > 0 ? 20.h : 0),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Group jobs by category
  Map<String, List<Map<String, dynamic>>> _getCategorizedJobs() {
    final Map<String, List<Map<String, dynamic>>> categorizedJobs = {};
    
    for (var job in _filteredJobs) {
      final category = job['category'] as String;
      
      if (!categorizedJobs.containsKey(category)) {
        categorizedJobs[category] = [];
      }
      
      categorizedJobs[category]!.add(job);
    }
    
    return categorizedJobs;
  }

  // Build a category section
  Widget _buildCategorySection({
    required String title,
    required List<Map<String, dynamic>> jobs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0011C9),
            ),
          ),
        ),
        ...jobs.map((job) => _buildJobItem(job)).toList(),
        SizedBox(height: 16.h),
      ],
    );
  }

  // Build a job item
  Widget _buildJobItem(Map<String, dynamic> job) {
    return InkWell(
      onTap: () {
        // Close the search sheet
        Navigator.pop(context);
        
        // Show worker type bottom sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => WorkerTypeBottomSheet(
            jobCategory: job['name'],
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                job['icon'] ?? Icons.work_outline,
                color: const Color(0xFF0011C9),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                job['name'],
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

//! C A T E G O R I E S  H E A D E R
class CategoriesHeader extends StatelessWidget {
  const CategoriesHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Popular Categories',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            // Show job categories search sheet when "See All" is tapped
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const JobManagementScreen(),
            );
          },
          child: Text(
            'See All',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0011C9),
            ),
          ),
        ),
      ],
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
                builder: (context) =>  SettingsScreen(),
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
                        child: SizedBox(height: 70.h), // Space for search bar
                      ),
                      SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            //! I N D U S T R Y  T I T L E
                            Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Text(
                                'Jobs for $_selectedIndustry',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            //! J O B  C A T E G O R I E S
                            _buildJobCategoriesSection(),

                            SizedBox(height: 24.h),

                            //! L A T E S T  J O B S  S E C T I O N
                            // Replace CategoryChips with LatestJobsSection
                            const LatestJobsSection(),

                            SizedBox(height: 72.h), // Space for FAB
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
              SizedBox(height: 16.h),
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
              borderRadius: BorderRadius.circular(12.r),
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
          SizedBox(height: 8.h),
          // Text label with fixed height & ellipsis
          SizedBox(
            width: cardSize,
            height: 32.h, // Fixed height for title
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 12.sp,
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
//! L A T E S T  J O B S  S E C T I O N
class LatestJobsSection extends StatefulWidget {
  const LatestJobsSection({Key? key}) : super(key: key);

  @override
  State<LatestJobsSection> createState() => _LatestJobsSectionState();
}

class _LatestJobsSectionState extends State<LatestJobsSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _latestJobs = [];
  
  @override
  void initState() {
    super.initState();
    _loadLatestJobs();
  }
  
  // Load latest jobs posted by the hirer
  Future<void> _loadLatestJobs() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }
      
      // Query latest 3 jobs by the current user
      final snapshot = await _firestore
          .collection('jobs')
          .where('hirerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();
      
      final List<Map<String, dynamic>> loadedJobs = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['jobId'] = doc.id; // Add document ID to the job data
        
        // Convert Firestore timestamps to DateTime
        if (data['createdAt'] != null) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
        }
        
        if (data['date'] != null) {
          data['date'] = (data['date'] as Timestamp).toDate();
        }
        
        loadedJobs.add(data);
      }
      
      setState(() {
        _latestJobs = loadedJobs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading latest jobs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with title and "See All" button
        _buildSectionHeader(),
        SizedBox(height: 12.h),
        
        // Jobs list or loading indicator
        _isLoading 
            ? _buildLoadingIndicator()
            : _latestJobs.isEmpty
                ? _buildEmptyState()
                : _buildJobsList(),
      ],
    );
  }
  
  // Build section header with title and "See All" button
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your Latest Jobs',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => const JobManagementScreen(),
              ),
            );
          },
          child: Text(
            'See All',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0011C9),
            ),
          ),
        ),
      ],
    );
  }
  
  // Build loading indicator
  Widget _buildLoadingIndicator() {
    return Container(
      height: 150.h,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        color: Color(0xFF0011C9),
      ),
    );
  }
  
  // Build empty state when no jobs are available
  Widget _buildEmptyState() {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off_outlined,
            size: 36.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 8.h),
          Text(
            'No jobs posted yet',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const JobDetailsScreen(
                    jobCategory: '',
                    jobType: 'part-time',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 16),
            label: Text(
              'Create Job',
              style: GoogleFonts.poppins(fontSize: 12.sp),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0011C9),
              backgroundColor: const Color(0xFF0011C9).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the list of latest jobs
  Widget _buildJobsList() {
    return Column(
      children: _latestJobs.map((job) => _buildJobCard(job)).toList(),
    );
  }
  
  // Build a job card
  Widget _buildJobCard(Map<String, dynamic> job) {
    final bool isFullTime = job['jobType'] == 'full-time';
    final String jobCategory = job['jobCategory'] ?? 'Unknown';
    final DateTime? date = job['date'];
    final bool hasDescription = job['description'] != null && job['description'].toString().isNotEmpty;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to edit job screen when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsScreen(
                jobCategory: job['jobCategory'] ?? '',
                jobType: job['jobType'] ?? 'part-time',
                existingJob: job,
                isEditing: true,
                jobId: job['jobId'],
              ),
            ),
          ).then((_) {
            // Reload jobs when returning
            _loadLatestJobs();
          });
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Type and Category
              Row(
                children: [
                  // Job Type Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isFullTime
                          ? const Color(0xFF0011C9).withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      isFullTime ? 'FULL TIME' : 'PART TIME',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: isFullTime
                            ? const Color(0xFF0011C9)
                            : Colors.orange.shade800,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  
                  // Job Category
                  Expanded(
                    child: Text(
                      jobCategory,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // Budget/Salary
              if (isFullTime && job.containsKey('salaryRange'))
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 16.sp,
                        color: Colors.green.shade700,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '₹${job['salaryRange']['min']} - ₹${job['salaryRange']['max']}/month',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                )
              else if (job.containsKey('budget'))
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 16.sp,
                        color: Colors.green.shade700,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '₹${job['budget']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Date if available
              if (date != null)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        DateFormat('MMM dd, yyyy').format(date),
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Description if available (truncated)
              if (hasDescription)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    job['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
              // Status if available
              if (job['status'] != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job['status'].toString()).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      job['status'].toString().toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(job['status'].toString()),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Get color based on job status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade700;
      case 'closed':
        return Colors.red.shade700;
      case 'pending':
        return Colors.orange.shade700;
      default:
        return Colors.blue.shade700;
    }
  }
}