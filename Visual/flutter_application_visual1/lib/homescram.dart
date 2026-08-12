import 'package:flutter/material.dart';

class HomeScream extends StatelessWidget {
  const HomeScream({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Minha Agenda',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: (){

              },
              icon: const Icon(Icons.calendar_month, color: Colors.deepPurple,),
              label: const Text(
                'Calendário',
                style: TextStyle( color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                )
              ),

              ),
            )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20,),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Toque no botão abaixo para ditar seu evento',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              ),
            const Spacer(),

            Center(
              child: GestureContainer(
                onTap: () => _exibirModalGravacao(context),
              ),
            ),

            const Spacer(),

            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    ),
                ]
              ),

              child: const Row(
                children: [
                  Icon(Icons.event_note, color: Colors.deepPurple, size: 30,),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próximo evento:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Casamento - 20/04/2027',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                ],
                ),
            )
          ],
        ) 
        ),
    );
  }

  void _exibirModalGravacao(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context){
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ouvindo...',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20,),
                const Icon(Icons.graphic_eq, size: 60, color: Colors.deepPurple,),
                const SizedBox(height: 20,),
                const Text(
                  'Fale o título e a data do próximo evento. \nExemplo: "Casamento no dia 20 de abril de 2027 às 16h"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30,),
                ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Confirmar e salvar', style: TextStyle(color: Colors.white)),
                  )
              ],
            ),
          );
      }
    );
  }
}

class GestureContainer extends StatelessWidget{
  final VoidCallback onTap;
  const GestureContainer({super.key, required this.onTap});

  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.deepPurple,
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 10,

            )
          ]
        ),
        child: const Icon(
          Icons.mic,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
}
