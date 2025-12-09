import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../app_theme.dart';

/// File upload widget with drag and drop area
class FileUploadWidget extends StatelessWidget {
  final VoidCallback onUpload;
  final bool isLoading;

  const FileUploadWidget({
    Key? key,
    required this.onUpload,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(16),
      color: AppTheme.primaryLight,
      strokeWidth: 2,
      dashPattern: const [8, 4],
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: AppTheme.primaryLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Upload FASTA File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click to browse or drag and drop your file here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isLoading ? null : onUpload,
              icon:
                  isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.file_upload),
              label: Text(isLoading ? 'Loading...' : 'Browse Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
