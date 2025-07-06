import 'package:flutter/material.dart';

/// Social sign-in button widget for authentication
class SocialSignInButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;

  const SocialSignInButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    iconPath,
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to a generic icon if image not found
                      return Icon(
                        Icons.account_circle,
                        size: 24,
                        color: textColor,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Google sign-in button
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SocialSignInButton(
      text: 'Continue with Google',
      iconPath: 'assets/icons/google_icon.png',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
    );
  }
}

/// Apple sign-in button
class AppleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const AppleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SocialSignInButton(
      text: 'Continue with Apple',
      iconPath: 'assets/icons/apple_icon.png',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}

/// Facebook sign-in button
class FacebookSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const FacebookSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SocialSignInButton(
      text: 'Continue with Facebook',
      iconPath: 'assets/icons/facebook_icon.png',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: const Color(0xFF1877F2),
      textColor: Colors.white,
    );
  }
}

/// Anonymous sign-in button
class AnonymousSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const AnonymousSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SocialSignInButton(
      text: 'Continue as Guest',
      iconPath: 'assets/icons/guest_icon.png',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.grey.shade100,
      textColor: Colors.black87,
    );
  }
}
