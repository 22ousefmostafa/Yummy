import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;

  const AuthScaffold({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = false,
    this.appBar,
    this.backgroundColor,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = Align(
              alignment:
                  centerContent ? Alignment.center : Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.authMaxWidth(context),
                ),
                child: Padding(
                  padding: padding ??
                      EdgeInsets.symmetric(
                        horizontal: Responsive.horizontalPadding(context),
                        vertical: Responsive.gapMD(context),
                      ),
                  child: child,
                ),
              ),
            );

            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }
}