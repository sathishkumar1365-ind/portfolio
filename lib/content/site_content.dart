// All site copy lives here so it can be edited without touching layout code.
// Copy follows the Nikhil Cutz developer brief.
import 'package:material_ui/material_ui.dart';

class Contact {
  static const brand = 'Nikhil Cutz';
  static const email = 'nikhilcutz01@gmail.com';
  static const instagramHandle = '@nikhilcutz022';
  static const instagramUrl = 'https://www.instagram.com/nikhilcutz022/';
  static const whatsappDisplay = '+91 93450 54761';
  static const whatsappNumber = '919345054761';
  static const location = 'Salem, Tamil Nadu, India';
  static const availability = 'Worldwide remote projects';

  static String whatsappUrl([String text = '']) => 'https://wa.me/$whatsappNumber${text.isEmpty ? '' : '?text=${Uri.encodeComponent(text)}'}';
}

/// Optional form backend. Paste a Formspree / Web3Forms / Getform endpoint
/// here to receive enquiries by email. When empty, the form hands the
/// completed enquiry to WhatsApp (or email) so nothing is lost.
const String kEnquiryEndpoint = '';

class HeroCopy {
  static const eyebrow = 'Video Editor & Creative Storyteller';
  static const title = 'Crafting Videos That Capture Attention.';
  static const body =
      'I help content creators, personal brands, and businesses transform raw footage into engaging, '
      'high-quality videos that connect with audiences and strengthen their online presence.';
  static const services = ['Short-Form Video Editing', 'YouTube Editing', 'Podcast Editing', 'UGC Editing', 'Brand Videos'];
  static const supporting = 'Available for projects worldwide.';
}

class Service {
  const Service(this.title, this.icon, this.summary, this.deliverables);
  final String title;
  final IconData icon;
  final String summary;
  final List<String> deliverables;
}

const services = <Service>[
  Service(
    'Short-Form Video Editing',
    Icons.smartphone_rounded,
    'Instagram Reels, YouTube Shorts, TikTok videos, talking-head reels, educational and business reels.',
    ['Captions', 'Engaging cuts', 'Zooms', 'B-rolls', 'Transitions', 'Sound effects'],
  ),
  Service('Podcast Video Editing', Icons.mic_rounded, 'Full podcast episodes, short clips, multi-camera editing and speaker-focused cuts.', [
    'Animated subtitles',
    'Audio cleanup',
    'Multi-cam',
    'B-rolls',
    'Short clips',
  ]),
  Service(
    'UGC & Video Ad Editing',
    Icons.shopping_bag_rounded,
    'UGC ads, product advertisements, testimonials, promotional reels and social media ad creatives.',
    ['Hook-focused editing', 'Product highlights', 'Captions', 'CTA integration'],
  ),
  Service(
    'Brand & Business Videos',
    Icons.business_center_rounded,
    'Business promos, product showcases, personal branding videos, real estate edits and corporate social content.',
    ['Promos', 'Product showcases', 'Real estate', 'Corporate social'],
  ),
  Service(
    'YouTube Video Editing',
    Icons.smart_display_rounded,
    'Talking-head videos, educational content, vlogs, tutorials and repurposing long-form videos into Shorts.',
    ['Talking-head', 'Tutorials', 'Vlogs', 'Long-form to Shorts'],
  ),
  Service(
    'Motion Graphics & Creative Editing',
    Icons.auto_awesome_rounded,
    'Animated typography, 3D text animations, logo animations, kinetic typography and chroma key.',
    ['Kinetic type', '3D text', 'Logo animation', 'Chroma key', 'Advanced transitions'],
  ),
];

const addOnServices = ['Advanced color grading', 'Sound design', 'Background replacement', 'Thumbnail design'];
const localShootNote = 'Local video shooting and on-location business promo shoots are available as an add-on in and around Salem, Tamil Nadu.';

class Project {
  const Project({
    required this.title,
    required this.category,
    required this.description,
    required this.style,
    required this.software,
    required this.videoUrl,
    this.sample = false,
  });
  final String title;
  final String category;
  final String description;
  final String style;
  final String software;

  /// A YouTube / YouTube Shorts link, or an MP4 (e.g. 'videos/my-edit.mp4').
  final String videoUrl;

  /// Shows a small "Sample" badge. Set to false (or remove) for Nikhil's real work.
  final bool sample;
}

/// Extracts the video id from any YouTube or YouTube Shorts link.
String? youTubeId(String url) {
  final m = RegExp(r'(?:youtube\.com/(?:shorts/|watch\?v=|embed/)|youtu\.be/)([\w-]{11})').firstMatch(url);
  return m?.group(1);
}

