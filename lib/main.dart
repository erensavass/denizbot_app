import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(const KaptanChatApp());

class KaptanChatApp extends StatelessWidget {
  const KaptanChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaptan Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0055A4),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}

/* =============== SPLASH (Dalga + Dönen Dümen) =============== */
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _spin, _pulse, _waveCtrl;
  late Animation<double> _scale, _fade;
  double _waveT = 0.0;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _scale = Tween(begin: 0.92, end: 1.06)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _fade = Tween(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..addListener(() => setState(() => _waveT += 0.03))
      ..repeat();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(_slideFade(const LoginScreen()));
    });
  }

  PageRouteBuilder _slideFade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 420),
        transitionsBuilder: (_, anim, __, child) {
          final offset =
              Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic))
                  .animate(anim);
          final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
          return SlideTransition(
              position: offset,
              child: FadeTransition(opacity: fade, child: child));
        },
      );

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF003D82), Color(0xFF0055A4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(
                t: _waveT,
                color: Colors.white.withOpacity(0.10),
                amp: 14,
                waveLen: 1.6),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(
                t: _waveT * 0.9 + 2.0,
                color: Colors.white.withOpacity(0.06),
                amp: 20,
                waveLen: 2.2),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: RotationTransition(
                      turns: _spin,
                      child: Image.asset('assets/images/dumen.png', width: 160),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fade,
                child: const Text(
                  'KAPTAN CHAT',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t;
  final Color color;
  final double amp;
  final double waveLen;
  _WavePainter(
      {required this.t,
      required this.color,
      this.amp = 12,
      this.waveLen = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    final path = Path();
    final baseY = size.height * 0.82;
    path.moveTo(0, baseY);
    for (double x = 0; x <= size.width; x++) {
      final y =
          baseY + math.sin((x / size.width) * math.pi * 2 * waveLen + t) * amp;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.color != color ||
      oldDelegate.amp != amp ||
      oldDelegate.waveLen != waveLen;
}

/* =============== LOGIN =============== */
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFF0055A4),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/giris.png', width: 220),
                const SizedBox(height: 24),
                const Text('KAPTAN CHAT',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Adınızı girin',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0055A4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        _slideFade(ChatScreen(
                            userName: nameCtrl.text, startListening: true)),
                      ),
                      icon: const Icon(Icons.mic),
                      label: const Text('Sesli Konuşma'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0055A4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        _slideFade(ChatScreen(
                            userName: nameCtrl.text, startListening: false)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Yazarak Konuşma'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _slideFade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 360),
        transitionsBuilder: (_, anim, __, child) {
          final offset =
              Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic))
                  .animate(anim);
          final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
          return SlideTransition(
              position: offset,
              child: FadeTransition(opacity: fade, child: child));
        },
      );
}

/* =============== CHAT (Auto-send Speech) =============== */
class ChatScreen extends StatefulWidget {
  final String userName;
  final bool startListening;
  const ChatScreen(
      {super.key, required this.userName, required this.startListening});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_Msg> _messages = [];
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    if (widget.startListening) {
      Future.delayed(const Duration(milliseconds: 400), _toggleListen);
    }
  }

  void _toggleListen() async {
    if (!_isListening) {
      final available = await _speech.initialize(
        onStatus: (s) => debugPrint('speech status: $s'),
        onError: (e) => debugPrint('speech error: $e'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: "tr_TR",
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
          onResult: (r) {
            // Anlık yazdır
            _controller.text = r.recognizedWords;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );

            // Cümle tamamlandıysa otomatik gönder
            if (r.finalResult && _controller.text.trim().isNotEmpty) {
              _send();
            }
          },
        );
      }
    } else {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, isUser: true));
      // Mock bot cevabı (backend/AI ekipleri bağlayınca burası değişecek)
      _messages.add(_Msg(text: "Bunu duydum: $text", isUser: false));
    });
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0055A4),
        title: Row(children: [
          Image.asset('assets/images/dumen.png', width: 36),
          const SizedBox(width: 8),
          const Text('Kaptan Chat', style: TextStyle(color: Colors.white)),
        ]),
        actions: [
          IconButton(
            tooltip: _isListening ? 'Dinlemeyi durdur' : 'Konuşarak yaz',
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _toggleListen,
          )
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _Bubble(msg: _messages[i]),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 4,
                  offset: Offset(0, -1))
            ],
          ),
          child: Row(children: [
            IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                  color: const Color(0xFF0055A4)),
              onPressed: _toggleListen,
              tooltip: _isListening ? 'Dinlemeyi durdur' : 'Konuşarak yaz',
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Mesaj yazın veya konuşun...',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Color(0xFF0055A4)),
              onPressed: _send,
              tooltip: 'Gönder',
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  _Msg({required this.text, required this.isUser});
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final bg = msg.isUser ? const Color(0xFF0055A4) : Colors.white;
    final fg = msg.isUser ? Colors.white : const Color(0xFF111827);
    final align = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final radius = msg.isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            topRight: Radius.circular(14))
        : const BorderRadius.only(
            topLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
            topRight: Radius.circular(14));
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(msg.text,
            style: TextStyle(color: fg, fontSize: 15, height: 1.3)),
      ),
    );
  }
}
