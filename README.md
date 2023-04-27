# AwesomePDFViewer

AwesomePDFViewer is a feature-rich and highly customizable PDF viewer built using Flutter. This project is organized into six sprints, each tackling a specific part of the development process. These sprints are available as separate branches named `sprint1`, `sprint2`, and so on.

## Dependencies

This project uses the following packages:

- [another_xlider: ^3.0.1](https://pub.dev/packages/another_xlider)
- [pdfx: ^2.3.0](https://pub.dev/packages/pdfx)
- [printing: ^5.10.3](https://pub.dev/packages/printing)

## Table of Contents

- [Sprint Overview](#sprint-overview)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [License](#license)

## Sprint Overview

### Sprint 1: Wire up the PDF Viewer

In this sprint, we focus on initializing the PDF Viewer and loading the PDF documents. The goal is to display the PDF document on the screen.

Branch: `sprint1`

```dart
class AwesomePdfViewer extends StatefulWidget {
  const AwesomePdfViewer({
    super.key,
    required this.pdfPath,
  });

  final String pdfPath;

  @override
  State<AwesomePdfViewer> createState() => _PdfPageState();
}

class _PdfPageState extends State<AwesomePdfViewer> {
  late final PdfController _pdfController;

  @override
  void initState() {
    super.initState();

    _pdfController = PdfController(
      document: PdfDocument.openAsset(
        widget.pdfPath,
      ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome PDF Viewer'),
      ),
      body: PdfView(
        builders: PdfViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: CupertinoActivityIndicator()),
          pageLoaderBuilder: (_) =>
              const Center(child: CupertinoActivityIndicator()),
          errorBuilder: (_, error) => Center(child: Text(error.toString())),
        ),
        controller: _pdfController,
      ),
    );
  }
}
```

### Sprint 2: Layout all of the Widgets for the Scroll Bar

In the second sprint, we concentrate on designing and arranging the widgets for the scroll bar. This includes creating a user-friendly and visually appealing scroll bar layout.

Branch: `sprint2`

```dart
body: Stack(
children: [
    PdfView(
    builders: PdfViewBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) =>
            const Center(child: CupertinoActivityIndicator()),
        pageLoaderBuilder: (_) =>
            const Center(child: CupertinoActivityIndicator()),
        errorBuilder: (_, error) => Center(child: Text(error.toString())),
    ),
    onPageChanged: _pdfControllerSlider.jumpToPage,
    controller: _pdfController,
    ),
    Positioned(
    left: 0,
    right: 0,
    bottom: 40,
    child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
        child: Container(
            height: 60,
            width: _thumbnailImageList.length * 37,
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
```

### Sprint 3: Wire up the Scroll Bar

This sprint is dedicated to connecting the scroll bar functionality to the PDF viewer. Users should be able to navigate through the PDF document using the scroll bar.

Branch: `sprint3`

```dart
Positioned(
  left: 0,
  right: 0,
  bottom: 40,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: PdfPageNumber(
        controller: _pdfController,
        builder: (_, loadingState, page, pagesCount) {
          if (loadingState != PdfLoadingState.success)
            return Container();
          return Center(
            child: Container(
                width: 300,
                height: 60,
                color: Colors.blue,
                child: FlutterSlider(
                  values: [page.toDouble()],
                  max: pagesCount?.toDouble(),
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
                    inactiveDisabledTrackBarColor: Colors.transparent,
                    activeDisabledTrackBarColor: Colors.transparent,
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
                  onDragging: (handlerIndex, lowerValue, upperValue) {
                    ///TODO: Implement Logic for changing thumbnail
                  },
                )),
          );
        }),
  ),
),
```

### Sprint 4: Generate the thumbnails for the Scroll Bar

In the fourth sprint, we will generate thumbnails for the scroll bar using the linspace equation. This will provide users with a preview of evenly spaced pages, including the first and last page of the PDF document.

Branch: `sprint4`

```dart
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
  // Your linspace implementation
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
```

### Sprint 5: Realize the Issue with window changing sizes and add debouncer functionality

During this sprint, we address the issue of the PDF viewer not resizing correctly when the window size changes. We will add debouncer functionality to handle these resizing events properly.

Branch: `sprint5`

```dart
final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

@override
void didChangeMetrics() {
  _debouncer.run(
    () => _generateSliderImages(
      WidgetsBinding.instance.window.physicalSize.width,
    ),
  );
  super.didChangeMetrics();
}
```

```dart
import 'dart:async';
import 'dart:ui';

class Debouncer {
  Debouncer({required this.delay});
  final Duration delay;
  Timer? _timer;

  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void cancel() {
    _timer?.cancel();
  }
}
```

### Sprint 6: Add print & sharing functionality

In the final sprint, we will implement the print and sharing functionality, allowing users to print the PDF document or share it via different platforms.

Branch: `sprint6`

```dart
appBar: AppBar(
  title: const Text('Awesome PDF Viewer'),
  actions: [
    IconButton(
      onPressed: () async {
        final byteData = await rootBundle.load(widget.pdfPath);
        final bytes = byteData.buffer.asUint8List();
        await Printing.sharePdf(
          bytes: bytes,
        );
      },
      icon: const Icon(Icons.ios_share),
    ),
    IconButton(
      onPressed: () async {
        final byteData = await rootBundle.load(widget.pdfPath);
        final bytes = byteData.buffer.asUint8List();
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
        );
      },
      icon: const Icon(Icons.print),
    )
  ],
),
```

## Getting Started

To get started, clone the repository and navigate to the branch corresponding to the sprint you wish to work on:

```sh
git clone https://github.com/hughesyadaddy/pdf_workshop.git
cd pdf_workshop
git checkout <branch_name>
```

Replace `<branch_name>` with the name of the sprint branch you want to work on, e.g., `sprint1`.

Next, open the project in your favorite IDE, and run the app on an emulator or physical device.

## Contributing

Feel free to contribute to this project by opening issues or submitting pull requests. Any feedback or suggestions are highly appreciated.

## License

This project is licensed under the MIT License. For more details, see the [LICENSE](LICENSE) file.
