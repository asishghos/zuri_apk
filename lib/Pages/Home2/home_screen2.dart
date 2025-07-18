import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/image_display_model.dart';
import 'dart:developer' as Developer;
import 'dart:io';

// import 'package:testing2/services/DataSource/generate_image_api.dart';

class HomeScreen2 extends StatefulWidget {
  @override
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  File? _imageFile;
  String? _selectedClothingType;
  String? _selectedOccasion;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> clothingTypes = ['TopWear', 'BottomWear'];
  final List<String> occasions = [
    'Casual',
    'Formal',
    'Party',
    'Wedding',
    'Business',
    'Sports',
    'Beach',
    'Date Night',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera permission denied'),
              backgroundColor: Color(0xFF8D6E63),
            ),
          );
          return;
        }
      } else if (source == ImageSource.gallery) {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gallery permission denied'),
              backgroundColor: Color(0xFF8D6E63),
            ),
          );
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Color(0xFFCBA6A5)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFCBA6A5).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Color(0xFF8D6E63), fontSize: 16),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF5D4037)),
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_imageFile == null) {
      _showSnackBar('Please select an image', Color(0xFF8D6E63));
      return;
    }
    if (_selectedClothingType == null) {
      _showSnackBar('Please select clothing type', Color(0xFF8D6E63));
      return;
    }
    if (_selectedOccasion == null) {
      _showSnackBar('Please select occasion', Color(0xFF8D6E63));
      return;
    }
    Developer.log('Image: ${_imageFile!.path}');
    Developer.log('Clothing Type: $_selectedClothingType');
    Developer.log('Occasion: $_selectedOccasion');
    // Handle form submission here
    _showSnackBar('Form submitted successfully!', Color(0xFF5D4037));
    setState(() {
      _isLoading = true;
    });
    try {
      // final result = await ApiService3.generateImageService(
      //   _imageFile!,
      //   _selectedClothingType!,
      //   _selectedOccasion!,
      // );
      // ResultCache.resultData = result;
      // print(result);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("Error : $e", Colors.redAccent);
      Developer.log("Error on Image generated page: $e");
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSourceButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFF8BBB9),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFCBA6A5).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Color(0xFF5D4037)),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelectionSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 180,
          width: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(Icons.image_outlined, size: 80, color: Color(0xFF8D6E63)),
        ),
        SizedBox(height: 40),
        Text(
          'No image selected',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSourceButton(
              title: 'Camera',
              icon: Icons.camera_alt,
              onTap: () => _pickImage(ImageSource.camera),
            ),
            SizedBox(width: 20),
            _buildSourceButton(
              title: 'Gallery',
              icon: Icons.photo_library,
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedImageSection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFCBA6A5).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.file(_imageFile!, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 30),

          // Clothing Type Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Clothing Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
          SizedBox(height: 12),
          _buildDropdown(
            hint: 'Select clothing type',
            value: _selectedClothingType,
            items: clothingTypes,
            onChanged: (value) {
              setState(() {
                _selectedClothingType = value;
              });
            },
          ),

          SizedBox(height: 24),

          // Occasion Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Occasion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
          SizedBox(height: 12),
          _buildDropdown(
            hint: 'Select occasion',
            value: _selectedOccasion,
            items: occasions,
            onChanged: (value) {
              setState(() {
                _selectedOccasion = value;
              });
            },
          ),

          SizedBox(height: 40),

          // Submit Button
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30),
              backgroundColor: Color(0xFFF8BBB9),
              foregroundColor: Color(0xFF5D4037),
              elevation: 8,
              shadowColor: Color(0xFFCBA6A5).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 22),
                SizedBox(width: 10),
                Text(
                  'Submit Classification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          SizedBox(height: 15),

          TextButton.icon(
            onPressed: () {
              setState(() {
                _imageFile = null;
                _selectedClothingType = null;
                _selectedOccasion = null;
              });
            },
            icon: Icon(Icons.refresh, color: Color(0xFF8D6E63)),
            label: Text(
              'Choose Different Image',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8D6E63),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEEEED),
      appBar: AppBar(
        title: Text(
          'Clothing Classifier',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFFFEEEED),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF5D4037)),
      ),
      body: _isLoading
          ? LoadingPage()
          : Container(
              decoration: BoxDecoration(color: Color(0xFFFEEEED)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    if (_imageFile == null) ...[
                      SizedBox(height: 20),
                      Text(
                        'Choose Your Photo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Select an image and classify your clothing style',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                    Expanded(
                      child: Center(
                        child: _imageFile != null
                            ? _buildSelectedImageSection()
                            : _buildImageSelectionSection(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
