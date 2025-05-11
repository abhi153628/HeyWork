import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import 'more_jobs_page.dart';
import 'search_bar_widget.dart';
import 'widgets/catogory_list.dart';
import 'widgets/job_card_widget.dart';
import 'package:provider/provider.dart';

class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  final JobService _jobService = JobService();
  late Stream<List<JobModel>> _jobsStream;
  late Stream<List<JobModel>> _allJobsStream;
  final ScrollController _scrollController = ScrollController();
  bool _showAllJobs = false;
  bool _isNavigating = false;

  // In _WorkerHomePageState class (paste-2.txt)
  String _workerLocation = 'Location';

  // For smooth scrolling experience
  final GlobalKey _homeContentKey = GlobalKey();
  final GlobalKey _searchBarKey = GlobalKey();
  double _searchBarInitialPosition = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));

    // Get worker's location
    _fetchWorkerLocation();

    // Initialize job categories
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.setCategories(_jobService.getJobCategories());

    // Set initial jobs stream
    _jobsStream = _jobService.getJobs();

    // Pre-fetch all jobs for instant navigation
    _allJobsStream = _jobService.getAllJobs();

    // Setup scroll listener for navigation
    _scrollController.addListener(_handleScroll);

    // Schedule measurement of search bar position after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureSearchBarPosition();
    });
  }

  void _fetchWorkerLocation() async {
    final location = await _jobService.getWorkerLocation();
    setState(() {
      _workerLocation = location;
    });

    // Update the first category with the worker's location
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    List<JobCategory> categories = List.from(jobProvider.categories);
    categories[0] = JobCategory(
      id: 'location',
      name: "Nearby Jobs",
      iconPath: 'assets/icons/location.png',
      isSelected: categories[0].isSelected,
    );
    jobProvider.setCategories(categories);
  }

  void _measureSearchBarPosition() {
    if (_searchBarKey.currentContext != null) {
      final RenderBox renderBox =
          _searchBarKey.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      _searchBarInitialPosition = position.dy;
    }
  }

  void _handleScroll() {
    // Prevent triggering during animation
    if (_isNavigating) return;

    // Calculate if we should navigate to all jobs
    if (!_showAllJobs &&
        _scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 100) {
      _navigateToAllJobs(smooth: true);
    }

    // Calculate if we should navigate back to home
    if (_showAllJobs && _scrollController.position.pixels <= 0) {
      _navigateToHome(smooth: true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.setSelectedCategory(category);

    setState(() {
      // Special handling for "Nearby Jobs" category
      if (category == "Nearby Jobs") {
        // Use the actual worker location value for filtering
        _jobsStream = _jobService.getJobsByCategory(_workerLocation,
            workerLocation: _workerLocation);

        // If we're in all jobs view, update that stream too
        if (_showAllJobs) {
          _allJobsStream = _jobService.getAllJobsByCategory(_workerLocation,
              workerLocation: _workerLocation);
        }
      } else {
        // Normal handling for other categories
        _jobsStream = _jobService.getJobsByCategory(category,
            workerLocation: _workerLocation);

        // If we're in all jobs view, update that stream too
        if (_showAllJobs) {
          _allJobsStream = category == 'All Jobs'
              ? _jobService.getAllJobs()
              : _jobService.getAllJobsByCategory(category,
                  workerLocation: _workerLocation);
        }
      }
    });
  }

  void _navigateToAllJobs({bool smooth = false}) {
    if (_showAllJobs) return;

    setState(() {
      _isNavigating = true;
      _showAllJobs = true;
    });

    if (smooth) {
      // Scroll to top with animation
      _scrollController
          .animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      )
          .then((_) {
        setState(() {
          _isNavigating = false;
        });
      });
    } else {
      _scrollController.jumpTo(0);
      setState(() {
        _isNavigating = false;
      });
    }
  }

  void _navigateToHome({bool smooth = false}) {
    if (!_showAllJobs) return;

    setState(() {
      _isNavigating = true;
      _showAllJobs = false;
    });

    if (smooth) {
      // Scroll to top with animation
      _scrollController
          .animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      )
          .then((_) {
        setState(() {
          _isNavigating = false;
        });
      });
    } else {
      _scrollController.jumpTo(0);
      setState(() {
        _isNavigating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _showAllJobs ? _buildAllJobsView() : _buildHomeView(),
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        key: _homeContentKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            color: Color(0xFF0000CC),
            padding:
                const EdgeInsets.only(top: 35, left: 20, right: 16, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with title and menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HeyWork',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),

                // Location row
                Padding(
                  padding: const EdgeInsets.only(top: 1, bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        _workerLocation,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search bar section with blue background
          Stack(key: _searchBarKey, children: [
            Container(
              height: 150,
              decoration: BoxDecoration(color: Color(0xFF0000CC)),
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 120,
              ),
              child: Center(child: SearchBarWidget()),
            ),
          ]),

          SizedBox(
            height: 10,
          ),

          // Categories Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),

          // Categories List
          Consumer<JobProvider>(
            builder: (context, jobProvider, child) {
              return CategoryListWidget(
                categories: jobProvider.categories,
                selectedCategory: jobProvider.selectedCategory,
                onCategorySelected: _onCategorySelected,
              );
            },
          ),

          // Limited Jobs List (5-6 jobs)
          StreamBuilder<List<JobModel>>(
            stream: _jobsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
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

              // Show only first 5-6 jobs
              final jobs = snapshot.data!.take(6).toList();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...jobs.map((job) => JobCardWidget(job: job)).toList(),
                    // Indicate more jobs with a subtle hint
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: MoreJobsIndicator(
                        onPressed: () => _navigateToAllJobs(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Get the current selected category
  Widget _buildAllJobsView() {
    // Get the current selected category
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    // Format the title based on the category
    String title = jobProvider.selectedCategory;
    if (title == 'All Jobs') {
      title = 'All Jobs';
    } else if (title == "Nearby Jobs") {
      title = 'Jobs in Bengaluru';
    } else if (title == 'Full-Time') {
      title = 'Full-Time Jobs';
    } else if (title == 'Part-Time') {
      title = 'Part-Time Jobs';
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Fixed AppBar with search
        SliverAppBar(
          backgroundColor: Color(0xFF0000CC),
          pinned: true,
          expandedHeight: 110,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => _navigateToHome(),
              ),
              Text(
                title,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Color(0xFF0000CC),
              padding: const EdgeInsets.only(top: 85),
              child: const Center(child: SearchBarWidget()),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10),
            child: Container(),
          ),
        ),

        // Categories
        SliverToBoxAdapter(
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

        // Jobs list
        StreamBuilder<List<JobModel>>(
          stream: _allJobsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SliverFillRemaining(
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SliverFillRemaining(
                child: Center(child: Text('No jobs available')),
              );
            }

            final jobs = snapshot.data!;
            return SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < jobs.length) {
                      return JobCardWidget(job: jobs[index]);
                    } else if (index == jobs.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 50),
                        child: Center(
                          child: Text(
                            'No more jobs to display',
                            style: TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  childCount: jobs.length + 1,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Change the name to something different
extension JobServiceViewExtension on JobService {
  Stream<List<JobModel>> getAllJobs() {
    // Return all jobs without limitation
    return getJobs();
  }

  Stream<List<JobModel>> getAllJobsByCategory(String category,
      {String? workerLocation}) {
    return getJobsByCategory(category, workerLocation: workerLocation);
  }
}
