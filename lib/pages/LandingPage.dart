import 'package:digirider/global/Common.dart';
import 'package:digirider/pages/GoogleSignInUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/show_exit_dialog.dart';


class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitConfirmationDialogWhite(context),
      child: Scaffold(
        backgroundColor: Common.secondary,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 60,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Text(
              "Digital Rider",
              style: TextStyle(fontSize: 20, fontFamily: 'bold'),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GoogleLoginPage(),),),
                },
                child: Card(
                  elevation: 4,
                  shadowColor: Common.primary,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Common.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: Common.h2,
                          fontFamily: 'bold',
                          color: Common.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.black,
                ],
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 16, left: 16, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle1("Welcome to Digital Rider"),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.zero,
                        child: _buildHeroSection(),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Where Do We Get Orders"),
                      const SizedBox(height: 16),
                      // _buildOrderSources(),
                      const OrderSourcesSection(),

                      const SizedBox(height: 10),
                      _buildSectionTitle("Onboarding Process"),
                      const SizedBox(height: 16),
                      _buildOnboardingSteps(),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Benefits of Being a Digital Rider"),
                      const SizedBox(height: 20),
                      _buildBenefits(),
                      const SizedBox(height: 20),
                      _buildSectionTitle("About Us"),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.deepPurple.withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "We empower businesses by connecting them with reliable riders for seamless order fulfillment and delivery.",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'bold',
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Common.secondary,
          height: 0,
          child: const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Card(
      elevation: 6,
      color: Common.secondary,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Common.secondary,
          borderRadius: BorderRadius.circular(14)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _animatedFeatureCard(
              index: 0,
              isFullWidth: true,
              color: Colors.indigo,
              descWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6,),
                  _featureRow(
                    icon: Icons.currency_rupee,
                    title: "Earn 1000 per day",
                    desc: "Daily earning potential with reliable orders.",
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _featureRow(
                    icon: Icons.directions_bike,
                    title: "Drive Any Vehicle",
                    desc: "Auto, Bike, Car, or Taxi — earn with what you have.",
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 12),
                  _featureRow(
                    icon: Icons.check_circle,
                    title: "3-Step Onboarding",
                    desc: "Start earning quickly with our fast onboarding.",
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
            SizedBox(height: 6,),
          ],
        ),
      ),
    );
  }

  Widget _animatedFeatureCard({
    required int index,
    required Color color,
    required bool isFullWidth,
    Widget? descWidget,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: descWidget ?? const SizedBox(),
    );
  }

  Widget _featureRow({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Row(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white, // changed from white
                  fontFamily: 'bold',
                  fontSize: Common.h2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(color: Colors.white60, fontSize: Common.h3, fontFamily: 'bold'), // changed from white70
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'bold',
          fontWeight: FontWeight.bold,
          color: Common.secondary,
        ),
      ),
    );
  }

  Widget _buildSectionTitle1(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          fontFamily: 'bold',
          letterSpacing: 1.3,
        ),
      ),
    );
  }


  Widget _buildOnboardingSteps() {
    final List<Map<String, dynamic>> steps = [
      {
        "title": "Basic Info",
        "desc":
            "Provide your basic information including name, contact details, and address.",
        "icon": Icons.person,
        "color": Colors.indigo,
      },
      {
        "title": "Documents",
        "desc": "Upload Aadhar, Driving License, Payment QR and Profile Image.",
        "icon": Icons.file_copy,
        "color": Colors.purple,
      },
      {
        "title": "Verification",
        "desc":
            "We’ll notify you once your documents are verified. Physical card is given.",
        "icon": Icons.verified_user,
        "color": Colors.pink,
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return _animatedOnboardingCard(
          index: index,
          title: step['title'],
          desc: step['desc'],
          icon: step['icon'],
          color: step['color'],
        );
      }),
    );
  }

  Widget _animatedOnboardingCard({
    required int index,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'bold',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    final List<Map<String, dynamic>> benefits = [
      {
        "title": "Flexible Schedule",
        "desc": "Freedom to choose your working hours.",
        "icon": Icons.schedule,
        "color": Colors.indigo,
      },
      {
        "title": "Competitive Earnings",
        "desc": "Earn more with bonuses and incentives.",
        "icon": Icons.monetization_on,
        "color": Colors.purple,
      },
      {
        "title": "Regular Orders",
        "desc": "Consistent income from steady orders.",
        "icon": Icons.list_alt,
        "color": Colors.pink,
      },
      {
        "title": "Supportive Community",
        "desc": "Rider support system always ready.",
        "icon": Icons.people_alt,
        "color": Colors.blue,
      },
      {
        "title": "Training and Development",
        "desc": "Improve your skills and stay updated.",
        "icon": Icons.school,
        "color": Colors.teal,
      },
      {
        "title": "Health and Safety",
        "desc": "We prioritize your health and safety.",
        "icon": Icons.health_and_safety,
        "color": Colors.green,
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(benefits.length, (index) {
        final item = benefits[index];
        return _animatedBenefitCard(
          index: index,
          title: item['title'],
          desc: item['desc'],
          icon: item['icon'],
          color: item['color'],
        );
      }),
    );
  }

  Widget _animatedBenefitCard({
    required int index,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return Transform.translate(offset: offset * 100, child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: MediaQuery.of(context).size.width / 2 - 24,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'bold',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard(
    String title,
    String desc,
    IconData icon,
    Color borderColor,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: borderColor, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'bold',
          ),
        ),
        subtitle: Text(desc),
      ),
    );
  }

  void _launchUrl(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    try {
      final canLaunchIt = await canLaunchUrl(uri);
      if (!canLaunchIt) {
        throw 'Cannot launch $url';
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // You can show a snackbar or alert if needed.
    }
  }



  Widget _buildFooter() {
    return Container(

      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Text(
            "Digital Rider",
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'bold',
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),

          // Contact Info
          _infoRow(Icons.call, "+91 9461852060", Colors.greenAccent),
          const SizedBox(height: 10),
          _infoRow(Icons.email, "humansofruralindia@gmail.com", Colors.redAccent),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on, "7 Siyag House, Gotan, Rajasthan 342902", Colors.amberAccent),
          const SizedBox(height: 20),

          // Social Icons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                InkWell(
                  onTap: () => _launchUrl('https://www.facebook.com/humansofruralindia/'),
                  child: _socialIcon(FontAwesomeIcons.facebookF, Colors.white),
                ),
                const SizedBox(width: 14),
                InkWell(
                  onTap: () => _launchUrl('https://www.linkedin.com/company/humans-of-rural-india/'),
                  child: _socialIcon(FontAwesomeIcons.linkedinIn, Colors.white),
                ),
                const SizedBox(width: 14),
                InkWell(
                  onTap: () => _launchUrl('https://www.instagram.com/digistallapp/'),
                  child: _socialIcon(FontAwesomeIcons.instagram, Colors.white),
                ),
                const SizedBox(width: 14),
                InkWell(
                  onTap: () => _launchUrl('https://x.com/DigistallApp'),
                  child: _socialIcon(FontAwesomeIcons.xTwitter, Colors.white),
                ),
                const SizedBox(width: 14),
                InkWell(
                  onTap: () => _launchUrl('https://www.youtube.com/@digistall'),
                  child: _socialIcon(FontAwesomeIcons.youtube, Colors.white),
                ),
              ],
            ),
          ),


          const SizedBox(height: 10),
          const Divider(color: Colors.white24),
          const SizedBox(height: 5),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _footerChip(Icons.mail_outline, "Newsletter", () => _launchUrl("https://digistall.substack.com/"),),
              _footerChip(Icons.privacy_tip_outlined, "Privacy Policy", () => _launchUrl("https://gotan.in/privacy-policy-rider"),),
              _footerChip(Icons.article_outlined, "Terms & Conditions", () => _launchUrl("https://digistall.in/terms_and_conditions"),),
            ],
          ),


          const SizedBox(height: 12),

          // Legal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Siyag Rural Market Private Limited © Digistall",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "CIN: U52100RJ2021PTC077111",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "GSTIN: 08ABGCS8909L1ZN",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerChip(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(color: Colors.white, fontSize: Common.h3)),
          ],
        ),
      ),
    );
  }



  Widget _infoRow(IconData icon, String text, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white12,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }



}

