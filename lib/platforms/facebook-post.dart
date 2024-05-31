import 'social-media-generic.dart';

class FacebookPostEmbedData extends SocialMediaGenericEmbedData {
  final String postUrl;

  const FacebookPostEmbedData({required this.postUrl})
      : super(canChangeSize: false, bottomMargin: 2.5);

  @override
  String get htmlScriptUrl =>
      'https://connect.facebook.net/en_US/sdk.js#xfbml=1&version=v3.2';

  @override
  String get htmlBody =>
      htmlScript +
      '<div id="fb-root"><div class="fb-post" data-href="$postUrl"></div></div>';

  @override
  String get pauseVideoScript => "pauseVideo()";
  @override
  String get stopVideoScript => "stopVideo()";
}
