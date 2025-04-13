import 'package:flutter/material.dart';
import 'package:eli_tattoo/widgets/legal_content_widget.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LegalContentWidget(
      title: 'Termeni și Condiții',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle(text: '1. Acceptarea Termenilor'),
          _SectionContent(
            text: '''
Prin utilizarea aplicației Eli Tattoo Studio și a serviciilor noastre, accepți acești termeni și condiții în totalitate. Te rugăm să citești cu atenție înainte de a utiliza aplicația.''',
          ),
          
          _SectionTitle(text: '2. Servicii Disponibile'),
          _SectionContent(
            text: '''
• Programări pentru tatuaje și piercing
• Consultații gratuite pentru design
• Sistem de fidelizare cu puncte și recompense
• Treasure Hunt cu premii
• Chat direct cu artiștii
• Galerie de lucrări
• Scanare tatuaje pentru redare audio''',
          ),
          
          _SectionTitle(text: '3. Programări și Anulări'),
          _SectionContent(
            text: '''
• Programările se fac prin aplicație sau telefonic
• Este necesară o arvună pentru confirmarea programării
• Anulările se fac cu minimum 24 de ore înainte
• Reprogramările sunt posibile în funcție de disponibilitate''',
          ),
          
          _SectionTitle(text: '4. Treasure Hunt'),
          _SectionContent(
            text: '''
• Participarea este voluntară și gratuită
• Premiile sunt valabile conform termenelor specificate
• Locațiile sunt alese pentru siguranța participanților
• Eli Tattoo Studio nu este responsabil pentru incidente în timpul căutării''',
          ),
          
          _SectionTitle(text: '5. Sistemul de Fidelizare'),
          _SectionContent(
            text: '''
• Punctele se acumulează pentru servicii și achiziții
• Punctele expiră după 12 luni de la acumulare
• Recompensele sunt supuse disponibilității
• Punctele nu sunt transferabile''',
          ),
          
          _SectionTitle(text: '6. Conținut și Proprietate Intelectuală'),
          _SectionContent(
            text: '''
• Toate designurile sunt proprietatea artistului și a studioului
• Fotografiile lucrărilor pot fi folosite în scopuri promoționale
• Este interzisă copierea sau reproducerea designurilor''',
          ),
          
          _SectionTitle(text: '7. Program de Lucru'),
          _SectionContent(
            text: '''
• Luni-Vineri: 11:00-19:00
• Sâmbătă: 11:00-17:00
• Programul poate suferi modificări în perioada sărbătorilor''',
          ),
          
          _SectionTitle(text: '8. Contact'),
          _SectionContent(
            text: '''
Pentru orice întrebări sau clarificări:
• Email: elitattoobrasov@gmail.com
• Telefon: 0787 229 574
• Locații: Strada Republicii 25 și B-dul Nicolae Bălcescu Nr. 20, Brașov''',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  
  const _SectionTitle({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SectionContent extends StatelessWidget {
  final String text;
  
  const _SectionContent({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        height: 1.5,
      ),
    );
  }
}
