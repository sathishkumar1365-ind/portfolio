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

Portfolio videos live in `lib/content/site_content.dart` (`projects`). Each `videoUrl` can be:

- a **YouTube or YouTube Shorts link** (e.g. `https://www.youtube.com/shorts/VIDEO_ID`): the thumbnail is shown in the phone stack
  and the video plays inside the phone with YouTube's own player when tapped, or
- an **MP4** in `web/videos/` (e.g. `videos/my-edit.mp4`), which opens in the lightbox player.

The current entries are **sample YouTube Shorts by other creators**, used only to demo the layout, and show a "SAMPLE" badge.
Before launch, replace every link with Nikhil's own Shorts / Reels uploads and set `sample: false`.
The showreel is still a branded placeholder clip at `web/videos/showreel.mp4`.

### Phone stack carousel

`lib/widgets/phone_stack.dart` is an original Flutter carousel: the centre card morphs into a phone (bezel, rounded
screen, camera island) and plays in place, while the other videos fan out behind it, smaller and dimmer.
It supports drag/swipe with fling, tapping a side card, arrow buttons, dots, keyboard arrows and auto-advance
(which stops as soon as the visitor interacts).

## Layout checks

`flutter test test/overflow_test.dart` lays the whole page out at 13 screen sizes (320px phones to 1920px desktops)
and fails on any overflow.

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
