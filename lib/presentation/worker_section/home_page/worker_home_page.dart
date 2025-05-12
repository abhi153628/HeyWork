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
  String _workerLocation = 'Location';

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

  void _onCategorySelected(String category) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.setSelectedCategory(category);

    setState(() {
      // Special handling for "Nearby Jobs" category
      if (category == "Nearby Jobs") {
        // Use the actual worker location value for filtering
        _jobsStream = _jobService.getJobsByCategory(_workerLocation,
            workerLocation: _workerLocation);
      } else {
        // Normal handling for other categories
        _jobsStream = _jobService.getJobsByCategory(category,
            workerLocation: _workerLocation);
      }
    });
  }

  void _navigateToMoreJobs() {
    // Get the current selected category
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    String category = jobProvider.selectedCategory;
    
    // Navigate to MoreJobsPage passing the category
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoreJobsPage(
          category: category,
          workerLocation: _workerLocation,
        ),
      ),
    );
  }

  // New method to navigate to search page
  void _navigateToSearchPage() {
    // Get the current selected category from provider
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    String category = jobProvider.selectedCategory;
    
    // Navigate to MoreJobsPage with current category and worker location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoreJobsPage(
          category: category,
          workerLocation: _workerLocation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
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
            Stack(children: [
              Container(
                height: 150,
                decoration: BoxDecoration(color: Color(0xFF0000CC)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Center(
                  child: GestureDetector(
                    onTap: _navigateToSearchPage, // Using the new navigation method
                    child: SearchBarWidget(),
                  )
                ),
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

            // Jobs List (10 jobs)
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

                // Show only first 10 jobs
                final jobs = snapshot.data!.take(10).toList();
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ...jobs.map((job) => JobCardWidget(job: job)).toList(),
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
    );
  }
  
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