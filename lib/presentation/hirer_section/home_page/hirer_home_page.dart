import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import 'package:hey_work/presentation/hirer_section/job_managment_screen/job_managment_screen.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:hey_work/presentation/worker_section/job_detail_screen/job_application_service.dart';
import 'package:lottie/lottie.dart';
import '../common/floating_action_button.dart';
import '../job_catogory.dart';
import '../settings_screen/settings_page.dart';
import '../widgets/category_chips.dart';
import '../widgets/worker_type_bottom_sheet.dart';
import 'package:intl/intl.dart';
import '../jobs_posted/hirer_job_detail_screen.dart';
import '../jobs/posted_jobs.dart';
import '../hirer_view_job_applications/hirer_view_job_applications.dart';

//! S E A R C H  B A R  W I D G E T
class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appThemeBackgroundGrey = Colors.grey[200];

    return GestureDetector(
      onTap: () => _showJobCategoriesSearchSheet(context),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: appThemeBackgroundGrey,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
        child: Row(
          children: [
            Flexible(
              child: Text(
                'Start a job search',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14.sp, // More responsive font size
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.search,
              color: Colors.grey,
              size: 20.sp, // Responsive icon size
            ),
          ],
        ),
      ),
    );
  }

  void _showJobCategoriesSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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

  void _loadAllJobs() {
    setState(() {
      _isLoading = true;
    });

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
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Padding(
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
                  Flexible(
                    child: Text(
                      'Search Jobs',
                      style: GoogleFonts.roboto(
                        fontSize: 18.sp, // More responsive
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, size: 24.sp),
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
                  hintStyle: TextStyle(fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, size: 20.sp),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 20.sp),
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
            
            // Job categories list
            Expanded(
              child: _isLoading
                  ?  SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    )
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
                            ..._getCategorizedJobs().entries.map((entry) {
                              return _buildCategorySection(
                                title: entry.key,
                                jobs: entry.value,
                              );
                            }).toList(),
                            SizedBox(height: keyboardHeight > 0 ? 20.h : 0),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildJobItem(Map<String, dynamic> job) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        
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
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16.sp,
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
        Flexible(
          child: Text(
            'Popular Categories',
            style: GoogleFonts.roboto(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () {
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
          setState(() {
            _selectedIndustry = 'General';
            _jobCategories = JobCategoryManager.commonJobCategories;
          });
        }
      }
    } catch (e) {
      print('Error loading user industry: $e');
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
        automaticallyImplyLeading: false, // Remove back button for home page
        title: Text(
          'Heywork',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 28.sp, // More responsive
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2020F0)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
              size: 24.sp, // Responsive icon size
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SettingsScreen(),
              ));
            },
          ),
        ],
      ),

      //! B O D Y
      body: _isLoading
          ?  Center(child:  SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    ))
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) => false,
              child: Stack(
                children: [
                  //! S C R O L L A B L E  C O N T E N T
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(height: 60.h), // Space for search bar
                      ),
                      SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // SizedBox(height: 12.h),
                            //! J O B  C A T E G O R I E S
                            _buildJobCategoriesSection(),

                            //! My Jobs Section
                            const MyJobsSection(),

                         // Extra space at bottom
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

  Widget _buildJobCategoriesSection() {
    // Calculate responsive grid
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.06; // Total horizontal padding
    final availableWidth = screenWidth - padding;
    final itemWidth = (availableWidth - (3 * 8.w)) / 4; // 4 items with gaps
    
    List<List<JobCategoryInfo>> categoryRows = [];
    for (var i = 0; i < _jobCategories.length; i += 4) {
      int end = (i + 4 <= _jobCategories.length) ? i + 4 : _jobCategories.length;
      categoryRows.add(_jobCategories.sublist(i, end));
    }

    return Column(
      children: [
        for (var row in categoryRows)
          Column(
            children: [
              _buildJobCategoryRow(row, itemWidth),
              SizedBox(height: 16.h),
            ],
          ),
      ],
    );
  }

  Widget _buildJobCategoryRow(List<JobCategoryInfo> categories, double itemWidth) {
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

  Widget _buildJobCategoryCard({
    required IconData icon,
    required String title,
    required double width,
  }) {
    final cardSize = width.clamp(30.0, 70.0); // Constrain card size

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => WorkerTypeBottomSheet(
            jobCategory: title.replaceAll('\n', ' '),
          ),
        );
      },
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            // Card container
            Container(
              width: cardSize,
              height: cardSize,
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
                  size: (cardSize * 0.4).clamp(16.0, 28.0), // Responsive icon size
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Text label with responsive sizing
            SizedBox(
              width: width,
              height: 36.h, // Slightly more height for better text layout
              child: Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 11.sp, // More responsive font size
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//! M Y  J O B S  S E C T I O N
//! M Y  J O B S  S E C T I O N
class MyJobsSection extends StatefulWidget {
  const MyJobsSection({Key? key}) : super(key: key);

  @override
  State<MyJobsSection> createState() => _MyJobsSectionState();
}

class _MyJobsSectionState extends State<MyJobsSection> {
  final JobService _jobService = JobService();
  final JobApplicationService _applicationService = JobApplicationService(); // Add this line

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(),
        SizedBox(height: 12.h),
        _buildJobList(),
      ],
    );
  }
  
  Widget _buildSectionHeader() {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
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
  
  Widget _buildJobList() {
    return Column(
      children: [
        // Jobs list without fixed height - let it size naturally
        StreamBuilder<QuerySnapshot>(
          stream: _getJobsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 200.h,
                child: SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                height: 200.h,
                child: Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                ),
              );
            }

            final jobDocs = snapshot.data?.docs ?? [];

            if (jobDocs.isEmpty) {
              return Container(
                height: 300.h,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_off,
                        size: 60.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No jobs posted yet',
                        style: GoogleFonts.roboto(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Create a job to see it here',
                        style: GoogleFonts.roboto(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final jobs = jobDocs.map((doc) => JobModel.fromFirestore(doc)).toList();
            final limitedJobs = jobs.length > 5 ? jobs.sublist(0, 5) : jobs;

            return Column(
              children: [
                // Use Column instead of ListView to avoid scrolling conflicts
                ...limitedJobs.map((job) => _buildJobCard(job)).toList(),
              ],
            );
          },
        ),
        
        // "View All Jobs" button
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
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
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0011C9),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward,
                    color: const Color(0xFF0011C9),
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getJobsStream() {
    var query = FirebaseFirestore.instance
      .collection('jobs')
      .where('hirerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .orderBy('createdAt', descending: true)
      .limit(5);

    return query.snapshots();
  }

  // Add this method to get application count for a specific job
  Stream<int> _getApplicationCount(String jobId) {
    return FirebaseFirestore.instance
        .collection('jobApplications')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

Widget _buildJobCard(JobModel job) {
    final isFullTime = job.jobType.toLowerCase() == 'full-time';
    final jobTypeColor = isFullTime ? AppColors.green : Color(0xFF0000CC);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
      child: InkWell(
        // Make the entire card clickable
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
        borderRadius: BorderRadius.circular(16.r), // Match container border radius
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Posted date and job type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Posted ${_formatDate(job.createdAt)}',
                      style: GoogleFonts.roboto(
                        fontSize: 11.sp,
                        color: AppColors.darkGrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: jobTypeColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      job.jobType,
                      style: GoogleFonts.roboto(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Job title
              Text(
                job.jobCategory,
                style: GoogleFonts.roboto(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 8.h),

              // Scheduled job date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14.sp,
                    color: AppColors.darkGrey,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      'Scheduled for ${_formatScheduledDate(job.date)}',
                      style: GoogleFonts.roboto(
                        fontSize: 12.sp,
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14.sp,
                    color: AppColors.darkGrey,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      job.location,
                      style: GoogleFonts.roboto(
                        fontSize: 12.sp,
                        color: AppColors.darkGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Budget information
              Row(
                children: [
                  Icon(
                    Icons.currency_rupee,
                    size: 14.sp,
                    color: AppColors.darkGrey,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      isFullTime
                          ? 'Rs. ${job.budget} per month'
                          : 'Rs. ${job.budget} per day',
                      style: GoogleFonts.roboto(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              //! A C T I O N - B U T T O N S with Dynamic Application Count
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF0000CC),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      // Dynamic application count using StreamBuilder
                      StreamBuilder<int>(
                        stream: _getApplicationCount(job.id),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          
                          // Handle singular/plural text
                          String buttonText;
                          if (count == 0) {
                            buttonText = 'No Applications';
                          } else if (count == 1) {
                            buttonText = '1 Application';
                          } else {
                            buttonText = '$count Applications';
                          }
                          
                          return Text(
                            buttonText,
                            style: GoogleFonts.roboto(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
  
  String _formatScheduledDate(DateTime date) {
    String dayWithSuffix = _getDayWithSuffix(date.day);
    
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String monthName = months[date.month - 1];
    
    return '$dayWithSuffix $monthName ${date.year}';
  }
  
  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }
}