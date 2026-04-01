import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mesmer_digital_coaching/core/constants/app_colors.dart';
import 'package:mesmer_digital_coaching/core/constants/app_spacing.dart';
import 'package:mesmer_digital_coaching/core/theme/settings_provider.dart';
import 'package:mesmer_digital_coaching/core/widgets/custom_toaster.dart';
import 'package:mesmer_digital_coaching/features/workflow/enterprise/enterprise_document_provider.dart';
import 'package:path/path.dart' as path;

class EvidenceUploadScreen extends ConsumerStatefulWidget {
  final String enterpriseId;
  final String? sessionId;
  final String? taskId;

  const EvidenceUploadScreen({
    super.key,
    required this.enterpriseId,
    this.sessionId,
    this.taskId,
  });

  @override
  ConsumerState<EvidenceUploadScreen> createState() => _EvidenceUploadScreenState();
}

class _EvidenceUploadScreenState extends ConsumerState<EvidenceUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0;
  List<File> _selectedFiles = [];

  Future<void> _pickImage(ImageSource source) async {
    final settings = ref.read(systemSettingsProvider);
    
    // Determine quality from settings
    int? quality;
    if (settings.imageQuality == 'low') quality = 30;
    if (settings.imageQuality == 'medium') quality = 65;
    
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: quality,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (image != null) {
      setState(() {
        _selectedFiles.add(File(image.path));
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFiles.add(File(result.files.single.path!));
      });
    }
  }

  Future<void> _uploadAll() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    final repo = ref.read(enterpriseDocumentRepositoryProvider);
    int completed = 0;

    try {
      for (var file in _selectedFiles) {
        final result = await repo.uploadDocument(
          enterpriseId: widget.enterpriseId,
          sessionId: widget.sessionId,
          filePath: file.path,
          fileName: path.basename(file.path),
          documentType: widget.taskId != null ? 'iap_evidence' : 'evidence',
          onProgress: (sent, total) {
            // This is progress for the current file
            // For simplicity, we just show overall progress based on file count
          },
        );

        result.fold(
          (failure) => CustomToaster.show(context: context, message: 'Failed: ${path.basename(file.path)} - ${failure.message}', isError: true),
          (success) {
            completed++;
            setState(() {
              _uploadProgress = completed / _selectedFiles.length;
            });
          },
        );
      }

      if (mounted) {
        CustomToaster.show(context: context, message: 'Successfully uploaded $completed files.');
        if (completed == _selectedFiles.length) {
          // Clear and refresh
          setState(() {
            _selectedFiles.clear();
            _isUploading = false;
          });
          if (widget.sessionId != null) ref.invalidate(sessionDocumentsProvider(widget.sessionId!));
          ref.invalidate(enterpriseDocumentsProvider(widget.enterpriseId));
          Navigator.pop(context);
        } else {
          setState(() => _isUploading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        CustomToaster.show(context: context, message: 'An error occurred during upload.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attach Evidence', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_isUploading)
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              color: AppColors.primary,
            ),
          Expanded(
            child: _selectedFiles.isEmpty
                ? _buildEmptyState()
                : _buildFileGrid(),
          ),
          _buildActionButtonBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 80, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'No files selected',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'Capture photos of receipts, inventory,\nor site visits as evidence.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFileGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _selectedFiles.length,
      itemBuilder: (context, index) {
        final file = _selectedFiles[index];
        final isImage = ['.jpg', '.jpeg', '.png', '.webp'].contains(path.context.extension(file.path).toLowerCase());

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isImage
                    ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.insert_drive_file, color: Colors.blue, size: 32),
                            const SizedBox(height: 4),
                            Text(
                              path.extension(file.path).toUpperCase().replaceAll('.', ''),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            if (!_isUploading)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFiles.removeAt(index)),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtonBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isUploading)
            Row(
              children: [
                _buildSourceButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 12),
                _buildSourceButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(width: 12),
                _buildSourceButton(
                  icon: Icons.file_present,
                  label: 'File',
                  onTap: _pickFile,
                ),
              ],
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_selectedFiles.isEmpty || _isUploading) ? null : _uploadAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Theme.of(context).disabledColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                _isUploading ? 'UPLOADING...' : 'UPLOAD ${_selectedFiles.length} FILES',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
