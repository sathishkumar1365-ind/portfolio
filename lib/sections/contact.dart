import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import '../content/site_content.dart';
import '../pages/home_page.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal.dart';
import '../widgets/ui.dart';
import '../widgets/web_painters.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = context.w >= 1000;
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(number: '13', eyebrow: "Let's Work Together", title: 'Have A Project In Mind?'),
        const SizedBox(height: 4),
        Reveal(child: Text(contactCta, style: AppText.body(context.isMobile ? 15 : 17))),
        const SizedBox(height: 30),
        for (final (i, c) in [
          (Icons.chat_rounded, 'WhatsApp', Contact.whatsappDisplay, Contact.whatsappUrl("Hi Nikhil, I'd like to discuss a video editing project.")),
          (Icons.mail_rounded, 'Email', Contact.email, 'mailto:${Contact.email}?subject=${Uri.encodeComponent('Video editing enquiry')}'),
          (Icons.camera_alt_rounded, 'Instagram', Contact.instagramHandle, Contact.instagramUrl),
        ].indexed)
          Reveal(
            style: RevealStyle.slideLeft,
            delay: Duration(milliseconds: 90 * i),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ContactLink(icon: c.$1, label: c.$2, value: c.$3, url: c.$4, red: i.isEven),
            ),
          ),
        const SizedBox(height: 10),
        Reveal(
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.red, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text('${Contact.location} · ${Contact.availability}', style: AppText.body(14, color: Colors.white70)),
              ),
            ],
          ),
        ),
      ],
    );
    final form = const Reveal(style: RevealStyle.swingRight, child: EnquiryForm());
    return SectionShell(
      background: AppColors.bgAlt,
      top: 100,
      decor: const [Positioned.fill(child: AnimatedWeb(anchor: Offset(1.05, 1.05), opacity: .07, spokes: 16, rings: 9, radiusFactor: .9))],
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: left),
                const SizedBox(width: 60),
                Expanded(flex: 6, child: form),
              ],
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [left, const SizedBox(height: 40), form]),
    );
  }
}

class _ContactLink extends StatefulWidget {
  const _ContactLink({required this.icon, required this.label, required this.value, required this.url, required this.red});
  final IconData icon;
  final String label, value, url;
  final bool red;
  @override
  State<_ContactLink> createState() => _ContactLinkState();
}

