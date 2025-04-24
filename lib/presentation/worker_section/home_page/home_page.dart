// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JobService _jobService = JobService();
  late Stream<List<JobModel>> _jobsStream;

  @override
  void initState() {
    super.initState();

    // Initialize job categories
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.setCategories(_jobService.getJobCategories());

    // Set initial jobs stream
    _jobsStream = _jobService.getJobs();
  }

  void _onCategorySelected(String category) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.setSelectedCategory(category);
    setState(() {
      _jobsStream = _jobService.getJobsByCategory(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF0000CC),
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 15, left: 18),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'HeyWork',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 30.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 18,
                  ),
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
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //! Container
          Stack(children: [
            
            Container(
              height: 150,
              decoration: BoxDecoration(color: Color(0xFF0000CC)),
            ),
              const Padding(
            padding: EdgeInsets.only(top: 120,),
            child: Center(child: SearchBarWidget()),
          ),
          ]),
          // Search Bar
        SizedBox(height: 10,),

          // Categories Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Categories', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
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

          // Jobs List
          Expanded(
            child: StreamBuilder<List<JobModel>>(
              stream: _jobsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No jobs available'));
                }

                final jobs = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    return JobCardWidget(job: jobs[index]);
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
                hintText: 'Search here...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkGrey,
                    ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
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
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.black : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryBlue : AppColors.mediumGrey,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Icon(
                      _getCategoryIcon(category.name),
                      color:
                          isSelected ? Colors.white : Colors.black,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.name,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                      letterSpacing: 0.2

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
    final isPartTime = job.jobType.toLowerCase() == 'part-time';
    final jobTypeColor = isPartTime ? AppColors.primaryBlue : AppColors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.black.withOpacity(0.3),
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
                'Posted ${_getTimeAgo(job.postedAt)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.darkGrey,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          job.imageUrl!,
                          width: 40,
                          height: 40,
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
                      job.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                    Text(
                      job.company,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location and salary
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: 4),
              Text(
                '${job.location}, ${job.district}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.currency_rupee,
                size: 16,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: 4),
              Text(
                '${job.salary} ${job.salaryPeriod}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
