import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_motorcycle_redesign/admin/add_edit_motorcycle_screen.dart';
import 'package:moon_motorcycle_redesign/models/motorcycle.dart';

class MotorcycleManagementScreen extends StatelessWidget {
  const MotorcycleManagementScreen({super.key});

  Future<void> _deleteMotorcycle(BuildContext context, String id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this motorcycle?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                FirebaseFirestore.instance.collection('motorcycles').doc(id).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Motorcycle Management', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddEditMotorcycleScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('motorcycles').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading motorcycles'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No motorcycles found. Add one to get started.'));
          }

          final motorcycles = snapshot.data!.docs
              .map((doc) => Motorcycle.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: motorcycles.length,
            itemBuilder: (context, index) {
              final motorcycle = motorcycles[index];
              return ListTile(
                leading: Image.network(motorcycle.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(motorcycle.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text('\$${motorcycle.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddEditMotorcycleScreen(motorcycle: motorcycle),
                        ));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMotorcycle(context, motorcycle.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
