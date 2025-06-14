import 'package:flutter/material.dart';
import 'package:heywork/core/theme/app_colors.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<String> _searchTexts = [
    'Search by category...',
    'Search by industry...',
    'Search by company name...',
    'Search by location...',
    'Search jobs...'
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentIndex = (_currentIndex + 1) % _searchTexts.length;
        _animationController.reset();
        _animationController.forward();
      }
    });
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.search, color: AppColors.darkGrey),
          ),
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0)
                  .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                  )),
                child: Text(
                  _searchTexts[_currentIndex],
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
          Spacer(),
          Container(
            height: 40,
            width: 40,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0000CC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.tune,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}