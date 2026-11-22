# Nikhil Cutz – Video Editor Portfolio (Flutter Web)

Red & blue, dark, web-slinger inspired portfolio built from the Nikhil Cutz developer brief.
No franchise logos, characters or artwork are used: the webs, skyline, halftones and comic panels are all drawn in code.

## Run it

```bash
flutter pub get
flutter run -d chrome          # development
flutter build web --release    # production build in build/web
```

Built and tested with Flutter 3.50.1 (Dart 3.14). A ready-made release build is in `web_build/` of the delivery zip:
upload that folder to any static host (Firebase Hosting, Netlify, Vercel, GitHub Pages, cPanel).
To preview it locally: `cd web_build && python3 -m http.server 8080` then open http://localhost:8080.

## Where things live

| What | File |
| --- | --- |
| All text, services, prices, FAQ, projects, contact details | `lib/content/site_content.dart` |
| Colours and fonts | `lib/theme/app_theme.dart` |
| Page layout, navbar, mobile menu, WhatsApp button | `lib/pages/home_page.dart` |
| Sections (hero, portfolio, services, about, process, pricing, FAQ, contact/footer) | `lib/sections/` |
| Animations: scroll reveal / swing-in, 3D tilt cards, web painters | `lib/widgets/` |
| Video lightbox and hover previews | `lib/widgets/video.dart` |
| **Intro hook** | `lib/intro/intro_slot.dart` + `kIntroBuilder` in `lib/main.dart` |
| SEO title, meta description, Open Graph, schema.org | `web/index.html` |

## Swap in real videos

The site ships with short branded **placeholder** clips in `web/videos/`.
Replace them with real, permission-cleared edits (compressed MP4, ideally under 8 MB each),
keeping the same file names, or change the `videoUrl` values in `lib/content/site_content.dart`.
Videos only load when a visitor hovers a card (muted preview, desktop) or presses play, so the homepage stays fast.

Placeholder content to replace before launch: sample videos, the two case studies, and the "Photo coming soon" portrait in `lib/sections/about.dart`.

## Plug in the custom intro

1. Build the intro as a widget in `lib/intro/`, and call `onFinished()` when it ends or is skipped.
2. In `lib/main.dart` set:

```dart
const IntroBuilder? kIntroBuilder = myIntro;
Widget myIntro(BuildContext context, VoidCallback onFinished) => MyIntro(onFinished: onFinished);
```

The portfolio fades in underneath and the hero entrance animation starts only after the intro finishes.

## Enquiry form

Validation, a hidden honeypot and a minimum time-on-page check are built in.
By default **Send Enquiry** opens WhatsApp (+91 93450 54761) with all form details filled in, with an email fallback.
To receive enquiries by email instead, create a free Formspree / Web3Forms / Getform form and paste its endpoint into
`kEnquiryEndpoint` in `lib/content/site_content.dart`.

## Notes

- Fonts (Anton, Bangers, Manrope) and CanvasKit are bundled, so the site does not depend on Google's CDNs.
- Respects the "reduce motion" accessibility setting: scroll reveals and web animations switch off.
- Pricing shows INR for India and a "Get a Custom Quote" path for international clients, as the brief asks.
