import 'dart:typed_data';

/// Result object containing the download URL and optionally the PDF bytes
class NfeDownloadResult {
  /// The URL to download the NFe PDF document
  final String downloadUrl;

  /// The PDF document bytes (only populated if downloadBytes was true)
  final Uint8List? pdfBytes;

  /// The document ID extracted from the API response
  final String documentId;

  const NfeDownloadResult({
    required this.downloadUrl,
    required this.documentId,
    this.pdfBytes,
  });

  @override
  String toString() =>
      'NfeDownloadResult(downloadUrl: $downloadUrl, '
      'documentId: $documentId, hasPdfBytes: ${pdfBytes != null})';
}
