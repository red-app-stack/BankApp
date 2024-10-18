import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_extension.dart';

Widget buildTextInput(
  TextEditingController controller,
  String hint, {
  String iconType = 'none',
  bool isPassword = false,
  bool activeIcon = false,
  bool enabled = true,
  List<TextInputFormatter>? inputFormatters,
  TextInputType keyboardType = TextInputType.text,
  required BuildContext context,
  FocusNode? currentFocus,
  FocusNode? nextFocus,
  VoidCallback? onIconPressed,
}) {
  activeIcon = isPassword ? isPassword : activeIcon;

  return StatefulBuilder(
    builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextField(
          controller: controller,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: hint,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.outline, // Unselected color
              fontWeight: FontWeight.normal,
            ),
            floatingLabelStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .inverseSurface, // Selected color
              fontWeight: FontWeight.bold,
            ),
            hintStyle: Theme.of(context).textTheme.bodyMedium,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                  width: 1.5, color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                  width: 2.0,
                  color: Theme.of(context).colorScheme.inverseSurface),
            ),
            // Use a suffixIcon based on the iconType
            suffixIcon: _buildSuffixIcon(
              iconType,
              activeIcon,
              context,
              onPressed: () {
                if (iconType == 'password') {
                  setState(() {
                    activeIcon = !activeIcon; // Toggle password visibility
                  });
                } else if (onIconPressed != null) {
                  onIconPressed();
                  if (iconType == 'delete') {
                    setState(() {
                      activeIcon = false; // Toggle password visibility
                    });
                  }
                }
              },
            ),
          ),
          autofillHints: _getAutofillHints(iconType),
          keyboardType: keyboardType,
          obscureText: isPassword && activeIcon,
          focusNode: currentFocus,
          enabled: enabled,
          inputFormatters: inputFormatters,
          textInputAction:
              nextFocus != null ? TextInputAction.next : TextInputAction.done,
          onEditingComplete: () {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
        ),
      );
    },
  );
}

List<String> _getAutofillHints(String iconType) {
  switch (iconType) {
    case 'email':
      return [AutofillHints.username, AutofillHints.email];
    case 'password':
      return [AutofillHints.password];
    case 'profile':
      return [AutofillHints.name];
    default:
      return [];
  }
}

Widget? _buildSuffixIcon(String iconType, bool activeIcon, BuildContext context,
    {required VoidCallback onPressed}) {
  switch (iconType) {
    case 'password':
      return IconButton(
        icon: Icon(
          activeIcon ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed,
      );
    case 'profile':
      return IconButton(
        icon: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed, // Profile icon might have some action
      );
    case 'edit':
      return IconButton(
        icon: Icon(
          Icons.edit,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed, // Action for editing can be handled
      );
    case 'email':
      return IconButton(
        icon: Icon(
          Icons.email,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed, // Action for editing can be handled
      );
    case 'delete':
      return activeIcon
          ? IconButton(
              icon: Icon(Icons.delete,
                  color: Theme.of(context).colorScheme.error),
              onPressed: onPressed, // Action for deleting the input
            )
          : IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: onPressed, // Action for editing can be handled
            );
    case 'search':
      return IconButton(
        icon: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed, // Action for searching
      );
    case 'clear':
      return IconButton(
        icon: Icon(
          Icons.clear,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed, // Action to clear input
      );
    case 'check':
      return IconButton(
        icon: Icon(
          Icons.check,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: onPressed, // Action for confirming
      );
    case 'dropdown':
      return IconButton(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed, // Action for showing dropdown
      );
    case 'camera':
      return IconButton(
        icon: Icon(
          Icons.camera_alt,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed, // Action for camera/photo upload
      );
    case 'attach':
      return IconButton(
        icon: Icon(
          Icons.attach_file,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed, // Action to attach a file
      );
    case 'mic':
      return IconButton(
        icon: Icon(
          Icons.mic,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed, // Action for voice input
      );
    case 'send':
      return IconButton(
        icon: Icon(
          Icons.send,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: onPressed, // Action for sending data
      );
    case 'calendar':
      return IconButton(
        icon: Icon(
          Icons.calendar_today,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onPressed, // Action for sending data
      );
    case 'none':
    default:
      return null; // No icon
  }
}

Widget buildSignInText(String text, String actionText, BuildContext context,
    VoidCallback onSignInPressed) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text, style: Theme.of(context).textTheme.bodyMedium),
      TextButton(
        onPressed: onSignInPressed,
        child: Text(
          actionText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
        ),
      ),
    ],
  );
}

Widget buildBackground(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Theme.of(context).extension<CustomColors>()!.backgroundGradientStart!,
          Theme.of(context).extension<CustomColors>()!.backgroundGradientEnd!,
        ],
      ),
    ),
  );
}

Widget fakeHero({required String tag, required Widget child}) {
  return Hero(
    tag: tag,
    child: Material(
      color: Colors.transparent,
      child: child,
    ),
    flightShuttleBuilder: (_, __, ___, ____, _____) {
      return Material(
        color: Colors.transparent,
        child: child,
      );
    },
  );
}
