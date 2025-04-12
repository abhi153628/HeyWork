import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/presentation/hirer_section/jobs_posted/jobs_posted.dart';
import 'package:intl/intl.dart';

// Main JobDetailsScreen that handles the form
class JobDetailsScreen extends StatefulWidget {
  final String jobCategory;
  final String jobType; // 'part-time' or 'full-time'
  final Map<String, dynamic>? existingJob; // For editing existing jobs
  final bool isEditing; // Flag to indicate if we're editing

  const JobDetailsScreen({
    Key? key,
    required this.jobCategory,
    required this.jobType,
    this.existingJob,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _jobCategoryController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  // State variables
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _jobType = 'part-time'; // Default
  bool _isFormValid = false;

  // Minimum budget amount
  final int _minimumBudget = 400;

  // Scroll controller for keyboard adjustments
  final ScrollController _scrollController = ScrollController();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // If editing, populate fields with existing job data
    if (widget.isEditing && widget.existingJob != null) {
      final job = widget.existingJob!;
      _jobCategoryController.text = job['jobCategory'] ?? '';
      _jobDescriptionController.text = job['jobDescription'] ?? '';
      if (job['date'] != null) {
        _selectedDate = job['date'] as DateTime;
      }
      if (job['time'] != null) {
        _selectedTime = job['time'] as TimeOfDay;
      }
      _budgetController.text = (job['budget'] ?? _minimumBudget).toString();
      _jobType = job['jobType'] ?? 'part-time';
    } else {
      // Set initial values from parameters
      _jobCategoryController.text = widget.jobCategory;
      _jobType = widget.jobType;

      // Initialize budget with minimum value
      _budgetController.text = _minimumBudget.toString();
    }

    // Add listeners to controllers to validate form
    _jobCategoryController.addListener(_validateForm);
    _jobDescriptionController.addListener(_validateForm);
    _budgetController.addListener(_validateForm);

    // Add focus listener to scroll to description field when focused
    _descriptionFocusNode.addListener(() {
      if (_descriptionFocusNode.hasFocus) {
        // Add a slight delay to ensure the keyboard is fully visible
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              150.h, // Scroll to position that ensures the field is visible
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });

    // Initial validation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateForm();
    });
  }

