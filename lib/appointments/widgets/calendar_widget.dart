import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/appointment.dart';
import '../services/appointments_service.dart';

class CalendarWidget extends StatefulWidget {
  final String? artistId;
  
  const CalendarWidget({
    Key? key,
    this.artistId,
  }) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final AppointmentsService _appointmentsService = AppointmentsService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Appointment>> _appointments = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAppointments();
  }

  void _loadAppointments() {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    _appointmentsService
        .getMonthAppointments(firstDay, lastDay, artistId: widget.artistId)
        .listen((monthAppointments) {
      if (mounted) {
        setState(() {
          _appointments = monthAppointments;
        });
      }
    });
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    return _appointments[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Appointment>(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2026, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            _loadAppointments();
          },
          eventLoader: _getAppointmentsForDay,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 4,
            markerSize: 8,
            markersAlignment: Alignment.bottomCenter,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
          ),
          availableCalendarFormats: const {
            CalendarFormat.month: 'Lună',
            CalendarFormat.twoWeeks: '2 Săptămâni',
            CalendarFormat.week: 'Săptămână'
          },
        ),
        const SizedBox(height: 16),
        if (_selectedDay != null) ...[
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: _appointmentsService.getAppointmentsForDate(
                _selectedDay!,
                artistId: widget.artistId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Eroare la încărcarea programărilor: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final appointments = snapshot.data!;
                
                if (appointments.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nu există programări pentru această zi',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          appointment.clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Ora: ${appointment.time}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Durată: ${appointment.formattedDuration}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Titlu: ${appointment.tattooTitle}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: appointment.status == 'confirmed'
                                ? Colors.green.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            appointment.status == 'confirmed'
                                ? 'Confirmată'
                                : 'În așteptare',
                            style: TextStyle(
                              color: appointment.status == 'confirmed'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          // TODO: Implementează editarea programării
                          print('Editare programare: ${appointment.id}');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
