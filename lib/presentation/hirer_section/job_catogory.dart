import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:icons_plus/icons_plus.dart'; 

// This class helps map industry types to their specific job categories
class JobCategoryManager {
  // Mapping of industry types to their job categories with icons
  static final Map<String, List<JobCategoryInfo>> industryToJobCategories = {
    'Restaurants & Food Services': [
      JobCategoryInfo(title: 'Waiter', icon: Icons.restaurant),
      JobCategoryInfo(title: 'Cook\nAssistant', icon: Icons.outdoor_grill),
      JobCategoryInfo(title: 'Dishwasher', icon: Icons.wash),
      JobCategoryInfo(title: 'Food\nServer', icon: Icons.room_service),
    ],
    'Hospitality & Hotels': [
      JobCategoryInfo(title: 'Housekeeper', icon: Icons.cleaning_services),
      JobCategoryInfo(title: 'Room\nBoy', icon: Icons.hotel),
      JobCategoryInfo(title: 'Bellboy', icon: Icons.luggage),
      JobCategoryInfo(title: 'Front Desk', icon: Icons.desk),
    ],
    'Warehouse & Logistics': [
      JobCategoryInfo(title: 'Inventory\nAssistant', icon: Icons.inventory_2),
      JobCategoryInfo(title: 'Forklift\nOperator', icon: Icons.forklift),
      JobCategoryInfo(title: 'Loader', icon: Icons.upload),
      JobCategoryInfo(title: 'Unloader', icon: Icons.download),
    ],
    'Cleaning & Facility Services': [
      JobCategoryInfo(title: 'Janitor', icon: Icons.cleaning_services_outlined),
      JobCategoryInfo(title: 'Restroom\nAttendant', icon: Icons.wc),
      JobCategoryInfo(title: 'Trash\nCollector', icon: Icons.delete_outline),
      JobCategoryInfo(title: 'Cleaner', icon: Icons.brush),
    ],
    'Retail & Stores': [
      JobCategoryInfo(title: 'Sales\nAssistant', icon: Icons.point_of_sale),
      JobCategoryInfo(title: 'Stock Boy', icon: Icons.inventory),
      JobCategoryInfo(title: 'Shelf\nArranger', icon: Icons.shelves),
      JobCategoryInfo(title: 'Cashier', icon: Icons.attach_money),
    ],
    // Add other industry mappings following the same pattern
    'Packing & Moving Services': [
      JobCategoryInfo(title: 'Lifter', icon: Icons.fitness_center),
      JobCategoryInfo(title: 'Moving\nSupervisor', icon: Icons.directions),
      JobCategoryInfo(title: 'Unpacking\nStaff', icon: Icons.unarchive),
      JobCategoryInfo(title: 'Packer', icon: Icons.archive),
    ],
    'Event Management & Catering': [
      JobCategoryInfo(title: 'Event\nHelper', icon: Icons.event),
      JobCategoryInfo(title: 'Tent\nInstaller', icon: Icons.cabin),
      JobCategoryInfo(title: 'Food Counter', icon: Icons.fastfood),
      JobCategoryInfo(title: 'Setup Crew', icon: Icons.build),
    ],
    'Construction & Civil Work': [
      JobCategoryInfo(title: 'Mason', icon: Icons.domain),
      JobCategoryInfo(title: 'Electrician', icon: Icons.bolt),
      JobCategoryInfo(title: 'Plumber', icon: Icons.plumbing),
      JobCategoryInfo(title: 'Painter', icon: Icons.format_paint),
    ],
    'Transport & Delivery': [
      JobCategoryInfo(title: 'Bike\nCourier', icon: Icons.two_wheeler),
      JobCategoryInfo(title: 'Truck\nCleaner', icon: Icons.local_shipping),
      JobCategoryInfo(title: 'Assistant\nDriver', icon: Icons.drive_eta),
      JobCategoryInfo(title: 'Parcel\nSorter', icon: Icons.inventory_2),
    ],
  };

  // Common job categories that can be used as fallbacks
  static final List<JobCategoryInfo> commonJobCategories = [
    JobCategoryInfo(title: 'Cleaner', icon: Icons.cleaning_services),
    JobCategoryInfo(title: 'Helper', icon: Icons.help_outline),
    JobCategoryInfo(title: 'Delivery\nBoy', icon: Icons.delivery_dining),
    JobCategoryInfo(title: 'Receptionist', icon: Icons.support_agent),
    JobCategoryInfo(title: 'Packing\nStaff', icon: Icons.inventory),
    JobCategoryInfo(title: 'Security\nGuard', icon: Icons.security),
    JobCategoryInfo(title: 'Loader', icon: Icons.upload_file),
    JobCategoryInfo(title: 'Unloader', icon: Icons.download),
    JobCategoryInfo(title: 'Kitchen\nHelper', icon: Icons.kitchen),
    JobCategoryInfo(title: 'Maintenance', icon: Icons.handyman),
    JobCategoryInfo(title: 'Cashier', icon: Icons.point_of_sale),
    JobCategoryInfo(title: 'Office Boy', icon: Icons.work),
  ];

  // Get job categories for a specific industry, falling back to common categories if needed
  static List<JobCategoryInfo> getJobCategoriesForIndustry(String industry) {
    // If we have specific categories for this industry, use them
    if (industryToJobCategories.containsKey(industry)) {
      return industryToJobCategories[industry]!;
    }
    
    // Otherwise return common job categories as fallback
    return commonJobCategories;
  }
  
  // Fill categories to ensure we have at least 12 categories (for a 4x3 grid)
  static List<JobCategoryInfo> getFilledJobCategories(String industry) {
    List<JobCategoryInfo> categories = getJobCategoriesForIndustry(industry);
    
    // If we don't have enough categories, add from common categories
    if (categories.length < 12) {
      // Add unique common categories that aren't already in the list
      for (var commonCategory in commonJobCategories) {
        if (!categories.any((cat) => cat.title == commonCategory.title) && categories.length < 12) {
          categories.add(commonCategory);
        }
      }
    }
    
    return categories;
  }
}

// Model class for job category data
class JobCategoryInfo {
  final String title;
  final IconData icon;
  
  JobCategoryInfo({
    required this.title,
    required this.icon,
  });
}