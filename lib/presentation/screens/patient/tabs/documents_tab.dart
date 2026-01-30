// File: lib/presentation/screens/patient/tabs/documents_tab.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/models.dart';
import '../../../../providers/providers.dart';
import '../../../widgets/ui_components.dart';

/// Documents Tab for Patient Details with Material Design 3
class DocumentsTab extends StatefulWidget {
  final PatientModel patient;

  const DocumentsTab({super.key, required this.patient});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  bool _isGridView = true;
  bool _isUploading = false;

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'dicom':
        return Icons.medical_services;
      case 'xml':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.blue;
      case 'doc':
      case 'docx':
        return Colors.indigo;
      case 'dicom':
        return Colors.teal;
      case 'xml':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _uploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
          'dicom',
          'xml',
        ],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isUploading = true);

        final patientProvider = context.read<PatientProvider>();

        for (final file in result.files) {
          if (file.path != null) {
            await patientProvider.uploadDocument(
              patientId: widget.patient.id,
              file: File(file.path!),
              fileName: file.name,
            );
          }
        }

        Fluttertoast.showToast(
          msg: 'Documents uploaded successfully',
          backgroundColor: AppTheme.success,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to upload documents',
        backgroundColor: AppTheme.error,
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _viewDocument(PatientDocument document) async {
    final Uri url = Uri.parse(document.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(
        msg: 'Could not open document',
        backgroundColor: AppTheme.error,
      );
    }
  }

  Future<void> _deleteDocument(PatientDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<PatientProvider>().deleteDocument(
          patientId: widget.patient.id,
          document: document,
        );
        Fluttertoast.showToast(
          msg: 'Document deleted',
          backgroundColor: AppTheme.success,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Failed to delete document',
          backgroundColor: AppTheme.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, child) {
        final patient = patientProvider.selectedPatient ?? widget.patient;
        final documents = patient.documents;

        return Stack(
          children: [
            Column(
              children: [
                // View toggle header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${documents.length} document${documents.length != 1 ? 's' : ''}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          _buildViewToggle(
                            icon: Icons.grid_view,
                            isActive: _isGridView,
                            onTap: () => setState(() => _isGridView = true),
                          ),
                          const SizedBox(width: 4),
                          _buildViewToggle(
                            icon: Icons.view_list,
                            isActive: !_isGridView,
                            onTap: () => setState(() => _isGridView = false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Documents list
                Expanded(
                  child: documents.isEmpty
                      ? _buildEmptyState()
                      : _isGridView
                      ? _buildGridView(documents)
                      : _buildListView(documents),
                ),
              ],
            ),

            // Upload FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                heroTag: 'upload_document',
                onPressed: _isUploading ? null : _uploadDocument,
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textPrimaryLight,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.textPrimaryLight,
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Upload',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isActive ? AppTheme.primary : context.textTertiary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.folder_outlined,
      title: 'No documents yet',
      description: 'Upload medical documents, lab reports, or prescriptions.',
      actionLabel: 'Upload Document',
      onAction: _uploadDocument,
    );
  }

  Widget _buildGridView(List<PatientDocument> documents) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return _buildGridItem(document, index)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 50 * index))
            .scale(begin: const Offset(0.95, 0.95));
      },
    );
  }

  Widget _buildGridItem(PatientDocument document, int index) {
    final fileType = document.name.split('.').last;
    final fileColor = _getFileColor(fileType);

    return AppCard(
      onTap: () => _viewDocument(document),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fileColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getFileIcon(fileType), size: 32, color: fileColor),
          ),
          const SizedBox(height: 10),
          Text(
            document.name,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            fileType.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<PatientDocument> documents) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return _buildListItem(document, index)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 50 * index))
            .slideX(begin: 0.05);
      },
    );
  }

  Widget _buildListItem(PatientDocument document, int index) {
    final fileType = document.name.split('.').last;
    final fileColor = _getFileColor(fileType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () => _viewDocument(document),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: fileColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getFileIcon(fileType), size: 24, color: fileColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fileType.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: context.textTertiary),
              onSelected: (value) {
                if (value == 'view') {
                  _viewDocument(document);
                } else if (value == 'delete') {
                  _deleteDocument(document);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, size: 20),
                      SizedBox(width: 8),
                      Text('Open'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppTheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppTheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
