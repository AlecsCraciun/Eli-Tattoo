import 'package:flutter/material.dart';
import 'package:eli_tattoo/widgets/legal_content_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LegalContentWidget(
      title: 'Politica de Confidențialitate',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle(text: '1. Introducere'),
          _SectionContent(
            text: '''
Eli Tattoo Studio, cu sediile în Strada Republicii 25 și B-dul Nicolae Bălcescu Nr. 20, Brașov, se angajează să protejeze și să respecte confidențialitatea datelor dumneavoastră personale. Această politică descrie modul în care colectăm și procesăm datele personale prin utilizarea aplicației noastre mobile și serviciilor noastre.''',
          ),
          
          _SectionTitle(text: '2. Date Colectate'),
          _SectionContent(
            text: '''
• Informații de profil (nume, email, telefon)
• Istoricul programărilor
• Fotografii ale tatuajelor (cu acordul dvs.)
• Preferințe pentru notificări
• Locația (doar pentru funcția Treasure Hunt, cu acordul explicit)
• Date despre dispozitiv și utilizarea aplicației''',
          ),
          
          _SectionTitle(text: '3. Scopul Colectării'),
          _SectionContent(
            text: '''
• Gestionarea programărilor și serviciilor
• Funcționalitatea Treasure Hunt
• Sistemul de fidelizare
• Comunicări despre servicii și promoții
• Îmbunătățirea experienței în aplicație
• Chat și asistență clienți''',
          ),
          
          _SectionTitle(text: '4. Stocarea și Securitatea'),
          _SectionContent(
            text: '''
Datele sunt stocate în siguranță folosind serviciile Firebase și sunt păstrate doar atât timp cât este necesar pentru scopurile declarate. Implementăm măsuri tehnice și organizatorice adecvate pentru a proteja datele dvs.''',
          ),
          
          _SectionTitle(text: '5. Drepturile Tale'),
          _SectionContent(
            text: '''
Ai dreptul să:
• Accesezi datele tale
• Corectezi informațiile inexacte
• Ștergi datele ("dreptul de a fi uitat")
• Restricționezi procesarea
• Porți datele (primești datele într-un format structurat)
• Te opui procesării
• Retragi consimțământul în orice moment''',
          ),
          
          _SectionTitle(text: '6. Contact'),
          _SectionContent(
            text: '''
Pentru orice întrebări despre datele tale sau această politică, ne poți contacta la:
Email: elitattoobrasov@gmail.com
Telefon: 0787 229 574''',
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
