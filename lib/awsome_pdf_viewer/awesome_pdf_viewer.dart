import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/trackbar.dart';
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
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Awesome PDF Viewer')),
      body: Stack(
        children: [
          PdfView(
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Container(
                  height: 60,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
