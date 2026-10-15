import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api.dart';
import 'l10n.dart';
import 'models.dart';
import 'store_update.dart';
import 'theme.dart';
import 'version.dart';

/// Forces an update when there is one to force. Two independent triggers:
///
/// 1. **Google Play has an update ready for this device.** This is the usual
///    case and the one that behaves like every big game: the moment the update
///    reaches you, the app stops and makes you take it. Play's answer already
///    accounts for staged rollout and device compatibility, so nobody is ever
///    blocked by an update they cannot actually install.
/// 2. **The server declares this build too old** (`min_version`). The
///    compatibility floor, for when an API change genuinely breaks old builds.
///    Works on every platform, including the ones with no store.
///
/// Both fail open. Play throwing (sideloaded build, no Play Services, offline)
/// and the server saying nothing both mean "carry on" - a gate that failed
/// closed would brick every install at once, fixable only through the store.
class UpdateGate extends StatefulWidget {
  const UpdateGate({
    super.key,
    required this.api,
    required this.child,
    this.store = const PlayStoreUpdates(),
  });

  final Api api;
  final Widget child;

  /// Swappable so the gate is testable without Play.
  final StoreUpdates store;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  AppRelease? _release;
  AppVersion? _mine;
  bool _storeUpdateReady = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final mine = await AppVersion.load();
    final release = await widget.api.release();
    final storeReady = await widget.store.isUpdateReady();
    if (!mounted) return;
    setState(() {
      _mine = mine;
      _release = release;
      _storeUpdateReady = storeReady;
      _checked = true;
    });

    // Hand straight over to Play's own full-screen flow, rather than making
    // the user tap through our screen first. Ours is the fallback for when
    // they back out of Play's.
    if (storeReady) await _runStoreUpdate();
  }

  Future<void> _runStoreUpdate() async {
    final done = await widget.store.startImmediateUpdate();
    // On success Play restarts the app, so reaching here generally means the
    // user declined - keep the wall up and let them try again.
    if (done && mounted) setState(() => _storeUpdateReady = false);
  }

  @override
  Widget build(BuildContext context) {
    final mine = _mine;

    // Nothing renders differently until the checks land: no spinner, no
    // launch delay, no flash of a gate that then disappears.
    if (!_checked || mine == null) return widget.child;

    if (_storeUpdateReady) {
      return UpdateRequiredScreen(
        release: _release,
        current: mine,
        onUpdate: _runStoreUpdate,
      );
    }
    if (_release?.blocks(mine.version) == true) {
      return UpdateRequiredScreen(release: _release, current: mine);
    }
    return widget.child;
  }
}

/// The wall. Deliberately a dead end - no back, no dismiss - because a gate the
/// user can tap past is not a gate.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({
    super.key,
    required this.release,
    required this.current,
    this.onUpdate,
  });

  /// Null when the server has no opinion - the Play path does not need it.
  final AppRelease? release;
  final AppVersion current;

  /// Runs Play's in-app update. Falls back to [updateDestination] when absent,
  /// which is the only option on a platform without in-app updates.
  final VoidCallback? onUpdate;

  /// Where the update button sends the user when there is no in-app flow.
  ///
  /// Only Android has a store to go to. Windows (and direct-download macOS)
  /// would otherwise be sent to an Android listing they cannot install, so they
  /// get the server's [AppRelease.updateUrl], or the website without one.
  /// Returns null on Android, meaning "use Google Play".
  static String? updateDestination(AppRelease? release, {TargetPlatform? platform}) {
    final p = platform ?? defaultTargetPlatform;
    if (!kIsWeb && p == TargetPlatform.android) return null;
    return release?.updateUrl ?? Links.website;
  }

  static Future<void> openStore([AppRelease? release]) async {
    final elsewhere = updateDestination(release);
    if (elsewhere != null) {
      await launchUrl(Uri.parse(elsewhere), mode: LaunchMode.externalApplication);
      return;
    }
    // market: opens the Play app directly. It fails on a device without Play,
    // so fall back to the browser rather than doing nothing.
    final direct = Uri.parse(Links.playStore);
    try {
      if (await launchUrl(direct, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    await launchUrl(Uri.parse(Links.playStoreWeb), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);

    return Scaffold(
      backgroundColor: Brutal.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/img/logo.png',
                  height: 92,
                  errorBuilder: (_, _, _) => const SizedBox(height: 92),
                ),
                const SizedBox(height: 22),
                Transform.rotate(
                  angle: -0.02,
                  child: BrutalBox(
                    color: Brutal.yellow,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          t['updateTitle'],
                          textAlign: TextAlign.center,
                          style: Brutal.display.copyWith(fontSize: 30),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          // The server can explain why; otherwise a generic line.
                          release?.message?.trim().isNotEmpty == true
                              ? release!.message!.trim()
                              : t['updateBody'],
                          textAlign: TextAlign.center,
                          style: Brutal.body.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                BrutalButton(
                  color: Brutal.lime,
                  onPressed: onUpdate ?? () => openStore(release),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(t['updateButton']),
                ),
                const SizedBox(height: 18),
                Text(
                  release?.minVersion != null
                      ? '${current.display}  ->  v${release!.minVersion}+'
                      : current.display,
                  textAlign: TextAlign.center,
                  style: Brutal.body.copyWith(
                    fontSize: 13,
                    color: Brutal.ink.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small "v1.8.0 (10)" line for the bottom of a screen. Shows the website's
/// version too once the server reports one, so a bug report can name both
/// halves without the user hunting for either.
class VersionFooter extends StatefulWidget {
  const VersionFooter({super.key, this.api});

  final Api? api;

  @override
  State<VersionFooter> createState() => _VersionFooterState();
}

class _VersionFooterState extends State<VersionFooter> {
  AppVersion? _mine;
  String? _server;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mine = await AppVersion.load();
    if (mounted) setState(() => _mine = mine);
    final release = await widget.api?.release();
    if (mounted && release?.serverVersion != null) {
      setState(() => _server = release!.serverVersion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mine = _mine;
    if (mine == null) return const SizedBox(height: 18);

    final t = L10n.of(context);
    final style = Brutal.body.copyWith(fontSize: 12, color: Brutal.ink.withValues(alpha: 0.55));

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 4),
      child: Column(
        children: [
          Text('${t['versionApp']} ${mine.display}', textAlign: TextAlign.center, style: style),
          if (_server != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${t['versionSite']} v$_server',
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
        ],
      ),
    );
  }
}
