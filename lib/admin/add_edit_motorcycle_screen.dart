import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moon_motorcycle_redesign/models/motorcycle.dart';

class AddEditMotorcycleScreen extends StatefulWidget {
  final Motorcycle? motorcycle;

  const AddEditMotorcycleScreen({super.key, this.motorcycle});

  @override
  State<AddEditMotorcycleScreen> createState() => _AddEditMotorcycleScreenState();
}

class _AddEditMotorcycleScreenState extends State<AddEditMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _engineController = TextEditingController();
  final _powerController = TextEditingController();
  final _torqueController = TextEditingController();
  XFile? _image;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.motorcycle != null) {
      _nameController.text = widget.motorcycle!.name;
      _descriptionController.text = widget.motorcycle!.description;
      _priceController.text = widget.motorcycle!.price.toString();
      _engineController.text = widget.motorcycle!.engine;
      _powerController.text = widget.motorcycle!.power;
      _torqueController.text = widget.motorcycle!.torque;
      _imageUrl = widget.motorcycle!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _saveMotorcycle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      String imageUrl = _imageUrl ?? '';

      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('motorcycle_images')
            .child(DateTime.now().toIso8601String());
        final uploadTask = await ref.putFile(File(_image!.path));
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      final motorcycleData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'imageUrl': imageUrl,
        'engine': _engineController.text,
        'power': _powerController.text,
        'torque': _torqueController.text,
      };

      if (widget.motorcycle != null) {
        await FirebaseFirestore.instance.collection('motorcycles').doc(widget.motorcycle!.id).update(motorcycleData);
      } else {
        await FirebaseFirestore.instance.collection('motorcycles').add(motorcycleData);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.motorcycle == null ? 'Add Motorcycle' : 'Edit Motorcycle',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    image: _image != null
                        ? DecorationImage(image: FileImage(File(_image!.path)), fit: BoxFit.cover)
                        : (_imageUrl != null && _imageUrl!.isNotEmpty
                            ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                            : null),
                  ),
                  child: _image == null && (_imageUrl == null || _imageUrl!.isEmpty)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              Text('Upload Image', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(label: 'Name', controller: _nameController, validator: (value) => value!.isEmpty ? 'Please enter a name' : null),
              const SizedBox(height: 20),
              _buildTextField(label: 'Description', controller: _descriptionController, validator: (value) => value!.isEmpty ? 'Please enter a description' : null, maxLines: 4),
              const SizedBox(height: 20),
              _buildTextField(label: 'Price per day', controller: _priceController, validator: (value) => value!.isEmpty ? 'Please enter a price' : null, keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              _buildTextField(label: 'Engine (e.g., 1250cc)', controller: _engineController),
              const SizedBox(height: 20),
               _buildTextField(label: 'Power (e.g., 136 hp)', controller: _powerController),
              const SizedBox(height: 20),
               _buildTextField(label: 'Torque (e.g., 143 Nm)', controller: _torqueController),
              const SizedBox(height: 40),
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveMotorcycle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          widget.motorcycle == null ? 'Add Motorcycle' : 'Save Changes',
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }
}
