class EmailService {
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    // Implementare trimitere email folosind Firebase Cloud Functions
    // sau alt serviciu de email (SendGrid, etc.)
  }

  String _generateConfirmationEmailBody(Map<String, dynamic> appointmentData) {
    return '''
    Dragă ${appointmentData['clientName']},

    Îți confirmăm programarea la Eli Tattoo Studio:

    Data: ${appointmentData['date']}
    Ora: ${appointmentData['time']}
    Artist: ${appointmentData['artistName']}
    Serviciu: ${appointmentData['service']}
    Locație: ${appointmentData['location']}

    Te așteptăm!

    Pentru orice modificări, te rugăm să ne contactezi la:
    Tel: 0787 229 574
    Email: elitattoobrasov@gmail.com

    Cu respect,
    Echipa Eli Tattoo Studio
    ''';
  }
}
