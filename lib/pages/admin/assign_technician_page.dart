import 'package:bcp_app/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcp_app/pages/image_viewer_page.dart';
import 'package:intl/intl.dart';

class AssignTechnicianPage extends StatefulWidget {
  final QueryDocumentSnapshot request;

  const AssignTechnicianPage({
    super.key,
    required this.request,
  });

  @override
  State<AssignTechnicianPage> createState() => _AssignTechnicianPageState();
}

class _AssignTechnicianPageState extends State<AssignTechnicianPage> {
  bool isLoading = false;
  String? selectedTechnician;
  String? selectedImportance;
  DateTime? dueDate;
  List<DocumentSnapshot> availableTechnicians = [];

  @override
  void initState() {
    super.initState();
    fetchAvaialbleTechnicians();
  }

  Future<void> fetchAvaialbleTechnicians() async {

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('MaintenanceStaff')
          .where('Availability', isEqualTo: 'Yes')
          .get();

      setState(() {
        availableTechnicians = querySnapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching technicians: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[900],
            ),
          ),
        ),
        ...children,
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red[900], size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownMenu({
    required String? value,
    required String hint,
    required List<DocumentSnapshot> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((DocumentSnapshot doc) {
          return DropdownMenuItem<String>(
            value: doc.id,
            child: Text(doc['Name'] as String),
          );
        }).toList(),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.red[900]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.red[900]!),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildImportanceDropdownMenu({
    required String? value,
    required String hint,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.red[900]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.red[900]!),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.calendar_today, color: Colors.red[900]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            dueDate == null
                ? 'Select Due Date'
                : DateFormat('yyyy-MM-dd').format(dueDate!),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != dueDate) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  Future<void> assignTechnician() async {
    if (selectedTechnician == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a technician')),
      );
      return;
    }

    if (selectedImportance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select importance')),
      );
      return;
    }

    if (dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get the document reference for the request
      DocumentReference requestRef = widget.request.reference;

      // Get the document reference for the selected technician
      DocumentReference technicianRef = FirebaseFirestore.instance
          .collection('MaintenanceStaff')
          .doc(selectedTechnician);

      // Start a batch write
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Update the request document
      batch.update(requestRef, {
        'Assigned To': selectedTechnician,
        'Due Date': dueDate,
        'Importance': selectedImportance,
        'Status': 'Assigned',
      });

      // Update the technician's availability
      batch.update(technicianRef, {'Availability': 'No'});

      // Commit the batch
      await batch.commit();

      // Show a success message alert dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Technician assigned successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

    } catch (e) {
      print('Error updating request and technician availability: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to assign technician. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var reporterName = widget.request['Reporter Name'];
    var roomNo = widget.request['Room No'] ?? 'Unknown';
    var equipment = widget.request['Equipment'] ?? 'Unknown';
    var issues = widget.request['Issues'] ?? 'No issues provided';
    var imageUrl = widget.request['Image URL'] ?? '';
    var remarks = widget.request['Remarks'] ?? '';

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.red[900],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Assign Technician',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoSection(
                    'Request Details',
                    [
                      _buildInfoItem('Reporter', reporterName, Icons.person),
                      _buildInfoItem('Room', roomNo, Icons.room),
                      _buildInfoItem('Equipment', equipment, Icons.build),
                      _buildInfoItem('Issues', issues, Icons.error),
                      if (remarks.isNotEmpty)
                        _buildInfoItem('Remarks', remarks, Icons.comment),
                      if (imageUrl.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewerPage(
                                  imageUrl: imageUrl,
                                ),
                              ),
                            );
                          },
                          child: _buildInfoItem(
                              'Image', 'Tap to view', Icons.image),
                        ),
                    ],
                  ),
                  Divider(),
                  _buildInfoSection(
                    'Assignment Details',
                    [
                      _buildDropdownMenu(
                        value: selectedTechnician,
                        hint: 'Select a Technician',
                        items: availableTechnicians,
                        icon: Icons.person,
                        onChanged: (value) {
                          setState(() {
                            selectedTechnician = value;
                          });
                        },
                      ),
                      _buildImportanceDropdownMenu(
                        value: selectedImportance,
                        hint: 'Select Importance',
                        items: ['High', 'Medium', 'Low'],
                        icon: Icons.priority_high,
                        onChanged: (value) {
                          setState(() {
                            selectedImportance = value;
                          });
                        },
                      ),
                      _buildDatePicker(),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (isLoading)
                    Container(
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(191, 0, 7, 100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                  if (!isLoading)
                    MyButton(
                      onTap: assignTechnician,
                      buttonText: 'Assign Technician',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
