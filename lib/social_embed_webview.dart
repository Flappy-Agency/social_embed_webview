library social_embed_webview;

import 'package:flutter/material.dart';
import 'package:social_embed_webview/platforms/social-media-generic.dart';
import 'package:social_embed_webview/utils/common-utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SocialEmbed extends StatefulWidget {
  final SocialMediaGenericEmbedData socialMediaObj;
  final Color? backgroundColor;

  const SocialEmbed({Key? key, required this.socialMediaObj, this.backgroundColor}) : super(key: key);

  @override
  _SocialEmbedState createState() => _SocialEmbedState();
}

class _SocialEmbedState extends State<SocialEmbed> with WidgetsBindingObserver {
  double _height = 300;
  WebViewController? _controller;
  late String htmlBody;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initController());

    if (widget.socialMediaObj.supportMediaControll) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  void _initController() {
    _controller?.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller?.addJavaScriptChannel('PageHeight', onMessageReceived: _onPageHeightJavascriptMessageReceived);
    _controller?.setBackgroundColor(getBackgroundColor(context));
    _controller?.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (str) {
          final color = colorToHtmlRGBA(getBackgroundColor(context));
          _controller?.runJavaScript('document.body.style= "background-color: $color"');
          if (widget.socialMediaObj.aspectRatio == null)
            _controller?.runJavaScript('setTimeout(() => sendHeight(), 0)');
        },
        onNavigationRequest: (navigation) async {
          final url = navigation.url;
          if (navigation.isMainFrame && await canLaunch(url)) {
            launch(url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
    _controller?.loadRequest(htmlToURI(getHtmlBody()));
  }

  @override
  void dispose() {
    if (widget.socialMediaObj.supportMediaControll) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.detached:
        _controller?.runJavaScript(widget.socialMediaObj.stopVideoScript);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _controller?.runJavaScript(widget.socialMediaObj.pauseVideoScript);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final webView = WebViewWidget(controller: _controller ?? WebViewController());

    final aspectRation = widget.socialMediaObj.aspectRatio;
    if (aspectRation != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 1.5,
          maxWidth: double.infinity,
        ),
        child: AspectRatio(aspectRatio: aspectRation, child: webView),
      );
    }

    return SizedBox(height: _height, child: webView);
  }

  void _onPageHeightJavascriptMessageReceived(JavaScriptMessage message) {
    _setHeight(double.parse(message.message));
  }

  void _setHeight(double height) {
    if (!mounted) return;
    setState(() {
      _height = height;
    });
  }

  Color getBackgroundColor(BuildContext context) {
    return widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
  }

  String getHtmlBody() => """
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            *{box-sizing: border-box;margin:0px; padding:0px;}
              #widget {
                        display: flex;
                        justify-content: center;
                        margin: 0 auto;
                        max-width:100%;
                    }      
          </style>
        </head>
        <body>
          <div id="widget" style="${widget.socialMediaObj.htmlInlineStyling}">${widget.socialMediaObj.htmlBody}</div>
          ${(widget.socialMediaObj.aspectRatio == null) ? dynamicHeightScriptSetup : ''}
          ${(widget.socialMediaObj.aspectRatio == null) ? dynamicHeightScriptCheck : ''}
        </body>
      </html>
    """;

  static const String dynamicHeightScriptSetup = """
    <script type="text/javascript">
      const widget = document.getElementById('widget');
    </script>
  """;

  static const String dynamicHeightScriptCheck = """
    <script type="text/javascript">
      const onWidgetResize = (widgets) => {
        PageHeight.postMessage(widget.clientHeight);
      }
      const resize_ob = new ResizeObserver(onWidgetResize);
      resize_ob.observe(widget);
    </script>
  """;
}
