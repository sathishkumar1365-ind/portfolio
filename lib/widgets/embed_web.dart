import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;

/// YouTube's own embedded player (privacy-enhanced domain), started on tap.
Widget youTubePlayer(String id) => HtmlElementView.fromTagName(
  key: ValueKey('yt-$id'),
  tagName: 'iframe',
  onElementCreated: (element) {
    final f = element as web.HTMLIFrameElement;
    f.src = 'https://www.youtube-nocookie.com/embed/$id?autoplay=1&playsinline=1&rel=0&modestbranding=1&loop=1&playlist=$id';
    f.allow = 'autoplay; encrypted-media; picture-in-picture; fullscreen';
    f.allowFullscreen = true;
    f.title = 'Video player';
    f.style
      ..border = '0'
      ..width = '100%'
      ..height = '100%';
  },
);
