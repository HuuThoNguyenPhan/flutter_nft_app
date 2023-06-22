// Future<void> _launchApp() async {
//   final bool isInstalled = await LaunchApp.isAppInstalled(
//     androidPackageName: metaMaskPackageName,
//     iosUrlScheme: metamaskWalletScheme,
//   );
//
//   /// If there is an exisitng app, just launch the app.
//   if (isInstalled) {
//     if (!mounted) return;
//     context.read<AuthCubit>().loginWithMetamask();
//     return;
//   }
//
//   /// If there is no exisitng app, launch app store.
//   await LaunchApp.openApp(
//     androidPackageName: metaMaskPackageName,
//     iosUrlScheme: metamaskWalletScheme,
//     appStoreLink: metamaskAppsStoreLink,
//   );
// }