  @override
  void dispose() {
    _jobCategoryController.dispose();
    _jobDescriptionController.dispose();
    _budgetController.dispose();
    _scrollController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  // Validate the entire form
  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ??
          false &&
              _selectedDate != null &&
              _selectedTime != null &&
              _jobCategoryController.text.isNotEmpty &&
              _jobDescriptionController.text.isNotEmpty &&
              (int.tryParse(_budgetController.text) ?? 0) >= _minimumBudget;
    });
  }

  // Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _validateForm();
      });
    }
  }

  // Time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0011C9),
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: const Color(0xFF0011C9),
              hourMinuteTextColor: const Color.fromARGB(255, 126, 126, 127),
              dayPeriodTextColor: const Color.fromARGB(255, 126, 126, 127),
              dayPeriodColor:
                  const Color(0xFF0011C9), // Set AM/PM background color here
              dialBackgroundColor: Colors.grey.shade200,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _validateForm();
      });
    }
  }

  // Show job category search dialog
  void _showJobCategorySearch() async {
    // This would typically be fetched from a backend
    final List<String> allCategories = [
      'Cleaning help',
      'Driver',
      'Quick Transport',
      'Gardener',
      'Pet Care',
      'Laptop Repair',
      'Printing Helper',
      'Delivery',
      'Warehouse Assistant',
      'Mechanic',
      'Shop Assistant',
      'Electrician',
    ];

    final String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder: (BuildContext context) {
        TextEditingController searchController = TextEditingController();
        List<String> filteredCategories = List.from(allCategories);

        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              // Adjust for keyboard
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2B8E).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    'Select Job Category',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Search box
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search job categories',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredCategories = allCategories
                            .where((category) => category
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Category list
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            filteredCategories[index],
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context, filteredCategories[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );

    if (result != null) {
      setState(() {
        _jobCategoryController.text = result;
        _validateForm();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Used to handle keyboard visibility
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      // Close keyboard when tapping outside
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        // Resize when keyboard appears
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ListView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  // Header with back button
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    widget.isEditing ? 'Edit Job Details' : 'Enter Job Details',
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Job Category Field
                  _buildJobCategoryField(),
                  SizedBox(height: 20.h),

                  // Job Description
                  _buildJobDescriptionSection(),
                  SizedBox(height: 20.h),

                  // Date & Time Section
                  _buildDateTimeSection(),
                  SizedBox(height: 20.h),

                  // Budget Section
                  _buildBudgetSection(),
                  SizedBox(height: 20.h),

                  // Job Type Section
                  _buildJobTypeSection(),

                  // Add enough space at the bottom to ensure form is visible when keyboard is open
                  SizedBox(height: 5.h + (bottomPadding > 0 ? 0 : 10.h)),

                  // Action Buttons
                  _buildActionButtons(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Job Category Field
  Widget _buildJobCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Category',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _showJobCategorySearch,
          child: AbsorbPointer(
            child: TextFormField(
              controller: _jobCategoryController,
              decoration: InputDecoration(
                hintText: 'Select Job Category',
                suffixIcon: Icon(Icons.search, size: 22.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF0011C9)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                isDense: true,
              ),
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a job category';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  // Job Description Section
  Widget _buildJobDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Description',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: TextFormField(
            controller: _jobDescriptionController,
            focusNode: _descriptionFocusNode,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Explain the job details',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter job description';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // Date & Time Section
  Widget _buildDateTimeSection() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final String dateText = _selectedDate != null
        ? dateFormat.format(_selectedDate!)
        : 'Select Date';

    final String timeText =
        _selectedTime != null ? _selectedTime!.format(context) : 'Select Time';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select date & time of service',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            // Date Selector
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  height: 56.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5FA),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateText,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: _selectedDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 20.sp,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Time Selector
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  height: 56.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5FA),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          timeText,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: _selectedTime != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.access_time,
                        size: 20.sp,
                        color: Colors.black,
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

  // Budget Section
  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Budget for the Job',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Text(
                  '₹',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: 'e.g., 500',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter budget';
                    }

                    final int? budget = int.tryParse(value);
                    if (budget == null) {
                      return 'Please enter a valid amount';
                    }

                    if (budget < _minimumBudget) {
                      return 'Minimum budget is ₹$_minimumBudget';
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Minimum budget is ₹$_minimumBudget',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Job Type Section
  Widget _buildJobTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Job Type',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _jobType,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _jobType = newValue;
                    _validateForm();
                  });
                }
              },
              items: <String>['part-time', 'full-time']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value == 'part-time' ? 'Part-time' : 'Full-time',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              minimumSize: Size(double.infinity, 56.h),
            ),
            child: Text(
              'CANCEL',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Submit Button
        Expanded(
          child: ElevatedButton(
            onPressed: _isFormValid
                ? () {
                    if (_formKey.currentState!.validate()) {
                      // Hide keyboard
                      FocusScope.of(context).unfocus();

                      // Process form data
                      final jobData = {
                        'jobCategory': _jobCategoryController.text,
                        'jobDescription': _jobDescriptionController.text,
                        'date': _selectedDate,
                        'time': _selectedTime,
                        'budget': int.parse(_budgetController.text),
                        'jobType': _jobType,
                      };

                      if (widget.isEditing) {
                        // If editing, return to previous screen with updated data
                        Navigator.pop(context, jobData);
                      } else {
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Job posted successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // Navigate to JobsPostedScreen with the new job data
                     Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (context) => JobsPostedScreen(
      submittedJob: jobData,
    ),
  ),
  (route) => false, // Removes all previous routes
);

                      }
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0011C9), // Deep blue
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF0011C9).withOpacity(0.5),
              disabledForegroundColor: Colors.white.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              minimumSize: Size(double.infinity, 56.h),
            ),
            child: Text(
              widget.isEditing ? 'UPDATE' : 'SUBMIT',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
