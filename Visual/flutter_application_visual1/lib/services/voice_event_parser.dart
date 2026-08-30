class ParsedVoiceEvent {
  final String title;
  final DateTime date;
  final String time; // HH:mm
  final String category;
  final String originalText;

  ParsedVoiceEvent({
    required this.title,
    required this.date,
    required this.time,
    required this.category,
    required this.originalText,
  });

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class VoiceEventParser {
  static final Map<String, int> _months = {
    'janeiro': 1,
    'jan': 1,
    'fevereiro': 2,
    'fev': 2,
    'março': 3,
    'marco': 3,
    'mar': 3,
    'abril': 4,
    'abr': 4,
    'maio': 5,
    'mai': 5,
    'junho': 6,
    'jun': 6,
    'julho': 7,
    'jul': 7,
    'agosto': 8,
    'ago': 8,
    'setembro': 9,
    'set': 9,
    'outubro': 10,
    'out': 10,
    'novembro': 11,
    'nov': 11,
    'dezembro': 12,
    'dez': 12,
  };

  static final Map<String, int> _weekdays = {
    'domingo': DateTime.sunday,
    'dom': DateTime.sunday,
    'segunda': DateTime.monday,
    'segunda-feira': DateTime.monday,
    'seg': DateTime.monday,
    'terça': DateTime.tuesday,
    'terca': DateTime.tuesday,
    'terça-feira': DateTime.tuesday,
    'terca-feira': DateTime.tuesday,
    'ter': DateTime.tuesday,
    'quarta': DateTime.wednesday,
    'quarta-feira': DateTime.wednesday,
    'qua': DateTime.wednesday,
    'quinta': DateTime.thursday,
    'quinta-feira': DateTime.thursday,
    'qui': DateTime.thursday,
    'sexta': DateTime.friday,
    'sexta-feira': DateTime.friday,
    'sex': DateTime.friday,
    'sábado': DateTime.saturday,
    'sabado': DateTime.saturday,
    'sab': DateTime.saturday,
  };

  static final Map<String, int> _wordNumbers = {
    'zero': 0,
    'uma': 1,
    'um': 1,
    'duas': 2,
    'dois': 2,
    'três': 3,
    'tres': 3,
    'quatro': 4,
    'cinco': 5,
    'seis': 6,
    'sete': 7,
    'oito': 8,
    'nove': 9,
    'dez': 10,
    'onze': 11,
    'doze': 12,
    'treze': 13,
    'quatorze': 14,
    'catorze': 14,
    'quinze': 15,
    'dezesseis': 16,
    'dezessete': 17,
    'dezoito': 18,
    'dezenove': 19,
    'vinte': 20,
    'trinta': 30,
    'quarenta': 40,
    'cinquenta': 50,
  };

  static ParsedVoiceEvent parse(String rawText) {
    if (rawText.trim().isEmpty) {
      final now = DateTime.now();
      return ParsedVoiceEvent(
        title: 'Novo Evento',
        date: DateTime(now.year, now.month, now.day),
        time: '${now.hour.toString().padLeft(2, '0')}:00',
        category: 'Geral',
        originalText: rawText,
      );
    }

    String text = rawText.toLowerCase().trim();

    // 1. Extrair Data primeiro (para não confundir "dia 15" com "15:00")
    final dateResult = _extractDate(text);
    final eventDate = dateResult.date;
    text = dateResult.cleanedText;

    // 2. Extrair Horário
    final timeResult = _extractTime(text);
    final timeStr = timeResult.time;
    text = timeResult.cleanedText;

    // 3. Detectar Categoria
    final category = _detectCategory(rawText);

    // 4. Limpar e Formatar Título
    String title = _cleanTitle(text);
    if (title.isEmpty) {
      title = _defaultTitleFromCategory(category);
    }

    return ParsedVoiceEvent(
      title: title,
      date: eventDate,
      time: timeStr,
      category: category,
      originalText: rawText,
    );
  }

  static _TimeExtractionResult _extractTime(String text) {
    final now = DateTime.now();
    int hour = (now.hour + 1) % 24;
    int minute = 0;
    String cleaned = text;

    // 1. "ao meio dia" / "meio-dia"
    if (RegExp(r'\b(ao\s+)?meio[- ]?dia\b').hasMatch(cleaned)) {
      cleaned = cleaned.replaceAll(RegExp(r'\b(ao\s+)?meio[- ]?dia\b'), ' ');
      return _TimeExtractionResult(time: '12:00', cleanedText: cleaned);
    }

    // 2. "à meia-noite" / "meia-noite"
    if (RegExp(r'\b([aà]\s+)?meia[- ]?noite\b').hasMatch(cleaned)) {
      cleaned = cleaned.replaceAll(RegExp(r'\b([aà]\s+)?meia[- ]?noite\b'), ' ');
      return _TimeExtractionResult(time: '00:00', cleanedText: cleaned);
    }

    // 3. Padrão numérico com prefixo "às/as" OU sufixos de tempo (h, :, horas, da manhã/tarde/noite)
    final regexWithTimeIndicators = RegExp(
      r'(?:([aà]s?)\s+)?(\d{1,2})(?:[:hH](\d{1,2})?|\s*horas?(?:\s*e\s*(\d{1,2}))?|\s*e\s*(\d{1,2}))?(?:\s*(da\s+(?:manh[aã]|tarde|noite)|am|pm))?',
    );

    final matches = regexWithTimeIndicators.allMatches(cleaned);
    for (final match in matches) {
      final hasAsPrefix = match.group(1) != null;
      final hStr = match.group(2);
      final hasColonOrH = match.group(0)?.contains(':') == true ||
          match.group(0)?.contains('h') == true ||
          match.group(0)?.contains('H') == true ||
          match.group(0)?.contains('hora') == true;
      final period = match.group(6);

      // Deve ter ao menos um indicador de horário (às, :, h, horas, da tarde/noite/manhã)
      if (hasAsPrefix || hasColonOrH || period != null) {
        if (hStr != null) {
          int h = int.parse(hStr);
          int m = 0;
          if (match.group(3) != null) {
            m = int.tryParse(match.group(3)!) ?? 0;
          } else if (match.group(4) != null) {
            m = int.tryParse(match.group(4)!) ?? 0;
          } else if (match.group(5) != null) {
            m = int.tryParse(match.group(5)!) ?? 0;
          }

          if (period != null) {
            if ((period.contains('tarde') || period.contains('noite') || period.contains('pm')) && h < 12) {
              h += 12;
            } else if (period.contains('manh') && h == 12) {
              h = 0;
            }
          } else if (h >= 1 && h <= 6 && (hasAsPrefix || hasColonOrH)) {
            h += 12;
          }

          if (h >= 0 && h <= 23) {
            hour = h;
            minute = m.clamp(0, 59);

            cleaned = cleaned.replaceRange(match.start, match.end, ' ');
            final formattedTime =
                '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
            return _TimeExtractionResult(time: formattedTime, cleanedText: cleaned);
          }
        }
      }
    }

    // 4. Padrão com números por extenso: "às duas da tarde", "às dez e meia", "às oito e quinze"
    final wordRegex = RegExp(
      r'(?:[aà]s?\s+)?(uma|duas|dois|tr[eê]s|quatro|cinco|seis|sete|oito|nove|dez|onze|doze)(?:\s*(?:horas?|h))?(?:\s*e\s*(meia|quinze|trinta|quarenta|cinquenta|\d{1,2}))?(?:\s*(da\s+(?:manh[aã]|tarde|noite)))?',
    );

    final wordMatch = wordRegex.firstMatch(cleaned);
    if (wordMatch != null) {
      final hWord = wordMatch.group(1)!;
      int h = _wordNumbers[hWord] ?? 12;
      int m = 0;

      final mWord = wordMatch.group(2);
      if (mWord != null) {
        if (mWord == 'meia') {
          m = 30;
        } else if (_wordNumbers.containsKey(mWord)) {
          m = _wordNumbers[mWord]!;
        } else {
          m = int.tryParse(mWord) ?? 0;
        }
      }

      final period = wordMatch.group(3);
      if (period != null) {
        if ((period.contains('tarde') || period.contains('noite')) && h < 12) {
          h += 12;
        }
      } else if (h < 7 && h >= 1) {
        h += 12;
      }

      hour = h.clamp(0, 23);
      minute = m.clamp(0, 59);

      cleaned = cleaned.replaceRange(wordMatch.start, wordMatch.end, ' ');
      final formattedTime =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      return _TimeExtractionResult(time: formattedTime, cleanedText: cleaned);
    }

    final formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    return _TimeExtractionResult(time: formattedTime, cleanedText: cleaned);
  }

  static _DateExtractionResult _extractDate(String text) {
    final now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    String cleaned = text;

    // 1. "depois de amanhã"
    if (cleaned.contains('depois de amanhã') || cleaned.contains('depois de amanha')) {
      date = now.add(const Duration(days: 2));
      cleaned = cleaned
          .replaceAll('depois de amanhã', '')
          .replaceAll('depois de amanha', '');
      return _DateExtractionResult(date: date, cleanedText: cleaned);
    }

    // 2. "amanhã"
    if (cleaned.contains('amanhã') || cleaned.contains('amanha')) {
      date = now.add(const Duration(days: 1));
      cleaned = cleaned.replaceAll('amanhã', '').replaceAll('amanha', '');
      return _DateExtractionResult(date: date, cleanedText: cleaned);
    }

    // 3. "hoje"
    if (cleaned.contains('hoje')) {
      date = now;
      cleaned = cleaned.replaceAll('hoje', '');
      return _DateExtractionResult(date: date, cleanedText: cleaned);
    }

    // 4. "dia 15 de abril [de 2026]" / "15/04" / "15/04/2026"
    final fullDateRegex = RegExp(
      r'(?:no\s+)?dia\s+(\d{1,2})(?:\s+de\s+([a-zç]+)(?:\s+de\s+(\d{4}))?)?',
    );
    final fullMatch = fullDateRegex.firstMatch(cleaned);
    if (fullMatch != null) {
      final day = int.tryParse(fullMatch.group(1)!) ?? now.day;
      int month = now.month;
      int year = now.year;

      final monthStr = fullMatch.group(2);
      if (monthStr != null && _months.containsKey(monthStr)) {
        month = _months[monthStr]!;
      }

      if (fullMatch.group(3) != null) {
        year = int.tryParse(fullMatch.group(3)!) ?? now.year;
      } else if (month < now.month || (month == now.month && day < now.day)) {
        // Se a data já passou este ano, assume próximo ano
        year = now.year + 1;
      }

      date = DateTime(year, month, day);
      cleaned = cleaned.replaceRange(fullMatch.start, fullMatch.end, ' ');
      return _DateExtractionResult(date: date, cleanedText: cleaned);
    }

    // Padrão numérico "15/04/2026" ou "15/04"
    final slashDateRegex = RegExp(r'\b(\d{1,2})\/(\d{1,2})(?:\/(\d{2,4}))?\b');
    final slashMatch = slashDateRegex.firstMatch(cleaned);
    if (slashMatch != null) {
      final day = int.tryParse(slashMatch.group(1)!) ?? now.day;
      final month = int.tryParse(slashMatch.group(2)!) ?? now.month;
      int year = now.year;
      if (slashMatch.group(3) != null) {
        int y = int.parse(slashMatch.group(3)!);
        year = y < 100 ? 2000 + y : y;
      } else if (month < now.month || (month == now.month && day < now.day)) {
        year = now.year + 1;
      }

      date = DateTime(year, month, day);
      cleaned = cleaned.replaceRange(slashMatch.start, slashMatch.end, ' ');
      return _DateExtractionResult(date: date, cleanedText: cleaned);
    }

    // 5. Dias da semana ("na próxima segunda", "sexta-feira", "no sábado")
    for (final entry in _weekdays.entries) {
      final regex = RegExp('\\b(?:na\\s+|no\\s+|pr[oó]xim[ao]\\s+)?${entry.key}\\b');
      if (regex.hasMatch(cleaned)) {
        final targetWeekday = entry.value;
        int daysToAdd = (targetWeekday - now.weekday) % 7;
        if (daysToAdd <= 0) {
          daysToAdd += 7; // Próximo dia da semana correspondente
        }
        date = now.add(Duration(days: daysToAdd));
        cleaned = cleaned.replaceAll(regex, '');
        return _DateExtractionResult(date: date, cleanedText: cleaned);
      }
    }

    return _DateExtractionResult(date: date, cleanedText: cleaned);
  }

  static String _detectCategory(String text) {
    final lower = text.toLowerCase();

    // Saúde
    if (RegExp(r'\b(m[eé]dico|consulta|dentista|exame|rem[eé]dio|hospital|cardiologista|nutricionista|fisioterapia|psic[oó]logo|terapia|farm[aá]cia|vacina|cl[ií]nico|ortopedista|oftalmologista|dermatologista|terapeuta)\b')
        .hasMatch(lower)) {
      return 'Saúde';
    }

    // Trabalho
    if (RegExp(r'\b(reuni[aã]o|call|daily|sprint|cliente|apresenta[cç][aã]o|projeto|entrega|feedback|alinhamento|entrevista|relat[oó]rio|chefe|equipe|empresa|escrit[oó]rio|proposta|contrato|meta|prazo|trabalho|confer[eê]ncia)\b')
        .hasMatch(lower)) {
      return 'Trabalho';
    }

    // Estudo
    if (RegExp(r'\b(prova|estudo|estudar|aula|curso|faculdade|escola|universidade|tcc|semin[aá]rio|simulado|enem|diploma|tarefa|li[cç][aã]o)\b')
        .hasMatch(lower)) {
      return 'Estudo';
    }

    // Social
    if (RegExp(r'\b(anivers[aá]rio|festa|jantar|almo[cç]o|casamento|churrasco|bar|caf[eé]|cinema|show|happy hour|encontro|confraterniza[cç][aã]o|pizza|balada|viagem|passeio|amigo|festa junina|chá de bebê)\b')
        .hasMatch(lower)) {
      return 'Social';
    }

    // Pessoal
    if (RegExp(r'\b(treino|academia|compras|pagar|banco|mercado|supermercado|corte de cabelo|barbeiro|sal[aã]o|faxina|conserto|mec[aâ]nico|carro|casa|pet|veterin[aá]rio|corrida|muscula[cç][aã]o)\b')
        .hasMatch(lower)) {
      return 'Pessoal';
    }

    return 'Geral';
  }

  static String _cleanTitle(String text) {
    String cleaned = text;

    // Remover preposições e palavras de comando
    final removePatterns = [
      r'^\s*(agendar|marcar|lembrar(\s+de)?|criar\s+(um\s+)?evento(\s+de)?|anotar|novo\s+evento(\s+de)?)\s+',
      r'\b(para|no\s+dia|no|na|em|de|às|as|com)\b',
      r'\b(por\s+favor|agradeço|obrigado|ok)\b',
      r'[,\.\-;:!]',
    ];

    for (final pattern in removePatterns) {
      cleaned = cleaned.replaceAll(RegExp(pattern, caseSensitive: false), ' ');
    }

    // Remover múltiplos espaços
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (cleaned.isEmpty) return '';

    // Capitalizar primeira letra
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  static String _defaultTitleFromCategory(String category) {
    switch (category) {
      case 'Saúde':
        return 'Consulta / Compromisso de Saúde';
      case 'Trabalho':
        return 'Reunião de Trabalho';
      case 'Estudo':
        return 'Sessão de Estudos';
      case 'Social':
        return 'Compromisso Social';
      case 'Pessoal':
        return 'Compromisso Pessoal';
      default:
        return 'Novo Evento';
    }
  }
}

class _TimeExtractionResult {
  final String time;
  final String cleanedText;
  _TimeExtractionResult({required this.time, required this.cleanedText});
}

class _DateExtractionResult {
  final DateTime date;
  final String cleanedText;
  _DateExtractionResult({required this.date, required this.cleanedText});
}
