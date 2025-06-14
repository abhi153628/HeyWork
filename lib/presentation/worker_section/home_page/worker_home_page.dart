import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:heywork/presentation/worker_section/worker_application_screen/jobs_service.dart';
import 'package:heywork/presentation/hirer_section/settings_screen/settings_page.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'more_jobs_page.dart';

import 'widgets/catogory_list.dart';
import 'widgets/job_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  final JobService _jobService = JobService();
  
  // ADD: ScrollController to manage scroll position
  final ScrollController _scrollController = ScrollController();

  Stream<List<JobModel>>? _jobsStream;
  String _workerLocation = '';
  bool _isLoadingLocation = true;
  bool _isInitialized = false;
  
  // Track applied jobs
  Set<String> _appliedJobIds = {};
  bool _isLoadingAppliedJobs = true;

  @override
  void initState() {
    super.initState();
    _jobsStream = _jobService.getJobs(); // Initialize immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCategoriesWithLocation();
      _refreshJobsWithLocation();
      _initializeApp();
      _loadAppliedJobs();
    });
  }

  // ADD: Dispose ScrollController
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ADD: Method to scroll to top
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
      print('Applied Jobs Loaded: $_appliedJobIds');
    } catch (e) {
      print('Error loading applied jobs: $e');
      if (mounted) {
        setState(() {
          _isLoadingAppliedJobs = false;
        });
      }
    }
  }

  //! R E F R E S H  A P P L I E D  J O B S  (Call when returning from job detail)
  Future<void> _refreshAppliedJobs() async {
    await _loadAppliedJobs();
    // MODIFIED: Scroll to top when refreshing
    _scrollToTop();
  }

  //! I N I T I A L I Z A T I O N
  void _initializeApp() async {
    // Initialize job categories
    if (_isInitialized) return; 
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.setCategories(_jobService.getJobCategories());
    
    // Set initial jobs stream
    _jobsStream = _jobService.getJobs();
    
    // Fetch worker location
    await _fetchWorkerLocation();
    
    // MODIFIED: Mark as initialized
    _isInitialized = true;
  }

  //! H E L P E R  M E T H O D  T O  G E T  F I R S T  W O R D
  String _getLocationDisplay(String location) {
    if (location.isEmpty) return 'Unknown Location';
    
    // Split by comma and take the first part, then get first word
    List<String> parts = location.split(',');
    if (parts.isNotEmpty) {
      String firstPart = parts[0].trim();
      List<String> words = firstPart.split(' ');
      return words.isNotEmpty ? words[0] : 'Unknown';
    }
    return 'Unknown';
  }

  //! L O C A T I O N  F E T C H I N G
  Future<void> _fetchWorkerLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
      });

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _workerLocation = 'Location Unknown';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get location directly from Firestore
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot = 
          await FirebaseFirestore.instance
              .collection('workers')
              .doc(user.uid)
              .get();

      if (!mounted) return;

      String locationText = 'Location Unknown';
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final userData = docSnapshot.data()!;
        
        if (userData.containsKey('location')) {
          final locationData = userData['location'];
          
          if (locationData is Map<String, dynamic> && 
              locationData.containsKey('placeName')) {
            locationText = locationData['placeName'] ?? 'Location Unknown';
          } else if (locationData is String && locationData.isNotEmpty) {
            locationText = locationData;
          }
        }
      }

      setState(() {
        _workerLocation = locationText;
        _isLoadingLocation = false;
      });

      // Update categories with location
      _updateCategoriesWithLocation();
      
      // Refresh jobs with location
      _refreshJobsWithLocation();

    } catch (error) {
      print('Error fetching location: $error');
      
      if (!mounted) return;
      
      setState(() {
        _workerLocation = 'Location Unavailable';
        _isLoadingLocation = false;
      });

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not fetch location'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  //! U P D A T E  C A T E G O R I E S  W I T H  L O C A T I O N
  void _updateCategoriesWithLocation() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    if (jobProvider.categories.isNotEmpty) {
      List<JobCategory> categories = List.from(jobProvider.categories);
      
      // Update the first category to show "Nearby Jobs"
      if (categories.isNotEmpty) {
        categories[0] = JobCategory(
          id: 'location',
          name: "Nearby Jobs",
          iconPath: categories[0].iconPath,
          isSelected: categories[0].isSelected,
        );
        
        jobProvider.setCategories(categories);
      }
    }
  }

  //! R E F R E S H  J O B S  W I T H  L O C A T I O N
  void _refreshJobsWithLocation() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    setState(() {
      if (jobProvider.selectedCategory == "Nearby Jobs") {
        _jobsStream = _jobService.getJobsByCategory(
          _workerLocation,
          workerLocation: _workerLocation
        );
      } else {
        _jobsStream = _jobService.getJobsByCategory(
          jobProvider.selectedCategory,
          workerLocation: _workerLocation
        );
      }
    });
  }

  //! R E F R E S H  L O C A T I O N  (Called when returning from profile)
  Future<void> _refreshLocation() async {
    await _fetchWorkerLocation();
    // Also refresh applied jobs when returning
    await _refreshAppliedJobs();
    // MODIFIED: Scroll to top when refreshing location
    _scrollToTop();
  }

  //! S H A R E  J O B
  void _shareJob(JobModel job) {
    final String shareText = '''
Job Opportunity: ${job.title}
Company: ${job.company}
Location: ${job.location}
Salary: ${job.hirerBusinessName}
Description: ${job.description.length > 100 ? '${job.description.substring(0, 100)}...' : job.description}

Find more jobs on HeyWork!
''';

    Share.share(shareText, subject: 'Check out this job opportunity!');
  }

  //! C A T E G O R Y  S E L E C T I O N
  void _onCategorySelected(String category) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.setSelectedCategory(category);

    setState(() {
      if (category == "Nearby Jobs") {
        _jobsStream = _jobService.getJobsByCategory(
          _workerLocation,
          workerLocation: _workerLocation
        );
      } else {
        _jobsStream = _jobService.getJobsByCategory(
          category,
          workerLocation: _workerLocation
        );
      }
    });
  }

  //! N A V I G A T I O N
  void _navigateToMoreJobs() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    String category = jobProvider.selectedCategory;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoreJobsPage(
          category: category,
          workerLocation: _workerLocation,
        ),
      ),
    ).then((_) {
      // MODIFIED: Refresh applied jobs and scroll to top when returning
      _refreshAppliedJobs();
    });
  }

  void _navigateToSearchPage() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    String category = jobProvider.selectedCategory;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoreJobsPage(
          category: category,
          workerLocation: _workerLocation,
        ),
      ),
    ).then((_) {
      // MODIFIED: Refresh applied jobs and scroll to top when returning
      _refreshAppliedJobs();
    });
  }

  void _navigateToSettings() async {
    // Navigate to settings and wait for result
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
    
    // MODIFIED: Refresh location and scroll to top when returning from settings
    _refreshLocation();
  }

  @override
  Widget build(BuildContext context) {
    //! S Y S T E M  U I  S T Y L E
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController, // ADD: Assign ScrollController
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //! A P P  B A R
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Heywork',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2020F0)),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: _navigateToSettings,
                    ),
                  ],
                ),
              ),
          
              //! L O C A T I O N  I N D I C A T O R
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.black54,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    _isLoadingLocation
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: SizedBox(
                              width: 140,
                              height: 140,
                              child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
                            )
                          )
                        : Text(
                            _getLocationDisplay(_workerLocation),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                          ),
                  ],
                ),
              ),
              
              //! H E R O  B A N N E R
              // MODIFIED: Added proper error handling for the image
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'asset/app banner.png',
                    // ADD: Error handling for image
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 50,
                          ),
                        ),
                      );
                    },
                    // ADD: Loading builder
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) {
                        return child;
                      }
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              
              //! S E A R C H  B A R
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _navigateToSearchPage,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: const Color.fromARGB(23, 0, 0, 0)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Search here...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
          
              SizedBox(height: 20),
          
              //! C A T E G O R I E S  T I T L E
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
              ),
          
              //! C A T E G O R I E S  L I S T
              Consumer<JobProvider>(
                builder: (context, jobProvider, child) {
                  return CategoryListWidget(
                    categories: jobProvider.categories,
                    selectedCategory: jobProvider.selectedCategory,
                    onCategorySelected: _onCategorySelected,
                  );
                },
              ),
          
              //! J O B S  L I S T
              StreamBuilder<List<JobModel>>(
                stream: _jobsStream ?? _jobService.getJobs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || _isLoadingAppliedJobs) {
                    return Container(
                      height: 200,
                      child: Center(
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
                        )
                      ),
                    );
                  }
          
                  if (snapshot.hasError) {
                    return Container(
                      height: 200,
                      child: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  }
          
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      height: 200,
                      child: Center(child: Text('No jobs available')),
                    );
                  }
          
                  // Show only first 10 jobs
                  final jobs = snapshot.data!.take(10).toList();
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Pass isApplied parameter
                        ...jobs.map((job) {
                          final isApplied = _appliedJobIds.contains(job.id);
                          return JobCardWidget(
                            job: job, 
                            isApplied: isApplied,
                          );
                        }).toList(),
                        // View All Jobs button
                        _buildViewAllJobsButton(),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  //! V I E W  A L L  J O B S  B U T T O N
  Widget _buildViewAllJobsButton() {
    return GestureDetector(
      onTap: _navigateToMoreJobs,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Color(0xFF0000CC).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View All Jobs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0000CC),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              color: Color(0xFF0000CC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}