/// Thumbnail for a project (YouTube still frame), or null for MP4 files.
String? thumbnailFor(String url) {
  final id = youTubeId(url);
  return id == null ? null : 'https://i.ytimg.com/vi/$id/hqdefault.jpg';
}

// PLACEHOLDER showreel clip in web/videos/. Replace with Nikhil's real showreel
// (an MP4 in web/videos/ or a YouTube link).
const showreelUrl = 'videos/showreel.mp4';

// SAMPLE videos: public YouTube Shorts by other creators, embedded with
// YouTube's own player only to demo the layout. Replace every videoUrl with
// Nikhil's own Shorts / Reels links before launch and set sample: false.
const portfolioCategories = ['All', 'Talking-Head', 'Podcast', 'UGC / Product Ads', 'Business Reels', 'YouTube / Long-Form', 'Motion Graphics'];

const projects = <Project>[
  Project(
    title: 'Talking-Head Before & After',
    category: 'Talking-Head',
    description: 'Punchy talking-head reel with a strong first-second hook, jump cuts, zooms and highlighted captions.',
    style: 'Fast cuts · Animated captions',
    software: 'Premiere Pro',
    videoUrl: 'https://www.youtube.com/shorts/bpfVNtjfuak',
    sample: true,
  ),
  Project(
    title: 'Short-Form Reel Breakdown',
    category: 'Talking-Head',
    description: 'Raw talking-head footage turned into a retention-focused reel with B-roll, SFX and kinetic captions.',
    style: 'Hook-first · B-roll',
    software: 'Premiere Pro · After Effects',
    videoUrl: 'https://www.youtube.com/shorts/vr6Bpw7jNs4',
    sample: true,
  ),
  Project(
    title: 'Podcast to Shorts',
    category: 'Podcast',
    description: 'Edited a long-form podcast into an engaging short-form video with dynamic captions, clean cuts, relevant B-rolls and sound design.',
    style: 'Multi-cam · Subtitles',
    software: 'CapCut',
    videoUrl: 'https://www.youtube.com/shorts/OwuTc_mzyo8',
    sample: true,
  ),
  Project(
    title: 'Podcast Clip Polish',
    category: 'Podcast',
    description: 'Speaker-focused podcast clip with audio cleanup, punch-in zooms and animated subtitles.',
    style: 'Speaker cuts · Audio cleanup',
    software: 'CapCut',
    videoUrl: 'https://www.youtube.com/shorts/b5wlE9YvhlE',
    sample: true,
  ),
  Project(
    title: 'Product Ad Timeline',
    category: 'UGC / Product Ads',
    description: 'Hook-first product ad with quick cuts, benefit captions and a clear call to action.',
    style: 'Hook-focused · CTA',
    software: 'CapCut',
    videoUrl: 'https://www.youtube.com/shorts/QNikDPdZxgU',
    sample: true,
  ),
  Project(
    title: 'Cinematic Product Shots',
    category: 'UGC / Product Ads',
    description: 'Product close-ups cut to music with speed ramps, smooth transitions and clean color.',
    style: 'Speed ramps · Music sync',
    software: 'CapCut',
    videoUrl: 'https://www.youtube.com/shorts/gXzc-zo_UsA',
    sample: true,
  ),
  Project(
    title: 'Cafe Promo Reel',
    category: 'Business Reels',
    description: 'Business promo reel with music-synced cuts, smooth transitions and warm color correction.',
    style: 'Music sync · Color',
    software: 'Premiere Pro · DaVinci Resolve',
    videoUrl: 'https://www.youtube.com/shorts/U7yvRZGFMzE',
    sample: true,
  ),
  Project(
    title: 'Real Estate Listing Reel',
    category: 'Business Reels',
    description: 'Property showcase reel with smooth walkthrough cuts, text callouts and a contact CTA.',
    style: 'Walkthrough · Callouts',
    software: 'Premiere Pro',
    videoUrl: 'https://www.youtube.com/shorts/RxRiWnXKXHc',
    sample: true,
  ),
  Project(
    title: 'Long-Form to Shorts',
    category: 'YouTube / Long-Form',
    description: 'Repurposed a long-form YouTube video into a vertical short with reframing, captions and pacing fixes.',
    style: 'Reframing · Pacing',
    software: 'Premiere Pro · After Effects',
    videoUrl: 'https://www.youtube.com/shorts/MoVlt-ptxIk',
    sample: true,
  ),
  Project(
    title: 'YouTube Edit Workflow',
    category: 'YouTube / Long-Form',
    description: 'YouTube edit with chapter-style structure, screen zooms, B-roll and clean audio.',
    style: 'Structure · Retention',
    software: 'Premiere Pro',
    videoUrl: 'https://www.youtube.com/shorts/sicsAh4MCwg',
    sample: true,
  ),
  Project(
    title: '3D Text Reel',
    category: 'Motion Graphics',
    description: 'Reel with tracked 3D text, light sweeps and sound design.',
    style: '3D text · Tracking',
    software: 'After Effects',
    videoUrl: 'https://www.youtube.com/shorts/dAiWKkDldWI',
    sample: true,
  ),
  Project(
    title: 'Freeze Cutout Transition',
    category: 'Motion Graphics',
    description: 'Freeze-frame cutout transition with masking, outline stroke and impact SFX.',
    style: 'Masking · Transitions',
    software: 'CapCut',
    videoUrl: 'https://www.youtube.com/shorts/MKKfO4Uu4dY',
    sample: true,
  ),
  Project(
    title: 'SFX & Transitions Breakdown',
    category: 'Motion Graphics',
    description: 'Before-and-after breakdown showing layered sound effects, transitions and motion text.',
    style: 'SFX · Motion text',
    software: 'Premiere Pro',
    videoUrl: 'https://www.youtube.com/shorts/NNSqY1vXvw4',
    sample: true,
  ),
];

