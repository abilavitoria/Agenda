import 'package:flutter/material.dart';

class HomeScream extends StatelessWidget {
  final VoidCallback onToogleTheme;
  final bool isDarkMode;

  const HomeScream({
    super.key,
    required this.onToogleTheme,
    required this.isDarkMode,
    });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Minha Agenda',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: onToogleTheme,
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? const Color(0xFFFFD166) : colorScheme.primary,
            ),),

          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: (){},
              icon: Icon(Icons.calendar_month, color: colorScheme.primary,),
              label: Text(
                'Calendário',
                style: TextStyle( color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.primary.withOpacity(0.15),
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
            const SizedBox(height: 20),

           Padding( 
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Toque no botão abaixo para ditar seu evento',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              ),
            const Spacer(),

            Center(
              child: GestureContainer(
                onTap: () => _exibirModalGravacao(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                          ? colorScheme.primary.withOpacity(0.6)
                          : colorScheme.primary.withOpacity(0.35),
                        blurRadius: isDarkMode ? 35 : 20,
                        spreadRadius: isDarkMode ? 8 : 4,                
                      )
                    ]
                  ),

                  child: const Icon(
                    Icons.mic,
                    size: 85,
                    color: Colors.white,
                  ),
                  )
              ),
            ),

            const Spacer(),

            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                borderRadius: BorderRadius.circular(16),
                border: isDarkMode ? Border.all(color: colorScheme.primary.withOpacity(0.3)) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    ),
                ]
              ),

              child: Row(
                children: [
                  Icon(Icons.event_note, color: colorScheme.primary, size: 30),
                  SizedBox(width: 12),
                  Column( 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próximo evento:',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)
                        ),
                      ),
                      const SizedBox(height: 2,),
                      Text(
                        'Casamento - 20/04/2027',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
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
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context){
        return Padding(
          padding: EdgeInsets.only(
            top: 28,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ouvindo...',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 24),
                Icon(Icons.graphic_eq, size: 70, color: colorScheme.primary),
                const SizedBox(height: 20),
                Text(
                  'Fale o título e a data do próximo evento. \nExemplo: "Casamento no dia 20 de abril de 2027 às 16h"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Text('Confirmar e salvar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
  final Widget child;
  const GestureContainer({super.key, required this.onTap, required this.child});

@override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTap, 
      child: child
    );
  }
}
