import 'package:flutter/material.dart';
import '../../services/logging_service.dart';

/// Production-ready error boundary widget that catches and handles
/// unhandled exceptions in the widget tree to prevent app crashes
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallbackWidget;
  final String? errorContext;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackWidget,
    this.errorContext,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  FlutterErrorDetails? errorDetails;

  @override
  void initState() {
    super.initState();
    
    // Set up error handling for this boundary
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log the error for debugging
      LoggingService.error(
        'Error caught by ErrorBoundary: ${details.exception}',
        tag: widget.errorContext ?? 'ErrorBoundary',
        error: details.exception,
        stackTrace: details.stack,
      );
      
      // Update state to show error UI
      if (mounted) {
        setState(() {
          hasError = true;
          errorDetails = details;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return widget.fallbackWidget ?? _buildDefaultErrorWidget();
    }
    
    return widget.child;
  }

  Widget _buildDefaultErrorWidget() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Oops! Something went wrong',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'re sorry, but something unexpected happened. Our team has been notified and is working on a fix.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          hasError = false;
                          errorDetails = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Navigate back to home or restart app
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Go Home'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Reset error handler when boundary is disposed
    FlutterError.onError = FlutterError.presentError;
    super.dispose();
  }
}

/// Widget-level error boundary for wrapping specific components
class WidgetErrorBoundary extends StatelessWidget {
  final Widget child;
  final String componentName;
  
  const WidgetErrorBoundary({
    super.key,
    required this.child,
    required this.componentName,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      errorContext: componentName,
      fallbackWidget: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading $componentName',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // Force rebuild by navigating back and forth
                Navigator.of(context).pushReplacementNamed(
                  Navigator.of(context).widget.runtimeType.toString(),
                );
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}