import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heywork/presentation/worker_section/worker_application_screen/jobs_service.dart';

import 'package:heywork/presentation/hirer_section/job_managment_screen/job_managment_screen.dart';
import 'package:lottie/lottie.dart';
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

  // Focus nodes for better focus management
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _budgetFocus = FocusNode();
  final FocusNode _minSalaryFocus = FocusNode();
  final FocusNode _maxSalaryFocus = FocusNode();

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
    // Unfocus any currently focused field and prevent re-focusing
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    
    setState(() {
      if (_isFullTime) {
        _jobType = 'part-time';
        _animationController.reverse();
      } else {
        _jobType = 'full-time';
        _animationController.forward();
      }
    });
    
    // Ensure focus stays dismissed after state change
    Future.delayed(const Duration(milliseconds: 50), () {
      FocusScope.of(context).unfocus();
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
    
    // Dispose focus nodes
    _descriptionFocus.dispose();
    _budgetFocus.dispose();
    _minSalaryFocus.dispose();
    _maxSalaryFocus.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //! A P P - B A R
      appBar: _buildAppBar(),
      //! B O D Y
      body: GestureDetector(
        // Dismiss keyboard when tapping outside - with proper behavior
        onTap: () {
          FocusScope.of(context).unfocus();
          // Ensure keyboard stays dismissed
          FocusManager.instance.primaryFocus?.unfocus();
        },
        behavior: HitTestBehavior.opaque, // Important: makes entire area tappable
        child: Stack(
          children: [
            _buildBody(),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
                  )
                ),
              ),
          ],
        ),
      ),
    );
  }

  //! A P P - B A R
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

  //! M A I N - B O D Y
  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          //! J O B - T Y P E - T O G G L E
          _buildJobTypeToggle(),
          SizedBox(height: 24.h),

          //! J O B - C A T E G O R Y
          _buildCategoryField(),
          SizedBox(height: 24.h),

          //! D E S C R I P T I O N - S E C T I O N
          _buildDescriptionSection(),
          SizedBox(height: 24.h),

          //! D A T E - T I M E - S E C T I O N
          _buildDateTimeSection(),
          SizedBox(height: 24.h),
        
          //! B U D G E T - S E C T I O N
          _buildBudgetSection(),
          SizedBox(height: 40.h),

          //! S U B M I T - B U T T O N
          _buildSubmitButton(),
          SizedBox(height: 24.h), // Bottom padding
        ],
      ),
    );
  }

  //! D E S C R I P T I O N - S E C T I O N
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
          child: Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        _buildDescriptionField(),
      ],
    );
  }

  //! D E S C R I P T I O N - F I E L D
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      focusNode: _descriptionFocus,
      maxLines: 3,
      textInputAction: TextInputAction.done,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        fillColor: const Color(0xFFf6f5f8),
        filled: true,
        hintText: 'Describe the job requirements',
        hintStyle: GoogleFonts.poppins(
          fontSize: 16.sp,
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF0011C9), width: 1.5),
        ),
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a job description';
        }
        return null;
      },
      onTap: () {
        // Ensure this field gets focus when tapped
        _descriptionFocus.requestFocus();
      },
    );
  }

  //! D A T E - T I M E - S E C T I O N
  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
          child: Text(
            'Select Date and Time',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Row(
          children: [
            // Date Picker
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf6f5f8),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade400),
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
                        color: Colors.grey.shade700,
                        size: 20.sp,
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
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf6f5f8),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade400),
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
                        color: Colors.grey.shade700,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  //! B U D G E T - S E C T I O N
  Widget _buildBudgetSection() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AnimatedCrossFade(
          firstChild: _buildBudgetField(),
          secondChild: _buildSalaryRangeFields(),
          crossFadeState: _isFullTime
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
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
    );
  }

  //! B U D G E T - F I E L D
  Widget _buildBudgetField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
          child: Text(
            'Budget (₹)',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          height: 60.h,
          child: TextFormField(
            controller: _budgetController,
            focusNode: _budgetFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              fillColor: const Color(0xFFf6f5f8),
              filled: true,
              hintText: 'Minimum ₹$_minimumBudget',
              hintStyle: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFF0011C9), width: 1.5),
              ),
              prefixIcon: Icon(
                Icons.currency_rupee,
                color: Colors.grey.shade700,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
        ),
      ],
    );
  }

  //! S A L A R Y - R A N G E - F I E L D S
  Widget _buildSalaryRangeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
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
                focusNode: _minSalaryFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  fillColor: const Color(0xFFf6f5f8),
                  filled: true,
                  labelText: 'From',
                  hintText: 'Min ₹$_minimumBudget',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFF0011C9), width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                ),
                onFieldSubmitted: (_) {
                  _maxSalaryFocus.requestFocus();
                },
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
                focusNode: _maxSalaryFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  fillColor: const Color(0xFFf6f5f8),
                  filled: true,
                  labelText: 'To',
                  hintText: 'Max',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFF0011C9), width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
    );
  }

  //! J O B - T Y P E - T O G G L E
  Widget _buildJobTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
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
                  borderRadius: BorderRadius.circular(8.r),
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
                  borderRadius: BorderRadius.circular(8.r),
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

  //! J O B - C A T E G O R Y
  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
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
          onTap: () {
            // Unfocus any active field before showing bottom sheet
            FocusScope.of(context).unfocus();
            _showJobCategoryBottomSheet();
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFf6f5f8),
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

  //! S U B M I T - B U T T O N
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

  //! D A T E - P I C K E R
  void _pickDate() async {
    // Dismiss keyboard and unfocus any active field
    FocusScope.of(context).unfocus();
    
    // Add a small delay to ensure focus is properly dismissed
    await Future.delayed(const Duration(milliseconds: 100));
    
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
      
      // Ensure no field gets focus after state update
      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(context).unfocus();
      });
    }
  }

  //! T I M E - P I C K E R
  void _pickTime() async {
    // Dismiss keyboard and unfocus any active field
    FocusScope.of(context).unfocus();
    
    // Add a small delay to ensure focus is properly dismissed
    await Future.delayed(const Duration(milliseconds: 100));
    
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
      
      // Ensure no field gets focus after state update
      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(context).unfocus();
      });
    }
  }

  //! J O B - C A T E G O R Y - B O T T O M S H E E T
  void _showJobCategoryBottomSheet() {
    // Unfocus any active field before showing bottom sheet and prevent re-focusing
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    
    // Add small delay to ensure focus is dismissed
    Future.delayed(const Duration(milliseconds: 100), () {
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
                            
                            // Ensure focus stays dismissed after category selection
                            Future.delayed(const Duration(milliseconds: 50), () {
                              FocusScope.of(context).unfocus();
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
                          fillColor: const Color(0xFFf6f5f8),
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
        // Dispose of controller when sheet is closed and ensure focus stays dismissed
        searchController.dispose();
        FocusScope.of(context).unfocus();
      });
    });
  }

  //! G E T - U N I Q U E - I N D U S T R I E S
  List<String> _getUniqueIndustries(List<Map<String, dynamic>> jobs) {
    final Set<String> industries = {};

    for (var job in jobs) {
      if (job['category'] != 'General') {
        industries.add(job['category'] as String);
      }
    }

    return industries.toList()..sort();
  }

  //! S U B M I T - F O R M
  Future<void> _submitForm() async {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();
    
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
              builder: (context) => JobManagementScreen(),
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