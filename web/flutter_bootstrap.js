{{flutter_js}}
{{flutter_build_config}}

// Self-host CanvasKit so the site does not depend on the gstatic CDN.
_flutter.loader.load({
  config: { canvasKitBaseUrl: "canvaskit/" },
});
