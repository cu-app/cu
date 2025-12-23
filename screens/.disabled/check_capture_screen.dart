import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/camera_overlay_widget.dart';
import '../models/check_deposit_model.dart';

class CheckCaptureScreen extends StatefulWidget {
  final CheckSide side;
  final Function(File) onImageCaptured;

  const CheckCaptureScreen({
    super.key,
    required this.side,
    required this.onImageCaptured,
  });

  @override
  State<CheckCaptureScreen> createState() => _CheckCaptureScreenState();
}

class _CheckCaptureScreenState extends State<CheckCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    // Check camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      _showPermissionError();
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (!mounted) return;
        _showCameraError();
        return;
      }

      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Camera initialization error: $e');
      if (!mounted) return;
      _showCameraError();
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile image = await _controller!.takePicture();
      final File imageFile = File(image.path);

      if (!mounted) return;

      // Show preview
      final confirmed = await _showImagePreview(imageFile);

      if (confirmed && mounted) {
        widget.onImageCaptured(imageFile);
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error capturing image: $e');
      if (!mounted) return;

      final theme = CUTheme.of(context);
      CUSnackBar.show(
        context,
        message: 'Failed to capture image: $e',
        type: CUSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        final File imageFile = File(image.path);
        final confirmed = await _showImagePreview(imageFile);

        if (confirmed && mounted) {
          widget.onImageCaptured(imageFile);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (!mounted) return;

      CUSnackBar.show(
        context,
        message: 'Failed to pick image: $e',
        type: CUSnackBarType.error,
      );
    }
  }

  Future<bool> _showImagePreview(File image) async {
    final theme = CUTheme.of(context);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CUDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CUAppBar(
                title: CUText(
                  'Review ${widget.side == CheckSide.front ? 'Front' : 'Back'} Image',
                  style: CUTypography.headlineSmall,
                ),
                automaticallyImplyLeading: false,
                actions: [
                  CUTextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: CUText('Retake'),
                  ),
                ],
              ),
              Container(
                constraints: BoxConstraints(maxHeight: CUSize.xl * 10),
                child: Image.file(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(CUSpacing.md),
                child: Column(
                  children: [
                    CUText(
                      'Make sure the check is clearly visible and all corners are in the frame.',
                      style: CUTypography.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: CUSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CUButton.secondary(
                          onPressed: () => Navigator.pop(context, false),
                          child: CUText('Retake'),
                        ),
                        CUButton.primary(
                          onPressed: () => Navigator.pop(context, true),
                          child: CUText('Use This Photo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  void _showPermissionError() {
    final theme = CUTheme.of(context);

    showDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: CUText(
          'Camera Permission Required',
          style: CUTypography.headlineSmall,
        ),
        content: CUText(
          'This app needs camera access to capture check images. Please grant camera permission in Settings.',
          style: CUTypography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          CUTextButton(
            onPressed: () => Navigator.pop(context),
            child: CUText('Cancel'),
          ),
          CUTextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: CUText('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showCameraError() {
    final theme = CUTheme.of(context);

    showDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: CUText(
          'Camera Error',
          style: CUTypography.headlineSmall,
        ),
        content: CUText(
          'Unable to access camera. You can still select an image from your gallery.',
          style: CUTypography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          CUTextButton(
            onPressed: () => Navigator.pop(context),
            child: CUText('Cancel'),
          ),
          CUTextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickFromGallery();
            },
            child: CUText('Choose from Gallery'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      backgroundColor: CUColors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            )
          else
            Center(
              child: CUProgressIndicator(
                color: CUColors.white,
              ),
            ),

          // Camera overlay
          CameraOverlayWidget(
            title: widget.side == CheckSide.front
                ? 'Capture Front of Check'
                : 'Capture Back of Check',
            subtitle: widget.side == CheckSide.front
                ? 'Place the front of your check within the guides'
                : 'Sign the back and place within the guides',
            onCapture: _captureImage,
            onCancel: () => Navigator.pop(context),
          ),

          // Gallery button
          Positioned(
            bottom: CUSpacing.xl * 1.5,
            right: CUSpacing.lg,
            child: SafeArea(
              child: CUIconButton(
                onPressed: _pickFromGallery,
                icon: CUIcon(CUIcons.photoLibrary),
                style: CUIconButtonStyle.filled,
                backgroundColor: CUColors.white.withOpacity(0.3),
                foregroundColor: CUColors.white,
                padding: EdgeInsets.all(CUSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
