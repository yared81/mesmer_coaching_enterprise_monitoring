import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:mesmer_digital_coaching/core/theme/app_colors.dart';

class SignaturePadWidget extends StatefulWidget {
  final String title;
  final Function(String base64) onSave;

  const SignaturePadWidget({
    super.key, 
    required this.title, 
    required this.onSave,
  });

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Signature(
              controller: _controller,
              height: 150,
              backgroundColor: Colors.grey.shade50,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => _controller.clear(),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () async {
                if (_controller.isNotEmpty) {
                  final Uint8List? data = await _controller.toPngBytes();
                  if (data != null) {
                    final String base64String = base64Encode(data);
                    widget.onSave(base64String);
                  }
                }
              },
              child: const Text('Confirm Signature'),
            ),
          ],
        ),
      ],
    );
  }
}
