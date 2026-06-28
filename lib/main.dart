import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/toast_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/toast_overlay.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/login_screen.dart';
import 'screens/onboarding/register_screen.dart';
import 'screens/onboarding/forgot_password_screen.dart';
import 'screens/user/main_shell.dart';
import 'screens/product_detail_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/order_success_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/store_map_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/shipping_addresses_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/admin/product_form_screen.dart';
import 'screens/admin/revenue_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PopiDigicamApp());
}

class PopiDigicamApp extends StatelessWidget {
  const PopiDigicamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ToastProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isLoading) {
            final userId = auth.user?.id;
            context.read<CartProvider>().setUser(userId);
            context.read<WishlistProvider>().setUser(userId);
            context.read<NotificationProvider>().setUser(userId);
            context.read<ChatProvider>().setUser(userId);
          }
          return const _App();
        },
      ),
    );
  }
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    final toast = context.read<ToastProvider>();
    return MaterialApp(
      title: 'PopiDigicam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
      builder: (context, child) {
        return ToastHost(
          provider: toast,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final uri = Uri.parse(name);
    final segments = uri.pathSegments;

    switch (name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const _AuthGate());
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 0));
      case '/explore':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => MainShell(
          initialIndex: 1,
          exploreQuery: args?['q'] as String?,
          exploreOpenFilter: args?['openFilter'] as bool?,
        ));
      case '/cart':
        return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 2));
      case '/orders':
        return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 3));
      case '/profile':
        return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 4));
      case '/checkout':
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case '/order-success':
        return MaterialPageRoute(builder: (_) => const OrderSuccessScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case '/store-map':
        return MaterialPageRoute(builder: (_) => const StoreMapScreen());
      case '/chat':
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      case '/wishlist':
        return MaterialPageRoute(builder: (_) => const WishlistScreen());
      case '/edit-profile':
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case '/payment-methods':
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());
      case '/shipping-addresses':
        return MaterialPageRoute(builder: (_) => const ShippingAddressesScreen());
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminShell());
      case '/admin/revenue':
        return MaterialPageRoute(builder: (_) => const RevenueScreen());
    }

    // Dynamic routes
    if (segments.length == 2 && segments[0] == 'product') {
      final id = int.tryParse(segments[1]);
      if (id != null) return MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: id));
    }
    if (segments.length == 2 && segments[0] == 'order') {
      final id = int.tryParse(segments[1]);
      if (id != null) return MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: id));
    }
    if (segments.length == 3 && segments[0] == 'admin' && segments[1] == 'product') {
      return MaterialPageRoute(builder: (_) => ProductFormScreen(productId: segments[2]));
    }

    return MaterialPageRoute(builder: (_) => const _AuthGate());
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.isAuthenticated) {
      if (auth.isAdmin) {
        return const AdminShell();
      } else {
        return const MainShell();
      }
    }

    return const SplashScreen();
  }
}
