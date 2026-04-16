import 'dart:io';

import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final PageController _pageController = PageController();
  final List<File?> _selectedFiles = [null, null, null, null];
  bool _isUploading = false;
  String _errorMessage = '';

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConsts.backgroundColor,
        automaticallyImplyLeading: _currentStep == 0 ? true : false,
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStepPage(title: S.of(context).fileUploadStep1Title, index: 0),
            _buildStepPage(title: S.of(context).fileUploadStep2Title, index: 1),
            _buildStepPage(title: S.of(context).fileUploadStep3Title, index: 2),
            _buildStepPage(title: S.of(context).fileUploadStep4Title, index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPage({required String title, required int index}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStyledFileBox(index),
                const SizedBox(height: 20),
              ],
            ),

            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red[700], fontSize: 16),
              ),

            if (_isUploading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 10),
              Text(
                S.of(context).fileUploadUploading,
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),
            _buildNavigationControls(index),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledFileBox(int index) {
    return GestureDetector(
      onTap: () => _pickPdfFile(index),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: [8, 4],
          radius: const Radius.circular(12),
          color: Colors.grey.shade400,
        ),
        child: Container(
          height: 250,
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              _selectedFiles[index] != null
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedFiles[index]!.path.split('/').last,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.close),
                        label: Text(S.of(context).fileUploadRemove),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _removeFile(index),
                      ),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).fileUploadDragDrop,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.of(context).fileUploadOr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.lightBlue,
                          side: const BorderSide(color: Colors.lightBlue),
                        ),
                        onPressed: () => _pickPdfFile(index),
                        child: Text(S.of(context).fileUploadBrowse),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls(int index) {
    final isLast = index == 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 16,
      children: [
        if (index > 0)
          Expanded(
            child: TextButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                backgroundColor: Color(0xffFFF879).withAlpha(180),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => _goToStep(index - 1),
              child: Text(
                S.of(context).onboarding_back,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (!isLast)
          Expanded(
            child: TextButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                backgroundColor:
                    index == 0
                        ? Color(0xffFFF879).withAlpha(180)
                        : Color(0xff347928).withAlpha(180),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed:
                  () =>
                      _selectedFiles.any((x) => x != null)
                          ? _goToStep(index + 1)
                          : null,
              child: Text(
                S.of(context).onboarding_next,
                style: TextStyle(
                  color: index == 0 ? Color(0xff347928) : Color(0xffffffff),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (isLast)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                backgroundColor: Color(0xff347928).withAlpha(180),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed:
                  _selectedFiles.every((file) => file != null) && !_isUploading
                      ? _uploadFiles
                      : null,
              child: Text(
                S.of(context).submit,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentStep = step;
    });
  }

  Future<void> _pickPdfFile(int stepIndex) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedFiles[stepIndex] = File(result.files.single.path!);
        _errorMessage = '';
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles[index] = null;
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) {
      setState(() => _errorMessage = 'No files selected');
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = '';
    });

    try {
      await context
          .read<FoodStoreProvider>()
          .createFoodStoreVerificationRequest(_selectedFiles);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).allFilesUploadedSuccessfully)),
        );
        _navigateBack();

        await context.read<FoodStoreProvider>().getMyStoreRequest();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _errorMessage = 'Upload failed: ${e.toString()}';
        });
      }
    }
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }
}
