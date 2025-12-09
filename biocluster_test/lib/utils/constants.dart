/// Application-wide constants
class AppConstants {
  AppConstants._();

  // API Configuration
  static const String apiUrl = 'https://biocluster.nexiotech.cloud';
  static const Duration apiTimeout = Duration(seconds: 60);

  // Validation Regex
  static final RegExp nucleotideRegex = RegExp(
    r'^[ATCGUatcgu]+$',
    caseSensitive: false,
  );

  static final RegExp proteinRegex = RegExp(
    r'^[ARNDCQEGHILKMFPSTWYVBZXarndcqeghilkmfpstwyvbzx]+$',
    caseSensitive: false,
  );

  // UI Constants
  static const double maxContentWidth = 1200.0;
  static const double cardElevation = 2.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // File Formats
  static const List<String> supportedExportFormats = [
    'TXT',
    'CSV',
    'JSON',
    'Excel',
  ];

  // Default Values
  static const int defaultClusterCount = 3;
  static const int minClusterCount = 2;

  // Messages
  static const String invalidSequenceMessage =
      'Invalid sequence detected. Please check your input.';
  static const String uploadFileMessage =
      'Upload a FASTA file or enter sequences manually';
  static const String processingMessage = 'Processing your sequences...';
  static const String successMessage = 'Analysis completed successfully!';
}
