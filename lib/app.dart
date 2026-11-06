import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/l10n/language.dart';
import 'core/result.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/appearance.dart';
import 'core/theme/tokens.dart';
import 'data/repositories/auth_repository.dart';
import 'data/session_controller.dart';
import 'data/store_session.dart';
import 'ui/scopes.dart';
import 'ui/screens/auth/create_store_screen.dart';
import 'ui/screens/auth/status_screens.dart';
import 'ui/screens/auth/welcome_screen.dart';
import 'ui/shell/home_shell.dart';
import 'ui/widgets/layout.dart';

class TindahanApp extends StatefulWidget {
  const TindahanApp({super.key, required this.language, required this.appearance, this.startupError});

  final LanguageController language;
  final AppearanceController appearance;
  final AppError? startupError;

  @override
  State<TindahanApp> createState() => _TindahanAppState();
}

class _TindahanAppState extends State<TindahanApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  SessionController? _sessionController;
  AuthRepository? _authRepository;
  Type? _lastStateType;

  Brightness get _brightness =>
      widget.appearance.resolve(WidgetsBinding.instance.platformDispatcher.platformBrightness);

  /// Moves to the palette the setting and the phone call for. Colours are read
  /// during build, and const widgets would otherwise keep the old ones, so
  /// every element is rebuilt. Rebuilding in place keeps open screens and
  /// half-filled forms, which recreating the tree would lose.
  void _applyAppearance() {
    if (!AppColors.use(_brightness)) return;
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
    setState(() {});
  }

  @override
  void didChangePlatformBrightness() => _applyAppearance();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.appearance.addListener(_applyAppearance);
    AppColors.use(_brightness);
    if (widget.startupError == null) {
      final auth = FirebaseAuth.instance;
      final db = FirebaseFirestore.instance;
      _authRepository = AuthRepository(auth: auth, db: db);
      final controller = SessionController(auth: auth, db: db);
      controller.addListener(_onSessionChanged);
      _sessionController = controller;
    }
  }

  /// Whenever the session moves to a different kind of state (signed in,
  /// signed out, disabled...), close any pushed screens so the user lands on
  /// the right home screen.
  void _onSessionChanged() {
    final type = _sessionController?.state.runtimeType;
    if (type == _lastStateType) return;
    _lastStateType = type;
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.appearance.removeListener(_applyAppearance);
    _sessionController?.removeListener(_onSessionChanged);
    _sessionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _sessionController;
    final authRepository = _authRepository;
    return AppearanceScope(
      controller: widget.appearance,
      child: LanguageScope(
        controller: widget.language,
        child: MaterialApp(
          title: 'Tindahan',
          debugShowCheckedModeBanner: false,
          // One theme for the active palette, swapped at once with the colours.
          theme: buildAppTheme(),
          themeAnimationDuration: Duration.zero,
          navigatorKey: _navigatorKey,
          builder: (context, navigator) {
            // Tab screens have no AppBar to set the status bar icons for them.
            final child = AnnotatedRegion<SystemUiOverlayStyle>(
              value: AppColors.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
              child: AppViewport(child: navigator ?? const SizedBox.shrink()),
            );
            if (controller == null || authRepository == null) return child;
            return AppServices(
              sessionController: controller,
              authRepository: authRepository,
              child: _SessionScopeHost(controller: controller, child: child),
            );
          },
          home: controller == null ? SetupNeededScreen(error: widget.startupError) : const AuthGate(),
        ),
      ),
    );
  }
}

/// Provides the current store session above the Navigator. Keeps the last
/// session for a moment after sign-out so closing screens can still read it.
class _SessionScopeHost extends StatefulWidget {
  const _SessionScopeHost({required this.controller, required this.child});

  final SessionController controller;
  final Widget child;

  @override
  State<_SessionScopeHost> createState() => _SessionScopeHostState();
}

class _SessionScopeHostState extends State<_SessionScopeHost> {
  StoreSession? _last;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final state = widget.controller.state;
        if (state is SessionReady) _last = state.session;
        return StoreScope(session: _last, child: widget.child);
      },
    );
  }
}

/// Picks the home screen from the session state. At start-up the branded
/// splash stays for at least [minSplash] so it reads as a loading page rather
/// than a flicker, then fades to the next screen.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  static const Duration minSplash = Duration(milliseconds: 1500);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Timer? _splashTimer;
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(AuthGate.minSplash, () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppServices.of(context).sessionController;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final Widget screen = !_splashDone
            ? const SplashScreen()
            : switch (state) {
                SessionLoading() => const SplashScreen(),
                SignedOut() => const WelcomeScreen(),
                NeedsEmailVerification(:final user) => VerifyEmailScreen(email: user.email ?? ''),
                NeedsStore(:final user) => CreateStoreScreen(user: user),
                AccessDisabled() => const AccessDisabledScreen(),
                SessionFailed(:final error) => SessionErrorScreen(error: error),
                SessionReady(:final session) => HomeShell(key: ObjectKey(session), isOwner: session.isOwner),
              };
        return ScreenSwitcher(identity: screen.key ?? screen.runtimeType, child: screen);
      },
    );
  }
}

/// Fades to [child] when [identity] changes; a rebuild with the same identity
/// keeps the screen's state.
///
/// Signing in or out passes through several screens faster than the fade.
/// Each change gets its own key, so screens fading out together never clash,
/// even when the same screen comes back mid-fade.
class ScreenSwitcher extends StatefulWidget {
  const ScreenSwitcher({super.key, required this.identity, required this.child});

  final Object identity;
  final Widget child;

  @override
  State<ScreenSwitcher> createState() => _ScreenSwitcherState();
}

class _ScreenSwitcherState extends State<ScreenSwitcher> {
  int _change = 0;

  @override
  void didUpdateWidget(ScreenSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identity != widget.identity) _change++;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey<int>(_change), child: widget.child),
    );
  }
}