class CaseStudy {
  const CaseStudy(this.title, this.category, this.brief, this.approach, this.output, this.videoUrl);
  final String title, category, brief, approach, output, videoUrl;
}

// PLACEHOLDER case studies: replace with real projects Nikhil can share.
const caseStudies = <CaseStudy>[
  CaseStudy(
    'Podcast Episode → Clip Series',
    'Podcast Editing',
    'A long podcast episode needed to become a set of short clips for Instagram and YouTube Shorts.',
    'Picked the strongest moments, cut multi-cam to the active speaker, added animated subtitles, B-roll and audio cleanup.',
    'Vertical clips with consistent caption styling, ready to post.',
    'https://www.youtube.com/shorts/OwuTc_mzyo8',
  ),
  CaseStudy(
    'Product Launch UGC Ad',
    'UGC & Video Ads',
    'A product brand had raw creator footage and needed an ad that stops the scroll.',
    'Rebuilt the edit around a hook in the first two seconds, product highlights, benefit captions and a CTA end card.',
    'Ad creative delivered in 9:16 and 1:1 for social placements.',
    'https://www.youtube.com/shorts/QNikDPdZxgU',
  ),
];

class Feature {
  const Feature(this.title, this.body, this.icon);
  final String title, body;
  final IconData icon;
}

const whyChoose = <Feature>[
  Feature('Content-Focused Editing', "Every edit is tailored to the content's purpose, audience and platform.", Icons.center_focus_strong_rounded),
  Feature('Clear Communication', 'Simple communication and regular project updates throughout the process.', Icons.forum_rounded),
  Feature('Reliable Delivery', 'Clear timelines and organized delivery for every project.', Icons.schedule_rounded),
  Feature('Revision Support', 'Revisions based on the agreed project scope.', Icons.published_with_changes_rounded),
  Feature('Worldwide Collaboration', 'Remote editing services for clients across different countries.', Icons.public_rounded),
  Feature('Consistent Content', 'Ongoing editing support for creators and businesses.', Icons.all_inclusive_rounded),
];

const industries = <Feature>[
  Feature('Content Creators', 'YouTubers, influencers and personal brands.', Icons.videocam_rounded),
  Feature('Business Owners', 'Entrepreneurs, coaches and consultants.', Icons.work_rounded),
  Feature('E-commerce Brands', 'Product ads, UGC and promotional videos.', Icons.storefront_rounded),
  Feature('Real Estate', 'Property showcases and real estate reels.', Icons.home_work_rounded),
  Feature('Fitness & Lifestyle', 'Fitness coaches and lifestyle creators.', Icons.fitness_center_rounded),
  Feature('Agencies & Brands', 'Marketing agencies and growing businesses.', Icons.campaign_rounded),
];

const workflow = <Feature>[
  Feature('Project Discussion', "Understand the client's requirements, content style, target audience and expectations.", Icons.chat_bubble_rounded),
  Feature('Footage & Reference Collection', 'Receive raw footage, reference videos, brand assets and editing instructions.', Icons.cloud_upload_rounded),
  Feature('Editing & Production', 'Edit with appropriate cuts, captions, B-rolls, sound design and motion graphics.', Icons.movie_creation_rounded),
  Feature('Review & Feedback', 'Share a preview and collect client feedback.', Icons.rate_review_rounded),
  Feature('Final Delivery', 'Complete agreed revisions and deliver the final video in the required format.', Icons.rocket_launch_rounded),
];

