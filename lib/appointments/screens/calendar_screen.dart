import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/appointments_service.dart';
import '../models/appointment.dart';
import '../widgets/appointment_card.dart';
import '../screens/new_booking_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final AppointmentsService _appointmentsService = AppointmentsService();
  Map<DateTime, List<Appointment>> _appointments = {};

  final List<Map<String, String>> _artistsData = [
    {'name': 'Toți artiștii', 'email': ''},
    {'name': 'Alecs Craciun', 'email': 'osuta1dfsex@gmail.com'},
    {'name': 'Denis Mihali', 'email': 'denismyhali@gmail.com'},
    {'name': 'Blanca Sardaru', 'email': 'blancasardaru28@yahoo.com'}
  ];

  String _selectedArtist = 'Toți artiștii';
  List<String> get _artists => _artistsData.map((artist) => artist['name']!).toList();

  String _getArtistEmail(String name) {
    return _artistsData.firstWhere(
      (artist) => artist['name'] == name,
      orElse: () => {'name': '', 'email': ''},
    )['email']!;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeNotifications();
    _loadAppointments();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _appointmentsService.initializeNotifications();
    } catch (e) {
      print("DEBUG: Eroare inițializare notificări: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la inițializarea notificărilor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0, 23, 59, 59);
      
      final artistEmail = _selectedArtist == 'Toți artiștii' 
          ? null 
          : _getArtistEmail(_selectedArtist);

      await _appointmentsService
          .getMonthAppointments(
            startOfMonth,
            endOfMonth,
            artistId: artistEmail,
          )
          .listen(
            (appointments) {
              if (mounted) {
                setState(() {
                  _appointments = {};
                  for (var appointment in appointments.entries) {
                    final date = DateTime.utc(
                      appointment.key.year,
                      appointment.key.month,
                      appointment.key.day,
                    );
                    _appointments[date] = appointment.value;
                  }
                });
              }
            },
            onError: (error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Eroare la încărcarea programărilor: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare neașteptată: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getArtistColor(String artistId) {
    if (artistId.toLowerCase().contains('alecs')) return Colors.blue;
    if (artistId.toLowerCase().contains('denis')) return Colors.green;
    if (artistId.toLowerCase().contains('blanca')) return Colors.pink;
    return Colors.grey;
  }

  Widget _buildAppointmentIndicator(List<Appointment> dayAppointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: dayAppointments.map((appointment) {
        String artistName = '';
        if (appointment.artistId.toLowerCase().contains('alecs')) {
          artistName = 'Alecs';
        } else if (appointment.artistId.toLowerCase().contains('denis')) {
          artistName = 'Denis';
        } else if (appointment.artistId.toLowerCase().contains('blanca')) {
          artistName = 'Blanca';
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _getArtistColor(appointment.artistId).withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getArtistColor(appointment.artistId).withOpacity(0.3),
            ),
          ),
          child: Text(
            '${appointment.time} - $artistName',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewBookingScreen()),
          ).then((_) => _loadAppointments()),
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.blue.withOpacity(0.3),
        ),
        body: GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
          child: Column(
            children: [
              _buildArtistSelector(),
              Expanded(child: _buildCalendarContainer()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtistSelector() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      borderRadius: 20,
      blur: 10,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.person_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: _selectedArtist,
                isExpanded: true,
                dropdownColor: const Color(0xFF2d2d2d),
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                items: _artists.map((String artist) {
                  return DropdownMenuItem<String>(
                    value: artist,
                    child: Text(artist),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedArtist = newValue;
                      _loadAppointments();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildCalendarContainer() {
    return GlassmorphicContainer(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      height: double.infinity,
      borderRadius: 15,
      blur: 10,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: SingleChildScrollView(
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          daysOfWeekHeight: 40,
          rowHeight: 120,
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
            _loadAppointments();
          },
          calendarStyle: _calendarStyle,
          headerStyle: _headerStyle,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final utcDate = DateTime.utc(date.year, date.month, date.day);
              final appointments = _appointments[utcDate] ?? [];
              if (appointments.isEmpty) return null;
              return _buildAppointmentIndicator(appointments);
            },
            defaultBuilder: (context, day, focusedDay) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    final utcDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
    final appointments = _appointments[utcDay] ?? [];
    if (appointments.isNotEmpty) {
      _showAppointmentDetails(appointments);
    }
  }

  CalendarStyle get _calendarStyle => CalendarStyle(
    cellMargin: const EdgeInsets.all(4),
    cellPadding: const EdgeInsets.all(4),
    defaultTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
    weekendTextStyle: const TextStyle(color: Colors.white70, fontSize: 16),
    selectedDecoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.blue.withOpacity(0.4), width: 1.0),
    ),
    todayDecoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
    ),
    outsideTextStyle: const TextStyle(color: Colors.white38, fontSize: 16),
  );

  HeaderStyle get _headerStyle => HeaderStyle(
    formatButtonVisible: true,
    titleCentered: true,
    formatButtonDecoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.0),
    ),
    formatButtonTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
    leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
    rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
  );

  void _showAppointmentDetails(List<Appointment> appointments) {
    showDialog(
      context: context,
      builder: (BuildContext context) => GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Programări ${appointments.first.date.day}/${appointments.first.date.month}/${appointments.first.date.year}',
              style: const TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
                            return GestureDetector(
                onTap: () => _showAppointmentFullDetails(appointment),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _getArtistColor(appointment.artistId).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getArtistColor(appointment.artistId).withOpacity(0.2),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      appointment.clientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${appointment.time} - ${appointment.formattedDuration}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAppointmentFullDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) => GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Detalii Programare',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  _editAppointment(appointment);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  _deleteAppointment(appointment);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Client:', appointment.clientName),
                _detailRow('Telefon:', appointment.clientPhone),
                _detailRow('Email:', appointment.clientEmail),
                _detailRow('Data:', '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}'),
                _detailRow('Ora:', appointment.time),
                _detailRow('Durată:', appointment.formattedDuration),
                _detailRow('Tip Tatuaj:', appointment.tattooTitle),
                _detailRow('Preț:', '${appointment.price} RON'),
                _detailRow('Avans:', '${appointment.advance} RON'),
                _detailRow('Locație:', appointment.location),
                if (appointment.notes.isNotEmpty)
                  _detailRow('Observații:', appointment.notes),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editAppointment(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewBookingScreen(appointment: appointment),
      ),
    ).then((_) => _loadAppointments());
  }

  void _deleteAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        title: const Text('Confirmare', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Sigur dorești să ștergi această programare?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _appointmentsService.cancelAppointment(
                  appointment.id,
                  'Șters de administrator',
                );
                Navigator.pop(context);
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Programare ștearsă cu succes'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _loadAppointments();
              } catch (e) {
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Eroare la ștergerea programării: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Șterge',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

