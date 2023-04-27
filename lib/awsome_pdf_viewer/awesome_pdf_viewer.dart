import 'dart:ui';

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
  List<PdfPageImage> _thumbnailImageList = [];
  late final PdfController _pdfController;
  List<double> linspace(
    double start,
    double stop, {
    int num = 10,
  }) {
    if (num <= 0) {
      throw ('num need be igual or greater than 0');
    }

    double delta;
    if (num > 1) {
      delta = (stop - start) / (num - 1);
    } else {
      delta = (stop - start) / num;
    }

    final space = List<double>.generate(num, (i) => start + delta * i);

    return space;
  }

  Future<void> _generateSliderImages(double width) async {
    final imageList = <PdfPageImage>[];
    final document = await PdfDocument.openAsset(widget.pdfPath);
    final pagesCount = document.pagesCount;
    final thumbnailCount = pagesCount >= (width / 130).round()
        ? (width / 130).round()
        : pagesCount;
    final evenlySpacedArrayPoints = linspace(
      1,
      pagesCount.toDouble(),
      num: thumbnailCount,
    );

    for (final invidualPoint in evenlySpacedArrayPoints) {
      final page = await document.getPage(invidualPoint.round());
      final pageImage =
          await page.render(width: page.width / 20, height: page.height / 20);
      await page.close();
      imageList.add(pageImage!);
    }
    await document.close();

    setState(() {
      _thumbnailImageList = imageList;
    });
  }

  @override
  void initState() {
    _pdfController =
        PdfController(document: PdfDocument.openAsset(widget.pdfPath));
    _generateSliderImages(window.physicalSize.width);
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
              child: PdfPageNumber(
                  controller: _pdfController,
                  builder: (_, loadingState, page, pagesCount) {
                    if (pagesCount == null || _thumbnailImageList.isEmpty) {
                      return Container(
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.blue,
                        ),
                      );
                    }
                    return Center(
                      child: Container(
                          width: _thumbnailImageList.length * 37,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.blue,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 40,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 30,
                                      color: Colors.white,
                                      child: _thumbnailImageList.isEmpty ||
                                              _thumbnailImageList.length <=
                                                  index
                                          ? const CupertinoActivityIndicator()
                                          : Image(
                                              image: MemoryImage(
                                                  _thumbnailImageList[index]
                                                      .bytes),
                                            ),
                                    );
                                  },
                                  itemCount: 10,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                    width: 5,
                                  ),
                                ),
                              ),
                              if (pagesCount != 1)
                                FlutterSlider(
                                  values: [page.toDouble()],
                                  max: pagesCount.toDouble(),
                                  min: 1,
                                  handlerWidth: 45,
                                  handlerHeight: 55,
                                  handler: FlutterSliderHandler(
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      child: Container(
                                        color: Colors.white,
                                      )),
                                  trackBar: const FlutterSliderTrackBar(
                                    inactiveDisabledTrackBarColor:
                                        Colors.transparent,
                                    activeDisabledTrackBarColor:
                                        Colors.transparent,
                                    inactiveTrackBar: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    activeTrackBar: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  onDragCompleted:
                                      (handlerIndex, lowerValue, upperValue) {
                                    _pdfController.jumpToPage(
                                      (lowerValue as double).toInt(),
                                    );
                                  },
                                  onDragging:
                                      (handlerIndex, lowerValue, upperValue) {
                                    ///TODO: Implement Logic for changing thumbnail
                                  },
                                ),
                            ],
                          )),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
