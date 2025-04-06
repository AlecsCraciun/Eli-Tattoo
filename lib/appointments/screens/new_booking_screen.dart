import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointments_service.dart';

class NewBookingScreen extends StatefulWidget {
  final Appointment? appointment;

  const NewBookingScreen({Key? key, this.appointment}) : super(key: key);

  @override
  _NewBookingScreenState createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppointmentsService _appointmentsService = AppointmentsService();
  
  late TextEditingController _clientNameController;
  late TextEditingController _clientEmailController;
  late TextEditingController _clientPhoneController;
  late TextEditingController _tattooTitleController;
  late TextEditingController _priceController;
  late TextEditingController _advanceController;
  late TextEditingController _notesController;
  
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '12:00';
  String _selectedArtist = 'Alecs Craciun';
  String _selectedLocation = 'Strada Republicii 25';
  int _selectedDuration = 120; // Valoare implicită 2 ore

  final List<String> _artists = ['Alecs Craciun', 'Denis Mihali', 'Blanca Sardaru'];
  final List<String> _locations = ['Strada Republicii 25', 'B-dul Nicolae Balcescu Nr.20'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final appointment = widget.appointment;
    _clientNameController = TextEditingController(text: appointment?.clientName ?? '');
    _clientEmailController = TextEditingController(text: appointment?.clientEmail ?? '');
    _clientPhoneController = TextEditingController(text: appointment?.clientPhone ?? '');
    _tattooTitleController = TextEditingController(text: appointment?.tattooTitle ?? '');
    _priceController = TextEditingController(text: appointment?.price.toString() ?? '');
    _advanceController = TextEditingController(text: appointment?.advance.toString() ?? '');
    _notesController = TextEditingController(text: appointment?.notes ?? '');

    if (appointment != null) {
      _selectedDate = appointment.date;
      _selectedTime = appointment.time;
      _selectedLocation = appointment.location;
      _selectedDuration = appointment.duration;
      _selectedArtist = appointment.artistId;
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _tattooTitleController.dispose();
    _priceController.dispose();
    _advanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF2d2d2d),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF2d2d2d),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      try {
        final appointment = Appointment(
          id: widget.appointment?.id ?? '',
          artistId: _selectedArtist,
          clientName: _clientNameController.text,
          clientEmail: _clientEmailController.text,
          clientPhone: _clientPhoneController.text,
          tattooTitle: _tattooTitleController.text,
          date: _selectedDate,
          time: _selectedTime,
          duration: _selectedDuration,
          price: double.parse(_priceController.text),
          advance: double.parse(_advanceController.text),
          location: _selectedLocation,
          notes: _notesController.text,
        );

        if (widget.appointment == null) {
          await _appointmentsService.createAppointment(appointment);
        } else {
          await _appointmentsService.updateAppointment(appointment);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Programare salvată cu succes!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Eroare la salvarea programării: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.appointment == null ? 'Programare Nouă' : 'Editare Programare',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDropdown(
                value: _selectedArtist,
                items: _artists,
                label: 'Artist',
                onChanged: (value) => setState(() => _selectedArtist = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedLocation,
                items: _locations,
                label: 'Locație',
                onChanged: (value) => setState(() => _selectedLocation = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _clientNameController,
                label: 'Nume Client',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Introduceți numele clientului' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _clientEmailController,
                label: 'Email Client',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Introduceți emailul clientului' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _clientPhoneController,
                label: 'Telefon Client',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Introduceți telefonul clientului' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _tattooTitleController,
                label: 'Descriere Tatuaj',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Introduceți descrierea tatuajului' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Preț (RON)',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Introduceți prețul' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _advanceController,
                      label: 'Avans (RON)',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Introduceți avansul' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDurationDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notesController,
                label: 'Note',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.appointment == null ? 'Creează Programare' : 'Actualizează Programare',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF2d2d2d),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDurationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedDuration,
        items: Appointment.availableDurations.map((int duration) {
          final hours = duration ~/ 60;
          return DropdownMenuItem<int>(
            value: duration,
            child: Text('$hours ore'),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedDuration = value!),
        decoration: const InputDecoration(
          labelText: 'Durată',
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF2d2d2d),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Data',
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ora',
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          _selectedTime,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