class OrderSourcesSection extends StatefulWidget {
  const OrderSourcesSection({super.key});

  @override
  State<OrderSourcesSection> createState() => _OrderSourcesSectionState();
}

class _OrderSourcesSectionState extends State<OrderSourcesSection>
    with TickerProviderStateMixin {
  late final AnimationController _controller1 = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final AnimationController _controller2 = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  bool _expanded1 = false;
  bool _expanded2 = false;

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _toggleExpanded(int index) {
    setState(() {
      if (index == 1) {
        _expanded1 = !_expanded1;
        _expanded1 ? _controller1.forward() : _controller1.reverse();
      } else {
        _expanded2 = !_expanded2;
        _expanded2 ? _controller2.forward() : _controller2.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAnimatedStepCard(
          title: "Orders from Gotan Store app",
          expanded: _expanded1,
          onTap: () => _toggleExpanded(1),
          controller: _controller1,
          children: [
            _buildSubItem("Pick and Drop Person", Colors.indigo, Colors.blue),
            _buildSubItem("Pick and Drop Parcel", Colors.purple, Colors.pink),
            SizedBox(height: 15,),
          ],
        ),
        const SizedBox(height: 2),
        _buildAnimatedStepCard(
          title: "Orders from Digistall",
          expanded: _expanded2,
          onTap: () => _toggleExpanded(2),
          controller: _controller2,
          children: [
            _buildSubItem(
              "Deliver Digistall Store Order and Earn commission",
              Colors.green,
              Colors.teal,
            ),
            SizedBox(height: 15,),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedStepCard({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required AnimationController controller,
    required List<Widget> children,
  }) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    final fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Common.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 12,
                left: 20,
                right: 20,
              ),
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [Colors.white, Colors.white],
                        ).createShader(bounds);
                      },
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: Common.h2,
                          color: Colors.white,
                          fontFamily: 'bold',
                          fontWeight: Common.weight2
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: fadeAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: Column(children: children),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubItem(String text, Color color1, Color color2) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      // padding: const EdgeInsets.symmetric(),
      decoration: BoxDecoration(
        color: Common.secondary, // your dark secondary color
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_right_alt, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontFamily: 'bold', fontSize: Common.h2, fontWeight: Common.weight2),
            ),
          ),
        ],
      ),
    );
  }
}
