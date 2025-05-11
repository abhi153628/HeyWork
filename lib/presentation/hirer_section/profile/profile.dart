import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobPostingScreen extends StatelessWidget {
  const JobPostingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top curved red background with profile
          ProfileHeaderSection(),

          // Edit Profile Button
          EditProfileButton(),
        ],
      ),
    );
  }
}

class ProfileHeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 380.h,
      decoration: BoxDecoration(
        color: const Color(0xFFBB0000),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 115.w,
            top: 115.h,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFc4c4c4)),
            ),
          ),
          // Background design elements - slightly transparent shapes
          Positioned(
            left: -90.w,
            top: 140.h,
            child: Transform.rotate(
              angle: -0.99, // Rotate counter-clockwise (in radians)
              child: Container(
                height: 150.h,
                width: 150.w, // optional, if you want symmetry
                decoration: BoxDecoration(
                  color: Color(0xFFd74346),
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
          ),
          Positioned(
            right: -100.w,
            bottom: 165.h,
            child: Transform.rotate(
              angle: 0.5, // Rotate clockwise (in radians)
              child: Container(
                height: 150.h,
                width: 150.w,
                decoration: BoxDecoration(
                  color: Color(0xFFf10004),
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // Back button and menu
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 40.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 35.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.red,
                        size: 24.sp,
                      ),
                    ),
                    Text(
                      "Hirer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ],
                ),
              ),

              // Profile picture
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 3,
                      offset: Offset(-4, 1),
                      spreadRadius: 1)
                ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(70.r),
                  child: Image.asset(
                    'asset/heywork.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Business name with verification icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Red Chilies ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Owner name
              Text(
                "Ramesh Bineesh",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),

              SizedBox(height: 4.h),

              // Location
              Text(
                "Whitefield, Bengaluru Urban District",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            "Edit Your Profile",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class JobsPostedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            // Header with "View All" option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Jobs Posted",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Job Cards
            JobCard(
              title: "Hotel Waiter",
              company: "Red Chilies Hotel",
              location: "Whitefield, Bengaluru Urban District",
              salary: "600 per day",
              postedTime: "1 minutes ago",
            ),

            SizedBox(height: 16.h),

            JobCard(
              title: "Shawarma Cook",
              company: "Red Chilies Hotel",
              location: "Whitefield, Bengaluru Urban District",
              salary: "600 per day",
              postedTime: "1 minutes ago",
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String postedTime;

  const JobCard({
    Key? key,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.postedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Posted time
          Text(
            "Posted $postedTime",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 12.h),

          // Job title and company icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      company,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Location with icon
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18.sp,
                color: Colors.grey,
              ),
              SizedBox(width: 8.w),
              Text(
                location,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Salary with icon
          Row(
            children: [
              Icon(
                Icons.monetization_on_outlined,
                size: 18.sp,
                color: Colors.grey,
              ),
              SizedBox(width: 8.w),
              Text(
                salary,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
