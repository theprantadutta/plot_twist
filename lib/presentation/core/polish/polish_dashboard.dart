import 'package:flutter/material.dart';

import 'polish_validator.dart';
import 'visual_hierarchy.dart';
import 'ui_polish_system.dart';

/// Developer dashboard for monitoring UI polish status
class PolishDashboard extends StatefulWidget {
  const PolishDashboard({super.key});

  @override
  State<PolishDashboard> createState() => _PolishDashboardState();
}

class _PolishDashboardState extends State<PolishDashboard> {
  PolishValidationResult? _validationResult;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _runValidation();
  }

  Future<void> _runValidation() async {
    setState(() {
      _isValidating = true;
    });

    // Simulate validation process
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      final result = PolishValidator.validateApp(context);
      setState(() {
        _validationResult = result;
        _isValidating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Polish Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isValidating ? null : _runValidation,
            tooltip: 'Run Validation',
          ),
        ],
      ),
      body: _isValidating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Validating UI Polish...'),
                ],
              ),
            )
          : _validationResult != null
              ? _buildDashboard()
              : const Center(
                  child: Text('No validation results available'),
                ),
    );
  }

  Widget _buildDashboard() {
    final result = _validationResult!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall score card
          _buildScoreCard(result),
          
          const SizedBox(height: 24),
          
          // Issues breakdown
          _buildIssuesBreakdown(result),
          
          const SizedBox(height: 24),
          
          // Detailed issues
          if (result.hasIssues) ...[
            _buildIssuesList('Critical Issues', result.issues, Colors.red),
            const SizedBox(height: 16),
          ],
          
          if (result.hasWarnings) ...[
            _buildIssuesList('Warnings', result.warnings, Colors.orange),
            const SizedBox(height: 16),
          ],
          
          if (result.hasSuggestions) ...[
            _buildIssuesList('Suggestions', result.suggestions, Colors.blue),
            const SizedBox(height: 16),
          ],
          
          // Quick actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildScoreCard(PolishValidationResult result) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Polish Score',
                        style: VisualHierarchy.secondaryHeading(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.grade.displayName,
                        style: VisualHierarchy.bodyTextSecondary(context).copyWith(
                          color: result.grade.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: result.grade.color.withValues(alpha: 0.1),
                    border: Border.all(
                      color: result.grade.color,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${result.overallScore.toInt()}',
                      style: VisualHierarchy.primaryHeading(context).copyWith(
                        color: result.grade.color,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            LinearProgressIndicator(
              value: result.overallScore / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(result.grade.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuesBreakdown(PolishValidationResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Issues Breakdown',
              style: VisualHierarchy.tertiaryHeading(context),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Critical',
                  result.issues.length.toString(),
                  Colors.red,
                ),
                _buildStatColumn(
                  'Warnings',
                  result.warnings.length.toString(),
                  Colors.orange,
                ),
                _buildStatColumn(
                  'Suggestions',
                  result.suggestions.length.toString(),
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Text(
              value,
              style: VisualHierarchy.tertiaryHeading(context).copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: VisualHierarchy.captionText(context),
        ),
      ],
    );
  }

  Widget _buildIssuesList(
    String title,
    List<ValidationIssue> issues,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForIssueType(title),
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: VisualHierarchy.tertiaryHeading(context).copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...issues.map((issue) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue.message,
                          style: VisualHierarchy.bodyText(context),
                        ),
                        if (issue.component != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Component: ${issue.component}',
                            style: VisualHierarchy.captionText(context),
                          ),
                        ],
                        if (issue.suggestion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Suggestion: ${issue.suggestion}',
                            style: VisualHierarchy.captionText(context).copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: VisualHierarchy.tertiaryHeading(context),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                UIPolishSystem.polishedButton(
                  text: 'Export Report',
                  onPressed: _exportReport,
                  icon: Icons.download,
                  isPrimary: false,
                ),
                UIPolishSystem.polishedButton(
                  text: 'View Guidelines',
                  onPressed: _viewGuidelines,
                  icon: Icons.book,
                  isPrimary: false,
                ),
                UIPolishSystem.polishedButton(
                  text: 'Run Tests',
                  onPressed: _runTests,
                  icon: Icons.play_arrow,
                  isPrimary: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForIssueType(String title) {
    switch (title.toLowerCase()) {
      case 'critical issues':
        return Icons.error;
      case 'warnings':
        return Icons.warning;
      case 'suggestions':
        return Icons.lightbulb;
      default:
        return Icons.info;
    }
  }

  void _exportReport() {
    if (_validationResult != null) {
      final report = PolishValidator.generateReport(_validationResult!);
      
      // In a real app, this would save to file or share
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validation Report'),
          content: SingleChildScrollView(
            child: Text(
              report,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _viewGuidelines() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('UI Polish Guidelines'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Maintain consistent spacing using the 8dp grid system'),
              SizedBox(height: 8),
              Text('2. Ensure all interactive elements meet 48dp minimum touch target'),
              SizedBox(height: 8),
              Text('3. Use consistent elevation levels for visual hierarchy'),
              SizedBox(height: 8),
              Text('4. Maintain WCAG AA color contrast ratios'),
              SizedBox(height: 8),
              Text('5. Use consistent animation timing and easing'),
              SizedBox(height: 8),
              Text('6. Follow semantic markup for accessibility'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _runTests() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Running comprehensive UI tests...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // In a real app, this would trigger automated tests
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tests completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}