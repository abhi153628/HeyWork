import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hey_work/main.dart';
import 'package:hey_work/presentation/hirer_section/common/floating_action_button.dart';
import 'package:hey_work/presentation/hirer_section/widgets/bottom_sheer.dart';
import 'package:hey_work/presentation/hirer_section/widgets/category_chips.dart';
import 'package:hey_work/presentation/hirer_section/widgets/job_catogory.dart';

class HeyWorkHomePage extends StatelessWidget {
  const HeyWorkHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get actual screen dimensions for perfect adaptation
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Adjust padding dynamically based on screen width
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width
    
    return Scaffold(
      // APP-BAR
      appBar: AppBar(
       title: Text(
    'heywork',
    style: Theme.of(context).textTheme.displayLarge?.copyWith(
      fontSize: 28.sp, 
      
    ),
  ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
              size: 28.sp,
            ),
            onPressed: () {},
          ),
        ],
      ),
      
      // BODY
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use constraints to ensure symmetry
          final maxWidth = constraints.maxWidth;
          
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEARCH BAR
                  SizedBox(height: 16.h),
                  SearchBar(),
                  
                  // JOB CATEGORIES SECTION
                  SizedBox(height: 20.h),
                  JobCategoriesSection(),
                  
                  // CATEGORIES SECTION
                  SizedBox(height: 24.h),
                  CategoriesHeader(),
                  
                  // CATEGORIES CHIP LIST
                  SizedBox(height: 16.h),
                  const CategoryChips(),
                  
                  // NEW BUTTON
                  SizedBox(height: 16.h),
                
                  
                  // Space for bottom navigation bar
                  SizedBox(height: 72.h),
                ],
              ),
            ),
          );
        },
        
      ),
       // FLOATING ACTION BUTTON: "New" button for creating new content
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const FloatingNewButton(),
    );
  }
}



class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Text(
            'Start a job search',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Icon(
            Icons.search,
            color: Colors.grey,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}