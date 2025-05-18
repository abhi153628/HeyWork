import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import 'package:hey_work/presentation/hirer_section/worker_detail_screen/worker_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import for cached images
import '../../worker_section/job_detail_screen/job_application_service.dart';
import '../../worker_section/job_detail_screen/job_application_modal.dart';


class ApplicationListScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const ApplicationListScreen({
    Key? key,
    required this.jobId,
    required this.jobTitle,
  }) : super(key: key);

  @override
  _ApplicationListScreenState createState() => _ApplicationListScreenState();
}

class _ApplicationListScreenState extends State<ApplicationListScreen> with SingleTickerProviderStateMixin {
  final JobApplicationService _applicationService = JobApplicationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  // Map to cache worker locations
  final Map<String, String> _workerLocations = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _updateApplicationStatus(
      String applicationId, String status) async {
    try {
      // For 'accepted' status, use the confirmation flow
      if (status == 'accepted') {
        final application = await _firestore.collection('jobApplications').doc(applicationId).get();
        if (application.exists) {
          final applicationData = application.data() as Map<String, dynamic>;
          final JobApplicationModel model = JobApplicationModel.fromFirestore(
            application,
          );
          _showHireConfirmation(context, model);
        }
        return;
      }
      
      // For other statuses (like rejected)
      final result = await _applicationService.updateApplicationStatus(
        applicationId,
        status,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Applications for ${widget.jobTitle}',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF0000CC),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF0000CC),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Hired'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationList(null),           // All applications
          _buildApplicationList('accepted'),     // Hired applications
        ],
      ),
    );
  }

  Widget _buildApplicationList(String? status) {
    return StreamBuilder<List<JobApplicationModel>>(
      stream: _getFilteredApplications(status),
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

        final applications = snapshot.data ?? [];

        if (applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_search,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  status == null
                      ? 'No applications yet'
                      : 'No hired workers yet',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status == null
                      ? 'Check back later for applicants'
                      : 'Hired workers will appear here',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final application = applications[index];
            return _buildWorkerProfileCard(application);
          },
        );
      },
    );
  }

  Stream<List<JobApplicationModel>> _getFilteredApplications(String? status) {
    if (status == null) {
      return _applicationService.getJobApplications(widget.jobId);
    } else {
      return _applicationService.getJobApplicationsByStatus(widget.jobId, status);
    }
  }

  Widget _buildWorkerProfileCard(JobApplicationModel application) {
    // Fetch the worker's current location
    _fetchCurrentWorkerLocation(application.workerId);
    
    return GestureDetector(
      onTap: () {
        // Navigate to the worker details page when card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkerDetailsPage(
              application: application,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Worker profile image with CachedNetworkImage
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 90,
                      height: 90,
                      child: application.workerProfileImage != null
                          ? CachedNetworkImage(
                              imageUrl: application.workerProfileImage!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      const Color(0xFF414ce4),
                                    ),
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Worker info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              application.workerName,
                              style: GoogleFonts.roboto(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Verified badge
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Using StreamBuilder for real-time location updates
                        _buildLocationText(application.workerId, application.workerLocation),
                        const SizedBox(height: 12),
                        // Works done count
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            FutureBuilder<int>(
                              future: _getWorkerCompletedJobsCount(application.workerId),
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                return Text(
                                  'Works done: $count',
                                  style: GoogleFonts.roboto(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Contact buttons
              Row(
                children: [
                  // Show Number button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final Uri phoneUri = Uri(
                          scheme: 'tel',
                          path: application.workerPhone,
                        );
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not launch phone dialer'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00A81E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Show Number',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // WhatsApp button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final phoneNumber = application.workerPhone.replaceAll(RegExp(r'[^0-9]'), '');
                        final whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');
                        
                        if (await canLaunchUrl(whatsappUrl)) {
                          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('WhatsApp is not installed on your device'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Color(0xFF00A81E)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'asset/images-removebg-preview (1).png',
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'WhatsApp',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Show accept/reject buttons for pending applications
              if (application.status.toLowerCase() == 'pending')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showHireConfirmation(context, application),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Hire'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateApplicationStatus(application.id, 'rejected'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Show hired badge if worker was hired
              if (application.status.toLowerCase() == 'accepted')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'HIRED',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            letterSpacing: 1.2,
                          ),
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

  // Widget to display location with real-time updates
  Widget _buildLocationText(String workerId, String fallbackLocation) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('workers').doc(workerId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final location = data?['location'];
          
          // Handle different location formats
          String locationText = fallbackLocation;
          if (location != null) {
            if (location is Map) {
              // If location is stored as a Map, extract just the place name
              locationText = location['placeName']?.toString() ?? location.values.first?.toString() ?? fallbackLocation;
            } else {
              // If location is a simple string
              locationText = location.toString();
            }
          }
          
          if (locationText.isNotEmpty) {
            return Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    locationText,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }
        }
        
        // Use cached location or fallback
        return Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.grey.shade600,
            ),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                _workerLocations[workerId] ?? fallbackLocation,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  // Get count of completed jobs for a worker
  Future<int> _getWorkerCompletedJobsCount(String workerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('jobApplications')
          .where('workerId', isEqualTo: workerId)
          .where('status', isEqualTo: 'accepted')
          .get();
          
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching worker completed jobs count: $e');
      return 0;
    }
  }

  // Fetch and cache worker location
  void _fetchCurrentWorkerLocation(String workerId) async {
    // Skip if we already have this worker's location
    if (_workerLocations.containsKey(workerId)) return;
    
    try {
      final workerDoc = await _firestore.collection('workers').doc(workerId).get();
      if (workerDoc.exists) {
        final workerData = workerDoc.data() ?? {};
        
        // Handle different location formats
        final currentLocation = workerData['location'];
        String locationText = '';
        
        if (currentLocation != null) {
          if (currentLocation is Map) {
            // If location is stored as a Map, extract just the place name
            locationText = currentLocation['placeName']?.toString() ?? 
                          currentLocation.values.first?.toString() ?? '';
          } else {
            // If location is a simple string
            locationText = currentLocation.toString();
          }
        }
        
        if (locationText.isNotEmpty) {
          setState(() {
            _workerLocations[workerId] = locationText;
          });
        }
      }
    } catch (e) {
      print('Error fetching worker location for $workerId: $e');
    }
  }

  void _showHireConfirmation(BuildContext context, JobApplicationModel application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Color(0xFF414ce4).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add,
                  color: Color(0xFF414ce4),
                  size: 40,
                ),
              ),
              
              SizedBox(height: 20),
              
              // Title
              Text(
                'Hire this Worker?',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              SizedBox(height: 16),
              
              // Message
              Text(
                'You are about to hire ${application.workerName} for this job. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              
              SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  
                  // Confirm button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmHiring(application.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF414ce4),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm Hire',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _confirmHiring(String applicationId) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF414ce4)),
          ),
        ),
      );

      // Update application status to accepted
      final result = await _applicationService.updateApplicationStatus(
        applicationId,
        'accepted',
      );

      // Close loading dialog
      Navigator.pop(context);
      
      // Show success/error message
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Worker hired successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error hiring worker: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}