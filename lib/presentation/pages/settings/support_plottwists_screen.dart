import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../application/services/purchase_service.dart';
import '../../core/app_colors.dart';
import 'widgets/settings_menu_item.dart';
import 'widgets/settings_section.dart';

class SupportPlotTwistsScreen extends ConsumerWidget {
  const SupportPlotTwistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the new provider that lists our IAP products
    final productsAsync = ref.watch(productsProvider);
    final purchaseService = ref.read(purchaseServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Support PlotTwists"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40, top: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.solidHeart,
                    size: 60,
                    color: AppColors.darkErrorRed,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Made with Love",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "PlotTwists is an independent project. Your support helps keep the servers running and new features coming. Thank you for being awesome!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // --- IN-APP PURCHASE SECTION ---
            SettingsSection(
              title: "Show Your Support",
              children: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                FontAwesomeIcons.faceSadTear,
                                size: 40,
                                color: AppColors.darkTextSecondary.withOpacity(
                                  0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Options Unavailable",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Could not load support options.\nPlease check your connection.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  }
                  // Create a list of menu items from the loaded products
                  return products.map((product) {
                    return SettingsMenuItem(
                      icon: FontAwesomeIcons.mugHot,
                      iconColor: Colors.brown.shade300,
                      title: product.title,
                      subtitle: product.description,
                      // Show the formatted price from the store
                      trailing: Text(
                        product.price,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () => purchaseService.buyProduct(product),
                    );
                  }).toList();
                },
                loading: () => [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
                error: (e, s) => [
                  ListTile(title: Text("Error loading support options: $e")),
                ],
              ),
            ),

            // --- SHARE SECTION ---
            SettingsSection(
              title: "Spread the Word",
              children: [
                SettingsMenuItem(
                  icon: FontAwesomeIcons.shareNodes,
                  iconColor: AppColors.auroraPink,
                  title: "Share the App",
                  subtitle: "The best support is sharing with a friend!",
                  onTap: () {
                    const String appLink =
                        "https://play.google.com/store/apps/details?id=com.pranta.plottwist";
                    Share.share(
                      "Check out PlotTwists! It's an awesome app for tracking and discovering movies and TV shows.\n\n$appLink",
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}
