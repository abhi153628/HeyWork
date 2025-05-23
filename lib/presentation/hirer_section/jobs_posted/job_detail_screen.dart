import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:hey_work/presentation/hirer_section/job_managment_screen/job_managment_screen.dart';
import '../jobs/posted_jobs.dart';
import 'package:intl/intl.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobCategory;
  final String jobType;
  final Map<String, dynamic>? existingJob;
  final bool isEditing;
  final String? jobId; // Add jobId parameter for editing

  const JobDetailsScreen({
    Key? key,
    required this.jobCategory,
    required this.jobType,
    this.existingJob,
    this.isEditing = false,
    this.jobId,
  }) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final JobService _jobService = JobService(); // Initialize the job service
  bool _isLoading = false; // Loading state

  // Form fields
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _jobType = '';

  // Animation controller for transitions
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Constants
  static const int _minimumBudget = 400;

  // Job Categories Data Structure
  final List<Map<String, dynamic>> _generalJobs = [
    {'name': 'Cleaner', 'category': 'General'},
    {'name': 'Helper', 'category': 'General'},
    {'name': 'Delivery Boy', 'category': 'General'},
    {'name': 'Receptionist', 'category': 'General'},
    {'name': 'Packing Staff', 'category': 'General'},
    {'name': 'Sorting Worker', 'category': 'General'},
    {'name': 'Security Guard', 'category': 'General'},
    {'name': 'Loader', 'category': 'General'},
    {'name': 'Unloader', 'category': 'General'},
    {'name': 'Kitchen Helper', 'category': 'General'},
    {'name': 'Maintenance Worker', 'category': 'General'},
    {'name': 'Cashier', 'category': 'General'},
    {'name': 'Office Boy', 'category': 'General'},
    {'name': 'Field Assistant', 'category': 'General'},
    {'name': 'Packer', 'category': 'General'},
    {'name': 'Driver', 'category': 'General'},
    {'name': 'Carpenter', 'category': 'General'},
    {'name': 'Ironing Staff', 'category': 'General'},
    {'name': 'Survey Helper', 'category': 'General'},
  ];

  final List<Map<String, dynamic>> _industryJobs = [
    // Restaurants & Food Services
    {'name': 'Waiter', 'category': 'Restaurants & Food Services'},
    {'name': 'Cook Assistant', 'category': 'Restaurants & Food Services'},
    {'name': 'Dishwasher', 'category': 'Restaurants & Food Services'},
    {'name': 'Food Server', 'category': 'Restaurants & Food Services'},

    // Hospitality & Hotels
    {'name': 'Housekeeper', 'category': 'Hospitality & Hotels'},
    {'name': 'Room Boy', 'category': 'Hospitality & Hotels'},
    {'name': 'Bellboy', 'category': 'Hospitality & Hotels'},
    {'name': 'Front Desk Assistant', 'category': 'Hospitality & Hotels'},

    // Warehouse & Logistics
    {'name': 'Inventory Assistant', 'category': 'Warehouse & Logistics'},
    {'name': 'Forklift Operator', 'category': 'Warehouse & Logistics'},

    // Construction & Civil Work
    {'name': 'Mason', 'category': 'Construction & Civil Work'},
    {'name': 'Electrician', 'category': 'Construction & Civil Work'},
    {'name': 'Plumber', 'category': 'Construction & Civil Work'},
    {'name': 'Tile Fitter', 'category': 'Construction & Civil Work'},
    {'name': 'Painter', 'category': 'Construction & Civil Work'},

    // Home Services
    {'name': 'Maid', 'category': 'Home Services'},
    {'name': 'Cook', 'category': 'Home Services'},
    {'name': 'Gardener', 'category': 'Home Services'},
    {'name': 'Babysitter', 'category': 'Home Services'},
    {'name': 'Elderly Care Assistant', 'category': 'Home Services'},
  ];

  List<Map<String, dynamic>> get _allJobs =>
      [..._generalJobs, ..._industryJobs];

  bool get _isFullTime => _jobType == 'full-time';

  @override
  void initState() {
    super.initState();

    // Set default budget
    _budgetController.text = _minimumBudget.toString();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Set job type
    _jobType = widget.jobType;
    if (_isFullTime) {
      _animationController.value = 1.0;
    }

    // Set initial text for category controller
    _categoryController.text = widget.jobCategory;

    // If editing, populate with existing data
    if (widget.isEditing && widget.existingJob != null) {
      _populateExistingJobData();
    }
  }

  void _populateExistingJobData() {
    final job = widget.existingJob!;

    _categoryController.text = job['jobCategory'] ?? '';
    _descriptionController.text = job['description'] ?? '';

    if (_isFullTime && job.containsKey('salaryRange')) {
      _minSalaryController.text = job['salaryRange']['min']?.toString() ?? '';
      _maxSalaryController.text = job['salaryRange']['max']?.toString() ?? '';
    } else {
      _budgetController.text = job['budget']?.toString() ?? '';
    }

    _selectedDate = job['date'];
    _selectedTime = job['time'];
  }

  void _toggleJobType() {
    setState(() {
      if (_isFullTime) {
        _jobType = 'part-time';
        _animationController.reverse();
      } else {
        _jobType = 'full-time';
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBody(),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0011C9),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.isEditing ? 'Edit Job Details' : 'Post a Job',
        style: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Job Type Toggle
          _buildJobTypeToggle(),
          SizedBox(height: 24.h),

          // Job Category (Clickable)
          _buildCategoryField(),
          SizedBox(height: 16.h),

          // Job Description
          _buildDescriptionField(),
          SizedBox(height: 16.h),

          // Date & Time Selection
          _buildDateTimeSection(),
          SizedBox(height: 16.h),

          // Budget or Salary Range based on job type with animation
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return AnimatedCrossFade(
                firstChild: _buildBudgetField(),
                secondChild: _buildSalaryRangeFields(),
                crossFadeState: _isFullTime
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
                layoutBuilder:
                    (topChild, topChildKey, bottomChild, bottomChildKey) {
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                        key: bottomChildKey,
                        child: bottomChild,
                      ),
                      Positioned(
                        key: topChildKey,
                        child: topChild,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: 24.h),

          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildJobTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            'Worker Type',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              // Part Time Button
              Expanded(
                child: InkWell(
                  onTap: _isFullTime ? _toggleJobType : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: !_isFullTime
                          ? const Color(0xFF0011C9)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        'PART TIME',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: !_isFullTime ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Full Time Button
              Expanded(
                child: InkWell(
                  onTap: !_isFullTime ? _toggleJobType : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: _isFullTime
                          ? const Color(0xFF0011C9)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        'FULL TIME',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _isFullTime ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

 Widget _buildCategoryField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
        child: Text(
          'Job Category',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
      InkWell(
        onTap: () => _showJobCategoryBottomSheet(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Color(0xFFf6f5f8),
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.work_outline,
                color: const Color(0xFF0011C9),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _categoryController.text.isNotEmpty
                      ? _categoryController.text
                      : 'Select Job Category',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: _categoryController.text.isNotEmpty
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade700,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

 Widget _buildDescriptionField() {
  return TextFormField(
    controller: _descriptionController,
    maxLines: 3,
    decoration: InputDecoration(
      fillColor: Color(0xFFf6f5f8),
      filled: true,
      labelText: 'Job Description',
      hintText: 'Describe the job requirements',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      prefixIcon: const Icon(Icons.description_outlined),
      alignLabelWithHint: true,
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a job description';
      }
      return null;
    },
  );
}
// Updated _buildDateTimeSection method with consistent colors
Widget _buildDateTimeSection() {
  return Row(
    children: [
      // Date Picker
      Expanded(
        child: InkWell(
          onTap: _pickDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Color(0xFFf6f5f8), // Match with other form fields
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'Select Date',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: _selectedDate != null ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey.shade800,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(width: 12.w),

      // Time Picker
      Expanded(
        child: InkWell(
          onTap: _pickTime,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Color(0xFFf6f5f8), // Match with other form fields
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: _selectedTime != null ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: Colors.grey.shade800,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
} Widget _buildBudgetField() {
  return Container(
    height: 80.h, // Fixed height for animation
    child: TextFormField(
      controller: _budgetController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        fillColor: Color(0xFFf6f5f8),
        filled: true,
        labelText: 'Budget (₹)',
        hintText: 'Minimum ₹$_minimumBudget',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        prefixIcon: const Icon(Icons.monetization_on_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a budget amount';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        if (int.parse(value) < _minimumBudget) {
          return 'Budget must be at least ₹$_minimumBudget';
        }
        return null;
      },
    ),
  );
}

 Widget _buildSalaryRangeFields() {
  return Container(
    height: 120.h, // Fixed height for animation
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            'Salary Range (₹)',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Row(
          children: [
            // Minimum Salary
            Expanded(
              child: TextFormField(
                controller: _minSalaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: Color(0xFFf6f5f8),
                  filled: true,
                  labelText: 'From',
                  hintText: 'Min ₹$_minimumBudget',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.remove),
                ),
                validator: (value) {
                  if (_isFullTime) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Invalid';
                    }
                    if (int.parse(value) < _minimumBudget) {
                      return 'Min ₹$_minimumBudget';
                    }
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 12.w),

            // Maximum Salary
            Expanded(
              child: TextFormField(
                controller: _maxSalaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: Color(0xFFf6f5f8),
                  filled: true,
                  labelText: 'To',
                  hintText: 'Max',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.add),
                ),
                validator: (value) {
                  if (_isFullTime) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Invalid';
                    }
                    // Validate that max is greater than min
                    final min = int.tryParse(_minSalaryController.text) ?? 0;
                    final max = int.tryParse(value) ?? 0;
                    if (max <= min) {
                      return 'Must be > min';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm, // Disable button when loading
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0011C9),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 0,
      ),
      child: Text(
        widget.isEditing ? 'UPDATE JOB' : 'POST JOB',
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0011C9),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0011C9),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

 // Updated _showJobCategoryBottomSheet method to fix the "attached is not true" error
// Complete replacement for _showJobCategoryBottomSheet method and related functions
void _showJobCategoryBottomSheet() {
  // Currently selected category for highlighting
  final currentCategory = _categoryController.text;

  // Search text controller
  final TextEditingController searchController = TextEditingController();

  // Filtered jobs list - initially all jobs
  List<Map<String, dynamic>> filteredJobs = [];
  
  // Make a defensive copy rather than directly referencing/modifying _allJobs
  filteredJobs.addAll(_allJobs);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (BuildContext sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          // Filter function - uses setSheetState to update only within the bottom sheet
          void filterJobs(String query) {
            setSheetState(() {
              if (query.isEmpty) {
                filteredJobs.clear();
                filteredJobs.addAll(_allJobs);
              } else {
                filteredJobs = _allJobs.where((job) {
                  return job['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                      job['category']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase());
                }).toList();
              }
            });
          }

          // Job category section builder
          Widget buildCategorySection(String title, List<Map<String, dynamic>> jobs) {
            if (jobs.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0011C9),
                    ),
                  ),
                ),
                ...jobs.map((job) {
                  final isSelected = job['name'] == currentCategory;

                  return InkWell(
                    onTap: () {
                      // First pop the bottom sheet
                      Navigator.pop(context);
                      
                      // Then update the state after the sheet is closed
                      Future.microtask(() {
                        setState(() {
                          _categoryController.text = job['name'];
                        });
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0011C9).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0011C9)
                              : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: isSelected ? const Color(0xFF0011C9) : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              job['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                                color:
                                isSelected ? const Color(0xFF0011C9) : Colors.black,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Color(0xFF0011C9)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle at the top
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h),
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2B8E).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                
                // Title
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
                  child: Text(
                    'Select Job Category',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                
                // Search bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  child: TextField(
                    controller: searchController,
                    autofocus: false,
                    decoration: InputDecoration(
                      fillColor: Color(0xFFf6f5f8),
                      filled: true,
                      hintText: 'Search job categories...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onChanged: filterJobs,
                  ),
                ),
                
                // Categories list
                Expanded(
                  child: filteredJobs.isEmpty
                      ? Center(
                          child: Text(
                            'No matching jobs found',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          children: [
                            // Currently selected job (if any)
                            if (currentCategory.isNotEmpty)
                              buildCategorySection(
                                'Selected',
                                _allJobs
                                    .where((job) => job['name'] == currentCategory)
                                    .toList(),
                              ),

                            // General Jobs
                            buildCategorySection(
                              'General Jobs',
                              filteredJobs
                                  .where((job) => job['category'] == 'General')
                                  .toList(),
                            ),

                            // Industry groups
                            ..._getUniqueIndustries(filteredJobs).map((industry) {
                              return buildCategorySection(
                                industry,
                                filteredJobs
                                    .where((job) => job['category'] == industry)
                                    .toList(),
                              );
                            }),
                            
                            // Extra space at bottom
                            SizedBox(height: 24.h),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  ).then((_) {
    // Dispose of controller when sheet is closed
    searchController.dispose();
  });
}
// Separate method for building job category section inside the bottom sheet
Widget _buildJobCategorySectionForBottomSheet({
  required BuildContext context,
  required String title,
  required List<Map<String, dynamic>> jobs,
  required String currentCategory,
}) {
  if (jobs.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0011C9),
          ),
        ),
      ),
      ...jobs.map((job) {
        final isSelected = job['name'] == currentCategory;

        return InkWell(
          onTap: () {
            // Use setState from the parent widget
            setState(() {
              _categoryController.text = job['name'];
            });
            // Close bottom sheet
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0011C9).withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0011C9)
                    : Colors.grey.shade300,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.work_outline,
                  color: isSelected ? const Color(0xFF0011C9) : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    job['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isSelected ? const Color(0xFF0011C9) : Colors.black,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Color(0xFF0011C9)),
              ],
            ),
          ),
        );
      }).toList(),
    ],
  );
}

  List<String> _getUniqueIndustries(List<Map<String, dynamic>> jobs) {
    final Set<String> industries = {};

    for (var job in jobs) {
      if (job['category'] != 'General') {
        industries.add(job['category'] as String);
      }
    }

    return industries.toList()..sort();
  }

  Widget _buildJobCategorySection({
    required String title,
    required List<Map<String, dynamic>> jobs,
    required String currentCategory,
  }) {
    if (jobs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0011C9),
            ),
          ),
        ),
        ...jobs.map((job) {
          final isSelected = job['name'] == currentCategory;

          return InkWell(
            onTap: () {
              setState(() {
                _categoryController.text = job['name'];
              });
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0011C9).withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0011C9)
                      : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    color: isSelected ? const Color(0xFF0011C9) : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      job['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color:
                            isSelected ? const Color(0xFF0011C9) : Colors.black,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Color(0xFF0011C9)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // Modified submit form method to save data to Firebase
  Future<void> _submitForm() async {
    // Validate form
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Validate date and time
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both date and time'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Validate category
    if (_categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a job category'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Create job data object
      final Map<String, dynamic> jobData = {
        'jobCategory': _categoryController.text,
        'description': _descriptionController.text,
        'date': _selectedDate,
        'time': _selectedTime,
        'jobType': _jobType,
      };

      // Add budget or salary range based on job type
      if (_isFullTime) {
        final minSalary = int.parse(_minSalaryController.text);
        final maxSalary = int.parse(_maxSalaryController.text);

        // Additional validation for salary range
        if (minSalary < _minimumBudget) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Minimum salary must be at least ₹$_minimumBudget'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        jobData['salaryRange'] = {
          'min': minSalary,
          'max': maxSalary,
        };
        // For consistency when displaying in JobsPostedScreen
        jobData['budget'] = maxSalary;
      } else {
        final budget = int.parse(_budgetController.text);

        // Additional validation for budget
        if (budget < _minimumBudget) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Budget must be at least ₹$_minimumBudget'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        jobData['budget'] = budget;
      }

      // Save to Firebase using the service
      final result = await _jobService.saveJobData(
        jobData: jobData,
        context: context,
        isEditing: widget.isEditing,
        jobId: widget.jobId,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        // Display success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Job updated successfully!'
                  : 'Job posted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Handle submit based on mode (create or edit)
        if (widget.isEditing) {
          // Return the updated job data to the previous screen
          Navigator.pop(context, result['jobData']);
        } else {
          // Navigate to JobsPostedScreen with the new job
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                JobManagementScreen(),
            ),
          );
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result['error']}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

