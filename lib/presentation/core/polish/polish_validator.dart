import 'package:flutter/material.dart';

import 'accessibility_system.dart';
import 'visual_hierarchy.dart';
import 'ui_polish_system.dart';

/// Comprehensive validation tool for UI polish and consistency
class PolishValidator {
  // --- VALIDATION RESULTS ---
  
  static PolishValidationResult validateApp(BuildContext context) {
    final issues = <ValidationIssue>[];
    final warnings = <ValidationIssue>[];
    final suggestions = <ValidationIssue>[];

    // Validate accessibility
    final accessibilityReport = _validateAccessibility(context);
    issues.addAll(accessibilityReport.issues.map((issue) => 
        ValidationIssue(type: IssueType.accessibility, message: issue)));

    // Validate visual hierarchy
    final hierarchyIssues = _validateVisualHierarchy(context);
    issues.addAll(hierarchyIssues.map((issue) => 
        ValidationIssue(type: IssueType.hierarchy, message: issue)));

    // Validate animation performance
    final animationIssues = _validateAnimationPerformance();
    warnings.addAll(animationIssues.map((issue) => 
        ValidationIssue(type: IssueType.performance, message: issue)));

    // Validate component consistency
    final consistencyIssues = _validateComponentConsistency(context);
    suggestions.addAll(consistencyIssues.map((issue) => 
        ValidationIssue(type: IssueType.consistency, message: issue)));

    // Validate spacing consistency
    final spacingIssues = _validateSpacingConsistency();
    suggestions.addAll(spacingIssues.map((issue) => 
        ValidationIssue(type: IssueType.spacing, message: issue)));

    return PolishValidationResult(
      issues: issues,
      warnings: warnings,
      suggestions: suggestions,
      overallScore: _calculateOverallScore(issues, warnings, suggestions),
    );
  }

  // --- PRIVATE VALIDATION METHODS ---

  static AccessibilityReport _validateAccessibility(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AccessibilitySystem.getColorSchemeReport(colorScheme);
  }

  static List<String> _validateVisualHierarchy(BuildContext context) {
    final issues = <String>[];
    
    // Check text scale factors
    final textTheme = Theme.of(context).textTheme;
    
    final headlineLarge = textTheme.headlineLarge?.fontSize ?? 32;
    final headlineMedium = textTheme.headlineMedium?.fontSize ?? 28;
    final headlineSmall = textTheme.headlineSmall?.fontSize ?? 24;
    final bodyLarge = textTheme.bodyLarge?.fontSize ?? 16;
    
    if (headlineLarge <= headlineMedium) {
      issues.add('Headline large should be larger than headline medium');
    }
    
    if (headlineMedium <= headlineSmall) {
      issues.add('Headline medium should be larger than headline small');
    }
    
    if (headlineSmall <= bodyLarge) {
      issues.add('Headlines should be larger than body text');
    }

    // Check color contrast in hierarchy
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    
    final primaryContrast = AccessibilitySystem.getContrastRatio(onSurface, surface);
    if (primaryContrast < AccessibilitySystem.minContrastRatioNormal) {
      issues.add('Primary text contrast is insufficient for accessibility');
    }

    return issues;
  }

  static List<String> _validateAnimationPerformance() {
    final issues = <String>[];
    
    // Check animation durations
    if (UIPolishSystem.standardDuration.inMilliseconds > 500) {
      issues.add('Standard animation duration may be too long for good UX');
    }
    
    if (UIPolishSystem.microDuration.inMilliseconds > 150) {
      issues.add('Micro animation duration should be under 150ms');
    }

    return issues;
  }

  static List<String> _validateComponentConsistency(BuildContext context) {
    final issues = <String>[];
    
    // Check button consistency
    final elevatedButtonTheme = Theme.of(context).elevatedButtonTheme;
    final textButtonTheme = Theme.of(context).textButtonTheme;
    
    if (elevatedButtonTheme.style == null) {
      issues.add('Elevated button theme should be defined for consistency');
    }
    
    if (textButtonTheme.style == null) {
      issues.add('Text button theme should be defined for consistency');
    }

    // Check card consistency
    final cardTheme = Theme.of(context).cardTheme;
    if (cardTheme.shape == null) {
      issues.add('Card shape should be defined for consistency');
    }

    return issues;
  }

  static List<String> _validateSpacingConsistency() {
    final issues = <String>[];
    
    // Check if spacing follows 8dp grid
    final spacingValues = [
      VisualHierarchy.spacingXS,
      VisualHierarchy.spacingS,
      VisualHierarchy.spacingM,
      VisualHierarchy.spacingL,
      VisualHierarchy.spacingXL,
    ];
    
    for (final spacing in spacingValues) {
      if (spacing % 4 != 0) {
        issues.add('Spacing value $spacing should follow 4dp grid system');
      }
    }

    return issues;
  }

