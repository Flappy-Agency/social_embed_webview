import '../utils/embed_theme.dart';
import 'social-media-generic.dart';

class TwitterEmbedData extends SocialMediaGenericEmbedData {
  final String embedHtml;
  final EmbedTheme? embedTheme;

  const TwitterEmbedData({
    required this.embedHtml,
    this.embedTheme,
  }) : super(canChangeSize: true, bottomMargin: -10);

  @override
  String get htmlScriptUrl => 'https://platform.twitter.com/widgets.js';

  @override
  String get htmlBody {
    final theme = embedTheme;
    if (theme != null) {
      return embedHtml.replaceAll('<blockquote', '<blockquote data-theme="${theme.name}"') + htmlScript;
    }

    return embedHtml + htmlScript;
  }
}
