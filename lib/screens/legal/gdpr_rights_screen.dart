import 'package:flutter/material.dart';
import 'package:eli_tattoo/widgets/legal_content_widget.dart';

class GdprRightsScreen extends StatelessWidget {
  const GdprRightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LegalContentWidget(
      title: 'Drepturile Tale GDPR',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle(text: '1. Dreptul la Informare'),
          _SectionContent(
            text: '''
Ai dreptul să fii informat despre:
• Ce date personale colectăm
• Cum folosim datele tale
• Cât timp păstrăm informațiile
• Cu cine împărtășim datele tale''',
          ),
          
          _SectionTitle(text: '2. Dreptul de Acces'),
          _SectionContent(
            text: '''
Poți solicita oricând:
• O copie a datelor tale personale
• Informații despre cum folosim datele
• Perioada de stocare
• Detalii despre sursa datelor''',
          ),
          
          _SectionTitle(text: '3. Dreptul la Rectificare'),
          _SectionContent(
            text: '''
Poți cere oricând să:
• Corectăm informațiile inexacte
• Completăm datele incomplete
• Actualizăm informațiile învechite''',
          ),
          
          _SectionTitle(text: '4. Dreptul la Ștergere'),
          _SectionContent(
            text: '''
Cunoscut și ca "dreptul de a fi uitat", poți cere ștergerea datelor tale când:
• Nu mai sunt necesare pentru scopul inițial
• Îți retragi consimțământul
• Te opui prelucrării
• Datele au fost prelucrate ilegal''',
          ),
          
          _SectionTitle(text: '5. Dreptul la Restricționare'),
          _SectionContent(
            text: '''
Poți cere restricționarea prelucrării când:
• Contești exactitatea datelor
• Prelucrarea este ilegală
• Nu mai avem nevoie de date, dar tu le soliciți pentru un drept legal''',
          ),
          
          _SectionTitle(text: '6. Dreptul la Portabilitate'),
          _SectionContent(
            text: '''
Poți:
• Primi datele într-un format structurat
• Transmite datele către alt operator
• Solicita transferul direct când este posibil tehnic''',
          ),
          
          _SectionTitle(text: '7. Exercitarea Drepturilor'),
          _SectionContent(
            text: '''
Pentru a-ți exercita oricare dintre aceste drepturi:
• Email: elitattoobrasov@gmail.com
• Telefon: 0787 229 574
• În persoană la unul din sediile noastre:
  - Strada Republicii 25
  - B-dul Nicolae Bălcescu Nr. 20, Brașov

Vom răspunde solicitării în maximum 30 de zile.''',
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
