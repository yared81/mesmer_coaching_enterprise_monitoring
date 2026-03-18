// TODO: Evidence upload screen — attach photos, documents, or videos to a session
// - Use image_picker for camera/gallery
// - Use file_picker for documents
// - Show upload progress
// - Display uploaded files as thumbnails
// - Files go to backend → Cloudflare R2

import 'package:flutter/material.dart';

class EvidenceUploadScreen extends StatelessWidget {
  const EvidenceUploadScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Evidence Upload — TODO')),
    );
  }
}
