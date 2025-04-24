
import 'package:flutter/material.dart';
import 'package:hey_work/presentation/worker_section/home_page/job_modal.dart';

class JobCategory {
  final String id;
  final String name;
  final String iconPath;
  final bool isSelected;

  JobCategory({
    required this.id,
    required this.name,
    required this.iconPath,
    this.isSelected = false,
  });
}

class JobProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobCategory> _categories = [];
  String _selectedCategory = 'All Works';
  bool _isLoading = false;

  List<JobModel> get jobs => _jobs;
  List<JobCategory> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  void setJobs(List<JobModel> jobs) {
    _jobs = jobs;
    notifyListeners();
  }

  void setCategories(List<JobCategory> categories) {
    _categories = categories;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}