class _ContactLinkState extends State<_ContactLink> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.red ? AppColors.red : AppColors.blue;
    return Semantics(
      link: true,
      label: '${widget.label}: ${widget.value}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: () => openLink(widget.url),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            transform: Matrix4.translationValues(_h ? 6 : 0, 0, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _h ? c.withValues(alpha: .12) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _h ? c : AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(11)),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label.toUpperCase(), style: AppText.label(10.5, color: AppColors.textDim)),
                      const SizedBox(height: 3),
                      Text(
                        widget.value,
                        style: AppText.body(15.5, color: Colors.white, weight: FontWeight.w700, height: 1.3),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _h ? -.125 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.arrow_forward_rounded, color: _h ? Colors.white : AppColors.textMute),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Enquiry form ─────────────────────────
enum _Status { idle, sending, success, error }

class EnquiryForm extends StatefulWidget {
  const EnquiryForm({super.key});
  @override
  State<EnquiryForm> createState() => _EnquiryFormState();
}

class _EnquiryFormState extends State<EnquiryForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _brand = TextEditingController();
  final _details = TextEditingController();
  final _honeypot = TextEditingController();
  final _openedAt = DateTime.now();
  String? _country;
  String? _service;
  String _type = 'One-time project';
  String? _budget;
  _Status _status = _Status.idle;
  bool _viaWhatsApp = false;

  bool get _inr => _country == null || _country == 'India';

  @override
  void dispose() {
    for (final c in [_name, _email, _brand, _details, _honeypot]) {
      c.dispose();
    }
    super.dispose();
  }

  String _summary() => [
    'New project enquiry (nikhilcutz website)',
    'Name: ${_name.text.trim()}',
    'Email: ${_email.text.trim()}',
    if (_brand.text.trim().isNotEmpty) 'Company / Brand: ${_brand.text.trim()}',
    'Country: $_country',
    'Service: $_service',
    'Project type: $_type',
    if (_budget != null) 'Budget: $_budget',
    'Details: ${_details.text.trim()}',
  ].join('\n');

  Future<void> _submit() async {
    if (_status == _Status.sending) return;
    if (!(_form.currentState?.validate() ?? false)) return;
    // Spam protection: hidden honeypot field + minimum time on page.
    if (_honeypot.text.isNotEmpty || DateTime.now().difference(_openedAt).inSeconds < 3) {
      setState(() => _status = _Status.success);
      return;
    }
    setState(() => _status = _Status.sending);
    try {
      if (kEnquiryEndpoint.isNotEmpty) {
        final res = await http.post(
          Uri.parse(kEnquiryEndpoint),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({
            'name': _name.text.trim(),
            'email': _email.text.trim(),
            'brand': _brand.text.trim(),
            'country': _country,
            'service': _service,
            'project_type': _type,
            'budget': _budget,
            'details': _details.text.trim(),
            '_subject': 'New enquiry from ${_name.text.trim()}',
          }),
        );
        if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('HTTP ${res.statusCode}');
        _viaWhatsApp = false;
      } else {
        // Open straight from the tap so browsers don't block the new tab.
        await openLink(Contact.whatsappUrl(_summary()));
        _viaWhatsApp = true;
      }
      if (mounted) setState(() => _status = _Status.success);
    } catch (_) {
      if (mounted) setState(() => _status = _Status.error);
    }
  }

  void _reset() {
    _form.currentState?.reset();
    for (final c in [_name, _email, _brand, _details]) {
      c.clear();
    }
    setState(() {
      _status = _Status.idle;
      _country = null;
      _service = null;
      _budget = null;
      _type = 'One-time project';
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1.4),
        boxShadow: const [
          BoxShadow(color: AppColors.red, offset: Offset(10, 10)),
          BoxShadow(color: Colors.black54, blurRadius: 40),
        ],
      ),
      padding: EdgeInsets.all(mobile ? 22 : 36),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, a) => FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween(begin: .95, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
            child: child,
          ),
        ),
        child: _status == _Status.success ? _success() : _fields(mobile),
      ),
    );
  }

  Widget _success() => Column(
    key: const ValueKey('ok'),
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 20),
      SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const AnimatedWeb(anchor: Offset(.5, .5), opacity: .5, spokes: 12, rings: 5, radiusFactor: .55, duration: Duration(milliseconds: 1200)),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, t, child) => Transform.scale(scale: t, child: child),
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.red,
                  boxShadow: [BoxShadow(color: AppColors.blue, offset: Offset(4, 4))],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Text(_viaWhatsApp ? 'ALMOST THERE!' : 'ENQUIRY SENT!', style: AppText.comic(40)),
      const SizedBox(height: 10),
      Text(
        _viaWhatsApp
            ? 'Your enquiry is ready in WhatsApp. Just press send there and I\'ll get back to you soon. If WhatsApp did not open, email ${Contact.email}.'
            : 'Thanks for reaching out. I\'ll reply to your email soon.',
        textAlign: TextAlign.center,
        style: AppText.body(15.5),
      ),
      const SizedBox(height: 26),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          if (_viaWhatsApp)
            CtaButton(
              label: 'Send by email instead',
              primary: false,
              compact: true,
              onTap: () => openLink(
                'mailto:${Contact.email}?subject=${Uri.encodeComponent('Project enquiry from ${_name.text.trim()}')}&body=${Uri.encodeComponent(_summary())}',
              ),
            ),
          CtaButton(label: 'New enquiry', compact: true, onTap: _reset),
        ],
      ),
      const SizedBox(height: 10),
    ],
  );

  Widget _fields(bool mobile) {
    InputDecoration dec(String label, {String? hint, bool required = false}) => InputDecoration(labelText: required ? '$label *' : label, hintText: hint);
    Widget pair(Widget a, Widget b) => mobile
        ? Column(children: [a, const SizedBox(height: 16), b])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 16),
              Expanded(child: b),
            ],
          );
    final budgets = _inr ? budgetsInr : budgetsUsd;

    return Form(
      key: _form,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        key: const ValueKey('form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('PROJECT ENQUIRY', style: AppText.comic(30)),
              const Spacer(),
              const Icon(Icons.bolt_rounded, color: AppColors.red),
            ],
          ),
          const SizedBox(height: 4),
          Text('Fields marked * are required.', style: AppText.body(13, color: AppColors.textMute)),
          const SizedBox(height: 22),
          pair(
            TextFormField(
              controller: _name,
              decoration: dec('Name', required: true),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (v) => (v == null || v.trim().length < 2) ? 'Please enter your name' : null,
            ),
            TextFormField(
              controller: _email,
              decoration: dec('Email address', required: true),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(v?.trim() ?? '') ? null : 'Please enter a valid email',
            ),
          ),
          const SizedBox(height: 16),
          pair(
            TextFormField(controller: _brand, decoration: dec('Company / Brand name'), textInputAction: TextInputAction.next),
            DropdownButtonFormField<String>(
              initialValue: _country,
              decoration: dec('Country', required: true),
              dropdownColor: AppColors.surfaceHi,
              isExpanded: true,
              items: [for (final c in countries) DropdownMenuItem(value: c, child: Text(c))],
              onChanged: (v) => setState(() {
                final wasInr = _inr;
                _country = v;
                if (wasInr != _inr) _budget = null;
              }),
              validator: (v) => v == null ? 'Please select your country' : null,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _service,
            decoration: dec('Required service', required: true),
            dropdownColor: AppColors.surfaceHi,
            isExpanded: true,
            items: [
              for (final s in services) DropdownMenuItem(value: s.title, child: Text(s.title)),
              const DropdownMenuItem(value: 'Other / Not sure', child: Text('Other / Not sure')),
            ],
            onChanged: (v) => setState(() => _service = v),
            validator: (v) => v == null ? 'Please choose a service' : null,
          ),
          const SizedBox(height: 18),
          Text('PROJECT TYPE', style: AppText.label(11, color: AppColors.textDim)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final t in const ['One-time project', 'Monthly retainer']) _TypePill(label: t, selected: _type == t, onTap: () => setState(() => _type = t)),
            ],
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _details,
            decoration: dec('Project details', required: true, hint: 'What are we editing? Length, style, platform, references, deadline…'),
            minLines: 4,
            maxLines: 7,
            validator: (v) => (v == null || v.trim().length < 10) ? 'Tell me a little about the project (10+ characters)' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey(_inr),
            initialValue: _budget,
            decoration: dec(_inr ? 'Budget range (INR)' : 'Budget range (USD)'),
            dropdownColor: AppColors.surfaceHi,
            isExpanded: true,
            items: [for (final b in budgets) DropdownMenuItem(value: b, child: Text(b))],
            onChanged: (v) => setState(() => _budget = v),
          ),
          // Honeypot: invisible to people, bots tend to fill it.
          Offstage(
            child: ExcludeSemantics(
              child: TextField(
                controller: _honeypot,
                decoration: const InputDecoration(labelText: 'Leave this empty'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_status == _Status.error)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x33FF5470),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFF5470)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFFF5470)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Something went wrong sending your enquiry. Please try again, or email ${Contact.email}.',
                      style: AppText.body(14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: CtaButton(label: _status == _Status.sending ? 'Sending…' : 'Send Enquiry', icon: Icons.send_rounded, onTap: _submit),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            kEnquiryEndpoint.isEmpty ? 'Sending opens WhatsApp with your details filled in.' : 'Your details are only used to reply to your enquiry.',
            style: AppText.body(12.5, color: AppColors.textMute),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.blue : AppColors.border, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  key: ValueKey(selected),
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppText.body(14, color: Colors.white, weight: FontWeight.w700, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ───────────────────────── Footer ─────────────────────────
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: HalftonePainter(color: AppColors.blue, opacity: .12, fromTopLeft: false)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(context.gutter, 70, context.gutter, mobile ? 100 : 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Reveal(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Nav.to(context, Sec.contact),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text("LET'S WORK ", style: AppText.display(mobile ? 54 : 110)),
                                ShaderMask(
                                  shaderCallback: (r) => AppColors.heroGradient.createShader(r),
                                  child: Text('TOGETHER', style: AppText.display(mobile ? 54 : 110)),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.north_east_rounded, color: AppColors.red, size: mobile ? 44 : 90),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(height: 1, color: Colors.white12),
                    const SizedBox(height: 26),
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text('© 2026 Nikhil Cutz · Video Editor & Creative Storyteller', style: AppText.body(13, color: AppColors.textDim)),
                        Wrap(
                          spacing: 8,
                          children: [
                            _FooterIcon(Icons.chat_rounded, 'WhatsApp', Contact.whatsappUrl()),
                            _FooterIcon(Icons.mail_rounded, 'Email', 'mailto:${Contact.email}'),
                            _FooterIcon(Icons.camera_alt_rounded, 'Instagram', Contact.instagramUrl),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _privacy(context),
                          child: Text(
                            'Privacy Policy',
                            style: AppText.body(13, color: AppColors.textDim, weight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _privacy(BuildContext context) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text('Privacy Policy', style: AppText.display(28)),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Text(
            'This website collects only the details you choose to send through the enquiry form (name, email, company, country, service, project type, budget and project details). '
            'They are used only to reply to your enquiry and discuss your project, and are never sold or shared with third parties.\n\n'
            'Footage and files you share for a project are used only for that project. Work is shown in the portfolio only with permission.\n\n'
            'This site does not use advertising trackers. To ask for your details to be deleted, email ${Contact.email}.',
            style: AppText.body(14.5),
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
    ),
  );
}

class _FooterIcon extends StatefulWidget {
  const _FooterIcon(this.icon, this.label, this.url);
  final IconData icon;
  final String label, url;
  @override
  State<_FooterIcon> createState() => _FooterIconState();
}

class _FooterIconState extends State<_FooterIcon> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.label,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: () => openLink(widget.url),
        child: Semantics(
          link: true,
          label: widget.label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 42,
            height: 42,
            transform: Matrix4.translationValues(0, _h ? -4 : 0, 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _h ? AppColors.red : Colors.transparent,
              border: Border.all(color: _h ? AppColors.red : Colors.white24),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 19),
          ),
        ),
      ),
    ),
  );
}
