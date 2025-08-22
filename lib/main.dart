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
              color: Colors.white.withValues(alpha: 0.10),
              amp: 14,
              waveLen: 1.6,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(
              t: _waveT * 0.9 + 2.0,
              color: Colors.white.withValues(alpha: 0.06),
              amp: 20,
              waveLen: 2.2,
            ),
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
                    color: Colors.white,
                  ),
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

/* =============== LOGIN (TCKN + Şifre -> Sonra butonlar) =============== */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final tcknCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _loggedIn = false;

  void _simulateLogin() {
    // Basit ön kontrol: TCKN 11 haneli mi? Şifre boş mu?
    if (tcknCtrl.text.trim().length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TC Kimlik No 11 haneli olmalı.')),
      );
      return;
    }
    if (passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen şifre girin.')),
      );
      return;
    }
    // Gerçek doğrulama yok -> giriş başarılı say
    setState(() => _loggedIn = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0055A4),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: !_loggedIn ? _buildLoginForm() : _buildModeButtons(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('loginForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/giris.png', width: 220),
        const SizedBox(height: 24),
        const Text(
          'KAPTAN CHAT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: tcknCtrl,
          keyboardType: TextInputType.number,
          maxLength: 11,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            hintText: 'TC Kimlik No (11 haneli)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passCtrl,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _simulateLogin(),
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Şifre',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0055A4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            onPressed: _simulateLogin,
            child: const Text('Giriş Yap'),
          ),
        ),
      ],
    );
  }

  Widget _buildModeButtons() {
    return Column(
      key: const ValueKey('modeButtons'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.verified_user, color: Colors.white, size: 56),
        const SizedBox(height: 10),
        const Text(
          'Giriş başarılı (simüle)',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
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
                  _slideFade(const ChatScreen(
                    userName: 'Kullanıcı',
                    startListening: true,
                  )),
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
                  _slideFade(const ChatScreen(
                    userName: 'Kullanıcı',
                    startListening: false,
                  )),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Yazarak Konuşma'),
              ),
            ),
          ],
        ),
      ],
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

/* =============== CHAT =============== */
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
            _controller.text = r.recognizedWords;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
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

  Future<void> _goFeedback() async {
    // Dinleme açıksa kapat
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
    // Mesajları temizlemek istersen (opsiyonel)
    _messages.clear();

    if (!mounted) return;
    // Feedback ekranına git
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FeedbackScreen()),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, isUser: true));
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
        toolbarHeight: 64,
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Image.asset(
                'assets/images/dumen.png',
                height: 42,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'KAPTAN HEP YANINIZDA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: _goFeedback, // ❗ Artık feedback ekranına gider
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.close, color: Colors.white),
                    SizedBox(height: 2),
                    Text(
                      'Sohbeti\nsonlandır',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final bg = msg.isUser ? const Color(0xFF0055A4) : Colors.white;
    final fg = msg.isUser ? Colors.white : const Color(0xFF111827);
    final align = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final radius = msg.isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
            topRight: Radius.circular(14),
          );

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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: fg, fontSize: 15, height: 1.3),
        ),
      ),
    );
  }
}

/* =============== FEEDBACK SCREEN =============== */
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _speed = 0, _accuracy = 0, _satisfaction = 0;
  String _comment = '';

  bool get _canSend => _speed > 0 && _accuracy > 0 && _satisfaction > 0;

  Widget _buildStars(int value, void Function(int) onTap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return IconButton(
          icon: Icon(
            i < value ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => onTap(i + 1),
        );
      }),
    );
  }

  void _submit() {
    if (!_canSend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen tüm kriterler için en az 1 yıldız seçin.')),
      );
      return;
    }

    // Backend'e gönderim yeri (HTTP vs.)
    debugPrint(
        'Hız: $_speed, Doğruluk: $_accuracy, Memnuniyet: $_satisfaction, Yorum: $_comment');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Değerlendirmeniz kaydedildi!')),
    );

    // Login ekranına dön (stack'i temizle)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0055A4),
        title: const Text('Değerlendirme'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('Hız', style: TextStyle(fontSize: 18)),
                  const Spacer(),
                  _buildStars(_speed, (val) => setState(() => _speed = val)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Doğruluk', style: TextStyle(fontSize: 18)),
                  const Spacer(),
                  _buildStars(
                      _accuracy, (val) => setState(() => _accuracy = val)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Memnuniyet', style: TextStyle(fontSize: 18)),
                  const Spacer(),
                  _buildStars(_satisfaction,
                      (val) => setState(() => _satisfaction = val)),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tüm kriterler için en az bir yıldız seçiniz.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Eklemek İstedikleriniz',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (val) => setState(() => _comment = val),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0055A4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _canSend ? _submit : null,
                  child: const Text('Gönder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
