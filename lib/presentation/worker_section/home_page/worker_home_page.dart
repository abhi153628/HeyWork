import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import 'package:hey_work/presentation/hirer_section/settings_screen/settings_page.dart';
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
      iconPath: 'asset/Rectangle 24928.png',
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
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
   
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Padding(
              padding: const EdgeInsets.only(top: 29,left: 20),
                child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Heywork',
                          style: GoogleFonts.roboto(
                            color: Color(0xFF0000CC),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu, color: Color(0xFF0000CC)),
                          onPressed: () {Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>  SettingsScreen(),
              ));},
                        ),
                      ],
                    ),
              ),

                  // Location row
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16,left: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.black54,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _workerLocation,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ),
                
              
            
                    Container(
              height: 180,
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF0000CC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find Part-Time',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Jobs Near Me',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 0,
                    child: Image.asset(
                      'asset/Rectangle 24928.png', // Make sure this image exists
                      height: 200,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
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
                      Container(
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            // Header section
            

            // Search bar section with blue background
        

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