  static double _calculateOverallScore(
    List<ValidationIssue> issues,
    List<ValidationIssue> warnings,
    List<ValidationIssue> suggestions,
  ) {
    const maxScore = 100.0;
    const issueWeight = 10.0;
    const warningWeight = 5.0;
    const suggestionWeight = 2.0;
    
    final deductions = (issues.length * issueWeight) +
                      (warnings.length * warningWeight) +
                      (suggestions.length * suggestionWeight);
    
    return (maxScore - deductions).clamp(0.0, maxScore);
  }

  // --- SPECIFIC COMPONENT VALIDATORS ---

  static List<ValidationIssue> validateButton(
    BuildContext context,
    Widget button,
  ) {
    final issues = <ValidationIssue>[];
    
    // Check if button meets minimum touch target size
    // This would require widget testing framework to measure actual size
    
    return issues;
  }

  static List<ValidationIssue> validateCard(
    BuildContext context,
    Widget card,
  ) {
    final issues = <ValidationIssue>[];
    
    // Validate card elevation and styling
    // This would require access to card properties
    
    return issues;
  }

  static List<ValidationIssue> validateTextField(
    BuildContext context,
    Widget textField,
  ) {
    final issues = <ValidationIssue>[];
    
    // Validate text field accessibility and styling
    // This would require access to text field properties
    
    return issues;
  }

  // --- UTILITY METHODS ---

  static String generateReport(PolishValidationResult result) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== UI Polish Validation Report ===');
    buffer.writeln('Overall Score: ${result.overallScore.toStringAsFixed(1)}/100');
    buffer.writeln();
    
    if (result.issues.isNotEmpty) {
      buffer.writeln('CRITICAL ISSUES (${result.issues.length}):');
      for (final issue in result.issues) {
        buffer.writeln('❌ [${issue.type.name.toUpperCase()}] ${issue.message}');
      }
      buffer.writeln();
    }
    
    if (result.warnings.isNotEmpty) {
      buffer.writeln('WARNINGS (${result.warnings.length}):');
      for (final warning in result.warnings) {
        buffer.writeln('⚠️  [${warning.type.name.toUpperCase()}] ${warning.message}');
      }
      buffer.writeln();
    }
    
    if (result.suggestions.isNotEmpty) {
      buffer.writeln('SUGGESTIONS (${result.suggestions.length}):');
      for (final suggestion in result.suggestions) {
        buffer.writeln('💡 [${suggestion.type.name.toUpperCase()}] ${suggestion.message}');
      }
      buffer.writeln();
    }
    
    if (result.issues.isEmpty && result.warnings.isEmpty) {
      buffer.writeln('✅ No critical issues found!');
    }
    
    buffer.writeln('=== End Report ===');
    
    return buffer.toString();
  }

  static PolishGrade getGrade(double score) {
    if (score >= 95) return PolishGrade.excellent;
    if (score >= 85) return PolishGrade.good;
    if (score >= 70) return PolishGrade.fair;
    if (score >= 50) return PolishGrade.poor;
    return PolishGrade.failing;
  }
}

// --- DATA CLASSES ---

class PolishValidationResult {
  final List<ValidationIssue> issues;
  final List<ValidationIssue> warnings;
  final List<ValidationIssue> suggestions;
  final double overallScore;

  const PolishValidationResult({
    required this.issues,
    required this.warnings,
    required this.suggestions,
    required this.overallScore,
  });

  bool get hasIssues => issues.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasSuggestions => suggestions.isNotEmpty;
  
  PolishGrade get grade => PolishValidator.getGrade(overallScore);
}

class ValidationIssue {
  final IssueType type;
  final String message;
  final String? component;
  final String? suggestion;

  const ValidationIssue({
    required this.type,
    required this.message,
    this.component,
    this.suggestion,
  });
}

enum IssueType {
  accessibility,
  hierarchy,
  performance,
  consistency,
  spacing,
  color,
  typography,
}

enum PolishGrade {
  excellent,
  good,
  fair,
  poor,
  failing,
}

extension PolishGradeExtension on PolishGrade {
  String get displayName {
    switch (this) {
      case PolishGrade.excellent:
        return 'Excellent';
      case PolishGrade.good:
        return 'Good';
      case PolishGrade.fair:
        return 'Fair';
      case PolishGrade.poor:
        return 'Poor';
      case PolishGrade.failing:
        return 'Failing';
    }
  }

  Color get color {
    switch (this) {
      case PolishGrade.excellent:
        return Colors.green;
      case PolishGrade.good:
        return Colors.lightGreen;
      case PolishGrade.fair:
        return Colors.orange;
      case PolishGrade.poor:
        return Colors.deepOrange;
      case PolishGrade.failing:
        return Colors.red;
    }
  }
}