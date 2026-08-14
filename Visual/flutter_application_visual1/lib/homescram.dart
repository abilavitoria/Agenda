import 'package:flutter/material.dart';

class HomeScream extends StatefulWidget {
  final VoidCallback onToogleTheme;
  final bool isDarkMode;

  const HomeScream({
    super.key,
    required this.onToogleTheme,
    required this.isDarkMode,
    });

  State<HomeScream> createState() => _HomeScreamState();

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

  class _HomeScreamState extends State<HomeScream>{
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
            onPressed: widget.onToogleTheme,
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: widget.isDarkMode ? const Color(0xFFFFD166) : colorScheme.primary,
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
                backgroundColor: colorScheme.primary.withValues(),
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
                style: TextStyle(fontSize: 18, color: colorScheme.onSurface.withValues(),
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
                        color: widget.isDarkMode
                          ? colorScheme.primary.withValues()
                          : colorScheme.primary.withValues(),
                        blurRadius: widget.isDarkMode ? 35 : 20,
                        spreadRadius: widget.isDarkMode ? 8 : 4,                
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
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(widget.isDarkMode ? 0.4 : 0.25),
                  width: 1.5,
                ),
              ),

              child: Row(
                children: [
                  Icon(Icons.event_note, color: colorScheme.primary, size: 32),
                  const SizedBox(width: 16),
                  Column( 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próximo evento:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.onSurface.withValues()
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Casamento - 20/04/2027',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
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
}



  void _exibirModalGravacao(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context){
        return const ModalGravacaoConteudo();
      },
    );
  }

class ModalGravacaoConteudo extends StatefulWidget{
  const ModalGravacaoConteudo({super.key});

  @override
  State<ModalGravacaoConteudo> createState() => _ModalConteudoGravacaoState();  
}

class _ModalConteudoGravacaoState extends State<ModalGravacaoConteudo>
    with SingleTickerProviderStateMixin{
      late AnimationController _animationController;
      late Animation<double> _scaleAnimation;
      
      @override
      void initState(){
        super.initState();

        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 900),
          )..repeat(reverse: true);

          _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
          );
      }

      @override
      void dispose(){
        _animationController.dispose();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Padding(
          padding: EdgeInsets.only(
            top: 36,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues()
                  ),

                  child: Icon(
                    Icons.mic,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Fale o título e a data do seu evento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Exemplo: "Casamento no dia 20 de abril de 2027 às 16h"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: colorScheme.onSurface.withValues()
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () => {
                    Navigator.pop(context),
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    )
                  ),
                  child: const Text(
                    'Confirmar e Salvar',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  )
                  )
            ],
          ),
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
