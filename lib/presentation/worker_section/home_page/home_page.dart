import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JobService _jobService = JobService();
  late Stream<List<JobModel>> _jobsStream;
  late Stream<List<JobModel>> _allJobsStream;
  final ScrollController _scrollController = ScrollController();
  bool _showAllJobs = false;
  bool _isNavigating = false;
  
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
  
  void _measureSearchBarPosition() {
    if (_searchBarKey.currentContext != null) {
      final RenderBox renderBox = _searchBarKey.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      _searchBarInitialPosition = position.dy;
    }
  }
  
  void _handleScroll() {
    // Prevent triggering during animation
    if (_isNavigating) return;
    
    // Calculate if we should navigate to all jobs
    if (!_showAllJobs && 
        _scrollController.position.pixels > _scrollController.position.maxScrollExtent - 100) {
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
      _jobsStream = _jobService.getJobsByCategory(category);
      
      // If we're in all jobs view, update that stream too
      if (_showAllJobs) {
        _allJobsStream = category == 'All Works' ? 
            _jobService.getAllJobs() : 
            _jobService.getAllJobsByCategory(category);
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
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
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
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
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
            padding: const EdgeInsets.only(top: 35, left: 20, right: 16, bottom: 5),
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
                        'Bengaluru, Karnataka',
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
          Stack(
            key: _searchBarKey,
            children: [
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
            ]
          ),
          
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
  
  Widget _buildAllJobsView() {
    // Get the current selected category
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
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
                '${jobProvider.selectedCategory} Jobs',
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

class MoreJobsIndicator extends StatelessWidget {
  final VoidCallback onPressed;

  const MoreJobsIndicator({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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

// Keep the existing widget implementations below this point
// (SearchBarWidget, CategoryListWidget, JobCardWidget, ListAllJobsButton)

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(
            Icons.search,
            color: AppColors.darkGrey,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkGrey,
                    ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          Container(
            height: 40,
            width: 40,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Color(0xFF0000CC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.tune,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryListWidget extends StatelessWidget {
  final List<JobCategory> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryListWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.name == selectedCategory;

          return GestureDetector(
            onTap: () => onCategorySelected(category.name),
            child: Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF0000CC) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Color(0xFF0000CC) : AppColors.mediumGrey,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(0xFF0000CC).withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Icon(
                      _getCategoryIcon(category.name),
                      color: isSelected ? Colors.white : Colors.black,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      category.name,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'All Works':
        return Icons.work;
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'Moving':
        return Icons.local_shipping;
      case 'Cooking':
        return Icons.restaurant;
      case 'Driving':
        return Icons.drive_eta;
      case 'Housekeeping':
        return Icons.home;
      case 'Food Server':
        return Icons.restaurant_menu;
      case 'Hospitality & Hotels':
        return Icons.hotel;
      default:
        return Icons.work;
    }
  }
}

class JobCardWidget extends StatelessWidget {
  final JobModel job;

  const JobCardWidget({
    super.key,
    required this.job,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFullTime = job.jobType.toLowerCase() == 'full-time';
    final jobTypeColor = isFullTime ? AppColors.green : Color(0xFF0000CC);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          color: AppColors.mediumGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Posted time and job type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Posted ${_getTimeAgo(job.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGrey,
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Job title and company
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          job.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.business,
                                color: AppColors.darkGrey);
                          },
                        ),
                      )
                    : const Icon(Icons.business, color: AppColors.darkGrey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobCategory,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          job.company,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (job.hirerIndustry.isNotEmpty) ...[
                          Text(
                            ' (${job.hirerIndustry})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGrey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Salary or Budget information
          Row(
            children: [
              const Icon(
                Icons.currency_rupee,
                size: 16,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: isFullTime && job.salaryRange != null
                    ? Text(
                        'Rs. ${job.salaryRange!['min']} - ${job.salaryRange!['max']} per month',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGrey,
                        ),
                      )
                    : Text(
                        'Budget: Rs. ${job.budget}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGrey,
                        ),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Category and description
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (job.description.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    job.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'All Works':
        return Icons.work;
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'Moving':
        return Icons.local_shipping;
      case 'Cooking':
        return Icons.restaurant;
      case 'Driving':
        return Icons.drive_eta;
      case 'Housekeeping':
        return Icons.home;
      case 'Food Server':
        return Icons.restaurant_menu;
      case 'Hospitality & Hotels':
        return Icons.hotel;
      default:
        return Icons.work;
    }
  }
}

// Add these new service methods to JobService class
extension JobServiceExtension on JobService {
  Stream<List<JobModel>> getAllJobs() {
    // Similar to getJobs but returns all jobs without limitation
    // This should be pre-loaded to avoid delay when navigating
    return getJobs(); // Replace with actual implementation
  }
  
  Stream<List<JobModel>> getAllJobsByCategory(String category) {
    // Similar to getJobsByCategory but returns all jobs in the category
    return getJobsByCategory(category); // Replace with actual implementation
  }
}