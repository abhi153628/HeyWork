import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'common/bottom_nav_bar.dart';
import 'home_page/hirer_home_page.dart';

class IndustrySelectionScreen extends StatefulWidget {
  const IndustrySelectionScreen({super.key});

  @override
  State<IndustrySelectionScreen> createState() =>
      _IndustrySelectionScreenState();
}

// Model class to avoid LateInitializationError
class IndustryData {
  String name;
  bool isSelected;

  IndustryData({required this.name, this.isSelected = false});
}

class _IndustrySelectionScreenState extends State<IndustrySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedIndustry = '';
  bool _isLoading = false; // Add a loading state variable

  final List<IndustryData> industryList = [
    IndustryData(name: 'Restaurants & Food Services'),
    IndustryData(name: 'Hospitality & Hotels'),
    IndustryData(name: 'Warehouse & Logistics'),
    IndustryData(name: 'Cleaning & Facility Services'),
    IndustryData(name: 'Retail & Stores'),
    IndustryData(name: 'Packing & Moving Services'),
    IndustryData(name: 'Event Management & Catering'),
    IndustryData(name: 'Construction & Civil Work'),
    IndustryData(name: 'Transport & Delivery'),
    IndustryData(name: 'Mechanic & Repair Services'),
    IndustryData(name: 'Home Services'),
    IndustryData(name: 'Pet Care Services'),
    IndustryData(name: 'Printing & Photocopy Services'),
    IndustryData(name: 'Salon & Beauty Services'),
    IndustryData(name: 'Educational Institutes & Coaching Centers'),
    IndustryData(name: 'Small Scale Manufacturing Units'),
    IndustryData(name: 'Courier & Logistics Companies'),
    IndustryData(name: 'IT Repair & Laptop Services'),
    IndustryData(name: 'Real Estate & Property Management'),
    IndustryData(name: 'Security Services'),
    IndustryData(name: 'Healthcare Support Services'),
    IndustryData(name: 'Textile & Garment Units'),
    IndustryData(name: 'Agriculture & Plantation'),
    IndustryData(name: 'Recycling & Waste Management'),
    IndustryData(name: 'Printing & Packaging'),
    IndustryData(name: 'Home Renovation & Painting'),
    IndustryData(name: 'Cold Storage & Food Processing'),
    IndustryData(name: 'Public Utility & Government Tenders'),
    IndustryData(name: 'Religious/Community Event Services'),
    IndustryData(name: 'Furniture & Carpentry Services'),
    IndustryData(name: 'Bakery & Confectionery Units'),
    IndustryData(name: 'Laundry & Dry Cleaning Services'),
    IndustryData(name: 'Mobile Repair Shops & Electronic Stores'),
    IndustryData(name: 'E-Waste Handling & Scrap Services'),
    IndustryData(name: 'ATM & Banking Support Vendors'),
    IndustryData(name: 'Field Survey & Campaign Work'),
    IndustryData(name: 'Local Government Schemes & Civic Work'),
    IndustryData(name: 'Photography & Videography Support'),
    IndustryData(name: 'Water Can & Gas Delivery Services'),
    IndustryData(name: 'Interior Design & Modular Furniture Setup'),
    IndustryData(name: 'Cultural Programs & Religious Functions'),
    IndustryData(name: 'Animal Shelters & Farms'),
    IndustryData(name: 'Fisheries & Marine Services'),
  ];

  List<IndustryData> filteredIndustries = [];

  @override
  void initState() {
    super.initState();
    // Initialize filteredIndustries with a copy of industryList to avoid reference issues
    filteredIndustries = List.from(industryList);
    selectedIndustry = '';
    _searchController.addListener(_filterIndustries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterIndustries() {
    if (_searchController.text.isEmpty) {
      setState(() {
        filteredIndustries = List.from(industryList);
      });
    } else {
      setState(() {
        filteredIndustries = industryList
            .where((industry) => industry.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    }
  }

  void _showIndustriesBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    //! H A N D L E
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    //! S E A R C H  F I E L D
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search industry type',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _filterIndustries();
                          });
                        },
                      ),
                    ),

                    //! L I S T  O F  I N D U S T R I E S
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filteredIndustries.length,
                        itemBuilder: (context, index) {
                          final industry = filteredIndustries[index];
                          return ListTile(
                            title: Text(
                              industry.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                for (var item in industryList) {
                                  item.isSelected = false;
                                }
                                industry.isSelected = true;
                                selectedIndustry = industry.name;
                              });
                              this.setState(() {
                                selectedIndustry = industry.name;
                              });
                              Navigator.pop(context);
                            },
                            trailing: industry.isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: const Color(0xFF0000CC),
                                    size: 24,
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _saveIndustryToFirebase() async {
    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && selectedIndustry.isNotEmpty) {
        Map<String, dynamic> userData = {
          'industry':
              selectedIndustry, // Changed from 'businessType' to 'industry'
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('hirers')
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));

        // Navigate to next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() {
          _isLoading = false; // Set loading state to false if validation fails
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an industry first'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Set loading state to false if error occurs
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              //! H E A D E R
              Text(
                'Choose your\nIndustry',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0000CC),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              //! S U B H E A D E R
              Text(
                'Choose the type of works you will be ready get hired for.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 24),

              //! S E A R C H  F I E L D
              GestureDetector(
                onTap: _showIndustriesBottomSheet,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      // Wrap with Expanded to prevent overflow
                      Expanded(
                        child: Text(
                          selectedIndustry.isNotEmpty
                              ? selectedIndustry
                              : 'Warehouse',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              //! S E L E C T E D  I N D U S T R Y
              if (selectedIndustry.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    selectedIndustry,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis, // Add overflow property
                    maxLines: 2, // Allow text to wrap to second line if needed
                  ),
                ),

              const Spacer(),

              //! C O N T I N U E  B U T T O N
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _saveIndustryToFirebase, // Disable button when loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading
                        ? Colors.grey[400]
                        : const Color(0xFF0000CC), // Change color when loading
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      // Show loading indicator when loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
