import 'package:flutter/material.dart';
import 'db/db_helper.dart';

class Booking {
  final int? id;
  final String name;
  final String roomType;
  final String checkInDate;

  Booking(
      {this.id,
      required this.name,
      required this.roomType,
      required this.checkInDate});

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      name: map['name'],
      roomType: map['room_type'],
      checkInDate: map['check_in_date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'room_type': roomType,
      'check_in_date': checkInDate,
    };
  }
}

class BookingHotelPage extends StatefulWidget {
  @override
  _BookingHotelPageState createState() => _BookingHotelPageState();
}

class _BookingHotelPageState extends State<BookingHotelPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomTypeController = TextEditingController();
  final TextEditingController checkInDateController = TextEditingController();

  List<Booking> bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  void _fetchBookings() async {
    final data = await dbHelper.getBookings();
    setState(() {
      bookings = data.map((e) => Booking.fromMap(e)).toList();
    });
  }

  void _addBooking() async {
    if (nameController.text.isNotEmpty &&
        roomTypeController.text.isNotEmpty &&
        checkInDateController.text.isNotEmpty) {
      await dbHelper.insertBooking(Booking(
        name: nameController.text,
        roomType: roomTypeController.text,
        checkInDate: checkInDateController.text,
      ));
      nameController.clear();
      roomTypeController.clear();
      checkInDateController.clear();
      _fetchBookings();
    }
  }

  void _updateBooking(Booking booking) async {
    if (nameController.text.isNotEmpty &&
        roomTypeController.text.isNotEmpty &&
        checkInDateController.text.isNotEmpty) {
      await dbHelper.updateBooking(Booking(
        id: booking.id,
        name: nameController.text,
        roomType: roomTypeController.text,
        checkInDate: checkInDateController.text,
      ));
      nameController.clear();
      roomTypeController.clear();
      checkInDateController.clear();
      _fetchBookings();
    }
  }

  void _deleteBooking(int id) async {
    await dbHelper.deleteBooking(id);
    _fetchBookings();
  }

  void _showEditDialog(Booking booking) {
    nameController.text = booking.name;
    roomTypeController.text = booking.roomType;
    checkInDateController.text = booking.checkInDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: roomTypeController,
                decoration: InputDecoration(labelText: 'Room Type'),
              ),
              TextField(
                controller: checkInDateController,
                readOnly: true, // Read-only to trigger calendar pop-up
                decoration: InputDecoration(labelText: 'Check-in Date'),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateBooking(booking);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Earliest selectable date
      lastDate: DateTime(2100), // Latest selectable date
    );

    if (pickedDate != null) {
      setState(() {
        checkInDateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}"; // Format the date as YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Hotel Booking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: roomTypeController,
              decoration: InputDecoration(labelText: 'Room Type'),
            ),
            TextField(
              controller: checkInDateController,
              readOnly: true, // Read-only to trigger calendar pop-up
              decoration: InputDecoration(labelText: 'Check-in Date'),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                textStyle: TextStyle(color: Colors.white),
              ),
              child: Text(
                'Add Booking',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return ListTile(
                    title: Text(booking.name),
                    subtitle:
                        Text('${booking.roomType} - ${booking.checkInDate}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                          onPressed: () => _showEditDialog(booking),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteBooking(booking.id!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
