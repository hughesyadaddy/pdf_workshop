import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pdfx/pdfx.dart';

class AwesomePdfViewer extends StatefulWidget {
  AwesomePdfViewer({super.key, required this.pdfPath});

  String pdfPath;

  @override
  State<AwesomePdfViewer> createState() => _AwesomePdfViewerState();
}

class _AwesomePdfViewerState extends State<AwesomePdfViewer> {
  late final PdfController _pdfController;

  @override
  void initState() {
    _pdfController =
        PdfController(document: PdfDocument.openAsset(widget.pdfPath));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Awesome PDF Viewer')),
      body: PdfView(
          builders: PdfViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(),
            documentLoaderBuilder: (_) =>
                const Center(child: CupertinoActivityIndicator()),
            pageLoaderBuilder: (_) =>
                const Center(child: CupertinoActivityIndicator()),
            errorBuilder: (_, error) =>
                Center(child: Text(error.toString())),
          ),
          controller: _pdfController),
    );
  }
}
