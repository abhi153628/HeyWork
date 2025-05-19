import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import 'package:hey_work/presentation/hirer_section/job_managment_screen/job_managment_screen.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import '../common/floating_action_button.dart';
import '../job_catogory.dart';
import '../settings_screen/settings_page.dart';
import '../widgets/category_chips.dart';
import '../widgets/worker_type_bottom_sheet.dart';
import 'package:intl/intl.dart';
import '../jobs_posted/job_detail_screen.dart';
import '../jobs/posted_jobs.dart';
import '../hirer_view_job_applications/hirer_view_job_applications.dart';

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
                    style: GoogleFonts.roboto(
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
                            style: GoogleFonts.roboto(
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
            style: GoogleFonts.roboto(
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
                style: GoogleFonts.roboto(
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
          style: GoogleFonts.roboto(
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
            style: GoogleFonts.roboto(
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
    final horizontalPadding = screenWidth * 0.03;
    final searchBarPadding = screenWidth * 0.03;

    return Scaffold(
      //! A P P - B A R
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Heywork',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 33,
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
                            SizedBox(height: 12.h),
                            //! J O B  C A T E G O R I E S
                            _buildJobCategoriesSection(),

                            //! My Jobs Section (Replaced LatestJobsSection)
                            const MyJobsSection(),

                            SizedBox(height: 12.h), // Space for FAB
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

//! M Y  J O B S  S E C T I O N - New component that replaces LatestJobsSection
class MyJobsSection extends StatefulWidget {
  const MyJobsSection({Key? key}) : super(key: key);

  @override
  State<MyJobsSection> createState() => _MyJobsSectionState();
}

class _MyJobsSectionState extends State<MyJobsSection> {
  final JobService _jobService = JobService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with title and "See All" button
        _buildSectionHeader(),
        SizedBox(height: 12.h),
        
        // Jobs list using the same UI as JobManagementScreen
        _buildJobList(),
      ],
    );
  }
  
  // Build section header with title and "See All" button
 Widget _buildSectionHeader() {
  return Padding(
    padding: EdgeInsets.only(bottom: 4.h,right: 280.h),
    child: Text(
      'My Jobs',
      style: GoogleFonts.roboto(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
  );
}
  
  //! J O B - L I S T - Same as in JobManagementScreen
 Widget _buildJobList() {
  return Column(
    children: [
      SizedBox(
        // Set a fixed height to limit the number of jobs shown
        height: 670.h, // Reduced height to accommodate the button
        child: StreamBuilder<QuerySnapshot>(
          stream: _getJobsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final jobDocs = snapshot.data?.docs ?? [];

            if (jobDocs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_off,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No jobs posted yet',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a job to see it here',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Convert docs to JobModel
            final jobs = jobDocs.map((doc) => JobModel.fromFirestore(doc)).toList();

            // Limit to latest 5 jobs (or fewer if less are available)
            final limitedJobs = jobs.length > 5 ? jobs.sublist(0, 5) : jobs;

            return ListView.builder(
              padding: EdgeInsets.zero, // Remove padding to match design
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              shrinkWrap: true,
              itemCount: limitedJobs.length,
              itemBuilder: (context, index) {
                final job = limitedJobs[index];
                return _buildJobCard(job);
              },
            );
          },
        ),
      ),
      
      // New "View All Jobs" button at the bottom
      Padding(
        padding: EdgeInsets.symmetric(vertical:6.h),
        child: Container(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const JobManagementScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
           backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                
              ),
              side: BorderSide(color: const Color(0xFF0011C9)),
            
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View All Jobs',
                  style: GoogleFonts.roboto(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0011C9),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward,
                  color: const Color(0xFF0011C9),
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}


  //! D A T A - F E T C H - Same as in JobManagementScreen
  Stream<QuerySnapshot> _getJobsStream() {
    var query = FirebaseFirestore.instance
      .collection('jobs')
      .where('hirerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .orderBy('createdAt', descending: true)
      .limit(5); // Limit to 5 most recent jobs

    return query.snapshots();
  }

  //! J O B - C A R D - Same as in JobManagementScreen
  Widget _buildJobCard(JobModel job) {
    final isFullTime = job.jobType.toLowerCase() == 'full-time';
    final jobTypeColor = isFullTime ? AppColors.green : Color(0xFF0000CC);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.black.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Posted date and job type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
               padding: const EdgeInsets.only(left: 3),
                child: Text(
                  'Posted ${_formatDate(job.createdAt)}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: jobTypeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job.jobType,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Job title
          Padding(
           padding: const EdgeInsets.only(left: 3),
            child: Text(
              job.jobCategory,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 8),

          // Scheduled job date
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: 4),
              Text(
                'Scheduled for ${_formatScheduledDate(job.date)}',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Budget information
          Row(
            children: [
              Icon(
                Icons.currency_rupee,
                size: 16,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: 4),
              Text(
                isFullTime
                    ? 'Rs. ${job.budget} per month'
                    : 'Rs. ${job.budget} per day',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          //! A C T I O N - B U T T O N S
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF0000CC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplicationListScreen(
                        jobId: job.id,
                        jobTitle: job.jobCategory,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Applications',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //! D A T E - F O R M A T T I N G - Same as in JobManagementScreen
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return difference.inMinutes == 1 
          ? '1 minute ago' 
          : '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return difference.inHours == 1 
          ? '1 hour ago' 
          : '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return difference.inDays == 1 
          ? '1 day ago' 
          : '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  //! S C H E D U L E D - D A T E - F O R M A T T I N G - Same as in JobManagementScreen
  String _formatScheduledDate(DateTime date) {
    // Get day with ordinal suffix (1st, 2nd, 3rd, etc.)
    String dayWithSuffix = _getDayWithSuffix(date.day);
    
    // Get month name
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String monthName = months[date.month - 1];
    
    // Format the date as "1st May 2024"
    return '$dayWithSuffix $monthName ${date.year}';
  }
  
  //! O R D I N A L - S U F F I X - Same as in JobManagementScreen
  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th'; // 11th, 12th, 13th
    }
    
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }
}