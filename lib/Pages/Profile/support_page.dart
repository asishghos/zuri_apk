import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.black),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: Text(
      //     'Support',
      //     style: GoogleFonts.libreFranklin(
      //       color: Colors.black,
      //       fontSize: MediaQuery.of(context).textScaler.scale(18),
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header Section
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // context.goNamed('myWardrobe');
                          Navigator.pop(context);
                        },
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          color: AppColors.titleTextColor,
                        ),
                      ),
                      SizedBox(width: dw * 0.025),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Support",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.titleTextColor,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(18),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Personal Assistance?',
                      style: GoogleFonts.libreFranklin(
                        color: AppColors.textPrimary,
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.022883295,
                    ),

                    // Illustration Card
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(32),
                      child: Image.asset("assets/images/support/s1.jpg"),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.018306636,
                    ),
                    Text(
                      'If you couldn\'t find the information you need, our support team is ready to assist you.',
                      // textAlign: TextAlign.center,
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        color: AppColors.titleTextColor,
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.036613272,
                    ),

                    Text(
                      'Frequently Asked Questions',
                      style: GoogleFonts.libreFranklin(
                        color: AppColors.textPrimary,
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.018306636,
                    ),

                    // FAQ Items
                    const FAQItem(
                      question: 'How does Zuri generate outfits for me?',
                      answer:
                          'Zuri styles outfits either from the clothes you upload or creates complete looks from scratch based on your input like occasion or weather.',
                      isExpanded: false,
                    ),
                    const FAQItem(
                      question:
                          'Do I need to upload all my clothes to use Zuri?',
                      answer:
                          '''Not at all! You can start by uploading just a few of your favorite pieces. Think of it as curating your virtual wardrobe!
But here's the thing: the more you upload, the more Zuri "gets you". A fuller Zuri closet helps Zuri truly understand your taste and your personal style, which means more personalized outfit suggestions, smarter shopping recommendations, and styling ideas tailored JUST for you 😍
Plus, Zuri shines when it comes to occasion-specific styling- whether it's a wedding, work event, weekend trip, or last-minute date night. With more of your wardrobe in the system, Zuri can plan your looks for upcoming events with precision, making sure you always feel dressed for the moment 🌟
So start small, but know that the more you add, the more powerful and personalized your styling experience becomes.''',
                      isExpanded: false,
                    ),
                    const FAQItem(
                      question: 'Can Zuri suggest looks for specific events?',
                      answer:
                          '''Oh yes, darling! Just give Zuri the full download - the event type, the vibe, the color theme, the venue. Whether it's a destination wedding, an investor pitch, a Sunday brunch or a date that might be something 😉, Zuri will style you head-to-toe for the moment. You give the deets, let Zuri give you the looks! ''',
                      isExpanded: false,
                    ),
                    const FAQItem(
                      question:
                          'What if an outfit suggestion doesn\'t suit my taste?',
                      answer:
                          '''That's totally okay! Even the best stylists need a vibe check sometimes. If a look's not your vibe, just skip it! And don't forget to double-tap ❤ the ones you love, it helps Zuri get to know you (almost) like your fashion bestie 🎀''',
                      isExpanded: false,
                    ),
                    const FAQItem(
                      question: 'Is my wardrobe data safe?',
                      answer:
                          '''Totally. Your wardrobe is your world, and Zuri treats it like a VIP! 🫡 All your uploads and personal style info stay secure and private. Zuri uses top-notch encryption and strict privacy protocols, so your closet secrets stay strictly between you and Zuri ''',
                      isExpanded: false,
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.036613272,
                    ),

                    Text(
                      'Didn\'t Find Any Solution?',
                      style: GoogleFonts.libreFranklin(
                        color: AppColors.textPrimary,
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.009153318,
                    ),
                    Text(
                      'If you haven\'t found the answers you\'re looking for, our support team is here to help, connect with us via Email or call our helpline for immediate assistance.',
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        color: AppColors.titleTextColor,
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.0274599,
                    ),

                    // Contact Options
                    ContactOption(
                      icon: HugeIcons.strokeRoundedMail01,
                      title: 'Email Us',
                      description:
                          'Reach out to our support team via email for detailed assistance and thoughtful solutions to your queries.',
                      buttonText: 'Send Email',
                      onTap: () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'fashionistazuri@gmail.com',
                          query: 'subject=Support Request',
                        );

                        try {
                          await launchUrl(
                            emailLaunchUri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          showErrorSnackBar(
                            context,
                            'Could not launch email app',
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.018306636,
                    ),
                    ContactOption(
                      icon: HugeIcons.strokeRoundedCall02,
                      title: 'Contact Us',
                      description:
                          'Have a question or need assistance? Reach out to dedicated support team we\'re here to help 24/7.',
                      buttonText: 'Call Now',
                      onTap: () async {
                        final Uri telLaunchUri = Uri(
                          scheme: 'tel',
                          path: '+91 9830124000',
                        );

                        try {
                          await launchUrl(
                            telLaunchUri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          showErrorSnackBar(
                            context,
                            'Could not launch phone app',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool isExpanded;

  const FAQItem({
    Key? key,
    required this.question,
    required this.answer,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _isExpanded ? Color(0xFFF9FAFB) : Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.question,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(16),
              fontWeight: FontWeight.w600,
              color: AppColors.titleTextColor,
            ),
          ),
          trailing: HugeIcon(
            icon: _isExpanded
                ? HugeIcons.strokeRoundedArrowUp01
                : HugeIcons.strokeRoundedArrowDown01,
            color: AppColors.titleTextColor,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          initiallyExpanded: widget.isExpanded,
          children: [
            if (widget.answer.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  widget.answer,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Color(0xFF6D717F),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ContactOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const ContactOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFE5E7EA),
              borderRadius: BorderRadius.circular(32),
            ),
            child: HugeIcon(icon: icon, color: AppColors.titleTextColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleTextColor,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.009153318,
                ),
                Text(
                  description,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.013729977,
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    buttonText,
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      color: Color(0xFFE25C7E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
