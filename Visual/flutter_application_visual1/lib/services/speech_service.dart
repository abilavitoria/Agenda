import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService extends ChangeNotifier {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;

  SpeechService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  double _soundLevel = 0.0;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isAvailable => _speechToText.isAvailable;
  String get lastWords => _lastWords;
  double get soundLevel => _soundLevel;
  String? get errorMessage => _errorMessage;

  Future<bool> initSpeech() async {
    if (_isInitialized) return true;

    try {
      // Solicitar permissão de microfone se necessário
      if (!kIsWeb) {
        final status = await Permission.microphone.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          _errorMessage =
              'Permissão de microfone negada. Ative nas configurações do aparelho.';
          notifyListeners();
          return false;
        }
      }

      _isInitialized = await _speechToText.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: false,
      );

      _errorMessage = null;
      notifyListeners();
      return _isInitialized;
    } catch (e) {
      _errorMessage = 'Não foi possível inicializar o microfone: $e';
      _isInitialized = false;
      notifyListeners();
      return false;
    }
  }

  void _onError(SpeechRecognitionError error) {
    _errorMessage = error.errorMsg;
    _isListening = false;
    _soundLevel = 0.0;
    notifyListeners();
  }

  void _onStatus(String status) {
    if (status == 'listening') {
      _isListening = true;
    } else if (status == 'notListening' || status == 'done') {
      _isListening = false;
      _soundLevel = 0.0;
    }
    notifyListeners();
  }

  Future<void> startListening({
    required Function(String words, bool isFinal) onResult,
    Function(double level)? onSoundLevelChange,
  }) async {
    _errorMessage = null;
    _lastWords = '';

    if (!_isInitialized) {
      final initialized = await initSpeech();
      if (!initialized) {
        return;
      }
    }

    try {
      _isListening = true;
      notifyListeners();

      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastWords = result.recognizedWords;
          onResult(result.recognizedWords, result.finalResult);
          notifyListeners();
        },
        onSoundLevelChange: (level) {
          _soundLevel = level;
          onSoundLevelChange?.call(level);
          notifyListeners();
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: false,
          partialResults: true,
          listenMode: ListenMode.confirmation,
          localeId: 'pt_BR',
        ),
      );
    } catch (e) {
      _errorMessage = 'Erro ao ouvir microfone: $e';
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
      _isListening = false;
      _soundLevel = 0.0;
      notifyListeners();
    } catch (e) {
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> cancelListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
      _isListening = false;
      _soundLevel = 0.0;
      notifyListeners();
    } catch (e) {
      _isListening = false;
      notifyListeners();
    }
  }
}
