import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hey_work/main.dart';
import 'package:hey_work/presentation/hirer_section/common/floating_action_button.dart';
import 'package:hey_work/presentation/hirer_section/settings_screen/settings_page.dart';
import 'package:hey_work/presentation/hirer_section/widgets/category_chips.dart';
import 'package:hey_work/presentation/hirer_section/widgets/job_catogory.dart';

//! S E A R C H  B A R  W I D G E T
class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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

//! M A I N  H O M E  P A G E
class HeyWorkHomePage extends StatelessWidget {
  const HeyWorkHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final searchBarPadding = screenWidth * 0.03;

    return Scaffold(
      //! A P P - B A R
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
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
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SettingsScreen()));
            },
          ),
        ],
      ),

      //! B O D Y
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) => false,
        child: Stack(
          children: [
            //! S C R O L L A B L E  C O N T E N T
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: 70.h), // Space for search bar
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      //! J O B  C A T E G O R I E S
                      JobCategoriesSection(),

                      SizedBox(height: 24.h),

                      //! C A T E G O R Y  H E A D E R
                      CategoriesHeader(),

                      SizedBox(height: 16.h),

                      //! C A T E G O R Y  C H I P S
                      const CategoryChips(),

                      SizedBox(height: 16.h),
                      const CategoryChips(),

                      SizedBox(height: 72.h), // Space for FAB
                    ]),
                  ),
                ),
              ],
            ),

            //! F L O A T I N G  S E A R C H  B A R
            Positioned(
              top: 0,
              left: searchBarPadding,
              right: searchBarPadding,
              child: Material(
                color: Colors.transparent,
                elevation: 0,
                child: SearchBar(),
              ),
            ),
          ],
        ),
      ),

      //! F L O A T I N G  A C T I O N  B U T T O N
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const FloatingNewButton(),
    );
  }
}
