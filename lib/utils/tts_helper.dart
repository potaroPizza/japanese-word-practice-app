import 'dart:js_interop';

@JS('SpeechSynthesisUtterance')
@staticInterop
class _SpeechSynthesisUtterance {
  external factory _SpeechSynthesisUtterance(String text);
}

extension on _SpeechSynthesisUtterance {
  external set lang(String value);
  external set rate(double value);
}

@JS('speechSynthesis.cancel')
external void _cancel();

@JS('speechSynthesis.speak')
external void _speak(_SpeechSynthesisUtterance utterance);

void speakJapanese(String text) {
  _cancel();
  final u = _SpeechSynthesisUtterance(text);
  u.lang = 'ja-JP';
  u.rate = 0.85;
  _speak(u);
}