class Software {
  const Software(this.name, this.short, this.area, this.color);
  final String name, short, area;
  final Color color;
}

const software = <Software>[
  Software('Adobe Premiere Pro', 'Pr', 'Video editing', Color(0xFF9999FF)),
  Software('Adobe After Effects', 'Ae', 'Motion graphics and animation', Color(0xFFCF96FD)),
  Software('DaVinci Resolve', 'DR', 'Color grading', Color(0xFFFF6B6B)),
  Software('CapCut', 'Cc', 'Short-form editing', Color(0xFFFFFFFF)),
];

const skills = [
  'Cutting & pacing',
  'Animated captions',
  'B-roll integration',
  'Sound design',
  'Color correction',
  'Kinetic typography',
  'Multi-cam editing',
  'Chroma key',
];

// No testimonials yet, so the brief asks for "What You Can Expect".
const expectations = <Feature>[
  Feature('A clear brief, upfront', 'We agree on style, length, platform and timeline before any editing starts.', Icons.assignment_turned_in_rounded),
  Feature('Edits built for the platform', 'Hooks, captions and pacing that suit Reels, Shorts, YouTube or ads.', Icons.tune_rounded),
  Feature('Previews before final', 'You review a preview and share feedback before final delivery.', Icons.visibility_rounded),
  Feature('Files ready to post', 'Final videos delivered in the format and aspect ratio you need.', Icons.download_done_rounded),
];

class PriceTier {
  const PriceTier(this.name, this.price, this.features, {this.highlight = false});
  final String name, price;
  final List<String> features;
  final bool highlight;
}

const singleReelPricing = <PriceTier>[
  PriceTier('Basic', '₹499', ['Clean cuts', 'Simple captions', 'Basic transitions', 'Sound effects', 'Up to 60 seconds']),
  PriceTier('Standard', '₹799', [
    'Smooth transitions',
    'Animated captions & highlighted words',
    'Basic color correction',
    'Sound effects',
    'Up to 60 seconds',
  ], highlight: true),
  PriceTier('Premium', '₹1,499', [
    'Advanced cuts, zooms & effects',
    'Motion graphics',
    'High-quality captions',
    'Professional color grading',
    'Cinematic transitions & music sync',
    'Up to 60 seconds',
  ]),
];

const monthlyPricing = <PriceTier>[
  PriceTier('Basic', '₹8,999', ['20 reels / month', 'Basic package edits']),
  PriceTier('Standard', '₹14,999', ['20 reels / month', 'Standard package edits'], highlight: true),
  PriceTier('Premium', '₹22,000', ['20 reels / month', 'Premium package edits']),
];

const faqs = <(String, String)>[
  ('Do you work with international clients?', 'Yes. I provide remote video editing services to clients worldwide.'),
  (
    'What type of videos do you edit?',
    'I specialize in short-form videos, YouTube content, podcasts, UGC ads, talking-head videos and business promotional content.',
  ),
  ('How do I share my raw footage?', 'You can share your footage through Google Drive or another mutually agreed file-sharing platform.'),
  (
    'How long does video editing take?',
    'Delivery time depends on video duration, complexity and project requirements. The timeline will be discussed before starting.',
  ),
  ('Do you offer monthly editing packages?', 'Yes. Monthly editing packages are available for creators and businesses that need consistent video content.'),
  ('Do you provide revisions?', 'Yes. Revisions are provided according to the agreed project scope.'),
  ('How can I get started?', 'Contact me through the website or email with your project requirements.'),
];

const contactCta =
    "Have a project in mind? Whether you're a content creator, business owner or growing brand, I'd love to help "
    'bring your content to life through professional video editing. Tell me about your project, and let\'s create something impactful.';

const countries = [
  'India',
  'United States',
  'United Kingdom',
  'Canada',
  'Australia',
  'United Arab Emirates',
  'Singapore',
  'Germany',
  'France',
  'Netherlands',
  'New Zealand',
  'Malaysia',
  'Sri Lanka',
  'Saudi Arabia',
  'Other',
];

const budgetsInr = ['Under ₹1,000', '₹1,000 – ₹5,000', '₹5,000 – ₹15,000', '₹15,000 – ₹25,000', '₹25,000+', 'Not sure yet'];
const budgetsUsd = ['Under \$100', '\$100 – \$300', '\$300 – \$800', '\$800 – \$1,500', '\$1,500+', 'Not sure yet'];
