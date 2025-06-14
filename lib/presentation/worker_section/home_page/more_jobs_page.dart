import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:heywork/presentation/worker_section/worker_application_screen/jobs_service.dart';
import 'package:heywork/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'search_bar_widget.dart';
import 'widgets/catogory_list.dart';
import 'widgets/job_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoreJobsPage extends StatefulWidget {
  final String category;
  final String workerLocation;

  const MoreJobsPage({
    Key? key,
    required this.category,
    required this.workerLocation,
  }) : super(key: key);

  @override
  State<MoreJobsPage> createState() => _MoreJobsPageState();
}

class _MoreJobsPageState extends State<MoreJobsPage> {
  final JobService _jobService = JobService();
  late Stream<List<JobModel>> _jobsStream;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // ADD: Track applied jobs
  Set<String> _appliedJobIds = {};
  bool _isLoadingAppliedJobs = true;

  @override
  void initState() {
    super.initState();

    // Initialize jobs stream based on category
    _initJobsStream();

    // Set the selected category in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      jobProvider.setSelectedCategory(widget.category);
    });

    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);

    // ADD: Load applied jobs
    _loadAppliedJobs();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  //! L O A D  A P P L I E D  J O B S
  Future<void> _loadAppliedJobs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoadingAppliedJobs = false;
      });
      return;
    }

    try {
      // Query all applications for this user
      final snapshot = await FirebaseFirestore.instance
          .collection('jobApplications')
          .where('workerId', isEqualTo: user.uid)
          .get();

      Set<String> tempAppliedJobs = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['jobId'] != null) {
          tempAppliedJobs.add(data['jobId']);
        }
      }

      if (mounted) {
        setState(() {
          _appliedJobIds = tempAppliedJobs;
          _isLoadingAppliedJobs = false;
        });
      }

      // DEBUG: Print applied job IDs
      print('Applied Jobs Loaded in MoreJobsPage: $_appliedJobIds');
    } catch (e) {
      print('Error loading applied jobs: $e');
      if (mounted) {
        setState(() {
          _isLoadingAppliedJobs = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;

      // If there's search text, we'll let the local filter handle it
      // We don't need to refresh the Firestore query for every keystroke
    });
  }

  void _initJobsStream() {
    // Start with no filters - we'll handle filtering in the UI
    if (widget.category == "Nearby Jobs") {
      _jobsStream = _jobService.getAllJobsByCategory(
        widget.workerLocation,
        workerLocation: widget.workerLocation,
      );
    } else if (widget.category == "All Jobs") {
      _jobsStream = _jobService.getAllJobs();
    } else {
      _jobsStream = _jobService.getAllJobsByCategory(
        widget.category,
        workerLocation: widget.workerLocation,
      );
    }
  }

  void _onCategorySelected(String category) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.setSelectedCategory(category);

    setState(() {
      // Update the stream based on the new category
      if (category == "Nearby Jobs") {
        _jobsStream = _jobService.getAllJobsByCategory(
          widget.workerLocation,
          workerLocation: widget.workerLocation,
        );
      } else if (category == "All Jobs") {
        _jobsStream = _jobService.getAllJobs();
      } else {
        _jobsStream = _jobService.getAllJobsByCategory(
          category,
          workerLocation: widget.workerLocation,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the title based on the category
    String title = widget.category;
    if (title == 'All Jobs') {
      title = 'All Jobs';
    } else if (title == "Nearby Jobs") {
      title = 'Jobs in ${widget.workerLocation}';
    } else if (title == 'Full-Time') {
      title = 'Full-Time Jobs';
    } else if (title == 'Part-Time') {
      title = 'Part-Time Jobs';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Fixed header with AppBar and Search
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar - Now fixed in position
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 16.0),
                    child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search jobs...',
                            hintStyle: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[900],
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear,
                                        size: 18, color: Colors.grey[600]),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            border: InputBorder.none,
                         
                        
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          style: TextStyle(fontSize: 14),
                          cursorColor: Color(0xFF0000CC),
                          cursorWidth: 1,
                          textAlignVertical: TextAlignVertical.center,
                        )),
                  ),
                ],
              ),
            ),
          ),

          // Categories (fixed position below search bar)
          Container(
            color: Colors.white,
            child: Consumer<JobProvider>(
              builder: (context, jobProvider, child) {
                return CategoryListWidget(
                  categories: jobProvider.categories,
                  selectedCategory: jobProvider.selectedCategory,
                  onCategorySelected: _onCategorySelected,
                );
              },
            ),
          ),

          // Scrollable content (job listings)
          Expanded(
            child: StreamBuilder<List<JobModel>>(
              stream: _jobsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _isLoadingAppliedJobs) {
                  return Center(child: SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    ));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No jobs available'));
                }

                // Filter jobs based on search query
                final allJobs = snapshot.data!;

                // Enhanced filtering functionality that combines everything into one search
                final filteredJobs = _searchQuery.isEmpty
                    ? allJobs
                    : allJobs.where((job) {
                        final query = _searchQuery.toLowerCase();

                        // Check all possible fields for matches
                        return job.title.toLowerCase().contains(query) ||
                            job.company.toLowerCase().contains(query) ||
                            job.location.toLowerCase().contains(query) ||
                            job.hirerIndustry.toLowerCase().contains(query) ||
                            job.jobCategory.toLowerCase().contains(query) ||
                            job.description.toLowerCase().contains(query) ||
                            // Additional match for prefix search like "industry:tech" or "category:delivery"
                            (query.startsWith("industry:") &&
                                job.hirerIndustry
                                    .toLowerCase()
                                    .contains(query.substring(9).trim())) ||
                            (query.startsWith("category:") &&
                                job.jobCategory
                                    .toLowerCase()
                                    .contains(query.substring(9).trim()));
                      }).toList();

                if (filteredJobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No matching jobs found'),
                        SizedBox(height: 12),
                        Text(
                          'Try searching by industry: "industry:tech"\nor job category: "category:delivery"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredJobs.length + 1,
                  itemBuilder: (context, index) {
                    if (index < filteredJobs.length) {
                      final job = filteredJobs[index];
                      final isApplied = _appliedJobIds.contains(job.id);
                      
                      // DEBUG: Print each job's status
                      if (index < 3) { // Only print first few to avoid spam
                        print('Job ${job.id}: ${job.jobCategory} - Applied: $isApplied');
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: JobCardWidget(
                          job: job,
                          isApplied: isApplied, // ✅ PASS APPLICATION STATUS
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 50),
                        child: Center(
                          child: Text(
                            filteredJobs.length == allJobs.length
                                ? 'No more jobs to display'
                                : 'End of search results',
                            style: TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for JobService - simplified
extension JobServiceExtension on JobService {
  Stream<List<JobModel>> getAllJobs() {
    // Return all jobs
    return getJobs();
  }

  Stream<List<JobModel>> getAllJobsByCategory(String category,
      {String? workerLocation}) {
    return getJobsByCategory(
      category,
      workerLocation: workerLocation,
    );
  }
}