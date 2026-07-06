import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locales = FlutterLocalization.instance.supportedLocales;
    final localization = FlutterLocalization.instance;
    OverlayEntry? overlayEntry;

    void loading() {
      overlayEntry = OverlayEntry(
        builder: (BuildContext context) {
          return Container(
            width: context.mq.size.width,
            height: context.mq.size.height,
            decoration: BoxDecoration(color: Colors.black.withAlpha(100)),
            child: Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        },
      );
      Overlay.of(context).insert(overlayEntry!);
    }

    void removeHighlightOverlay() {
      overlayEntry?.remove();
      overlayEntry?.dispose();
      overlayEntry = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Language"),
      ),
      body: Column(
        children: [
          ...locales.map(
            (locale) {
              final isCurrent = localization.currentLocale == locale;
              return ListTile(
              onTap: () async {
                if (isCurrent) return;
                loading();
                localization.translate(locale.languageCode);
                await Future.delayed(Duration(seconds: 1), () {
                  removeHighlightOverlay();
                });
              },
              trailing: isCurrent ? Icon(Icons.check) : null,
              titleTextStyle: context.tt.bodyMedium,
              title: Text(localization.getLanguageName(languageCode: locale.languageCode)),
            );
            },
          ),
        ],
      ),
    );
  }
}
