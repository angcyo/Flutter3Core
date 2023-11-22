part of flutter3_widgets;

/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to
/// deal in the Software without restriction, including without limitation the
/// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
/// sell copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge,
/// publish, distribute, sublicense, create a derivative work, and/or sell
/// copies of the Software in any work that is designed, intended, or marketed
/// for pedagogical or instructional purposes related to programming, coding,
/// application development, or information technology.  Permission for such
/// use, copying, modification, merger, publication, distribution, sublicensing,
///  creation of derivative works, or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
///  IN THE SOFTWARE.

/// https://github.com/adrian7123/flutter_microinteracoes

/// RotationStartDetails
///
/// Details for rotation gesture update.
class RotationStartDetails {
  /// @macro
  RotationStartDetails();
}

/// RotationUpdateDetails
///
/// Details for rotation gesture update.
class RotationUpdateDetails {
  /// @macro
  RotationUpdateDetails({
    required this.rotationAngle,
    required this.acceleration,
  });

  /// rotation in radians.
  final double rotationAngle;

  /// difference between the last rotation and the current one, in radians.
  final double acceleration;
}

/// RotationEndDetails
///
/// Details for rotation gesture update.
class RotationEndDetails {
  /// @macro
  RotationEndDetails();
}

/// Signature for when the pointers in contact with the screen have established
/// a focal point.
typedef GestureRotationStartCallback = void Function(
  RotationStartDetails details,
);

/// Signature for when the pointers in contact with the screen have indicated a
/// new focal point and/or rotation.
typedef GestureRotationUpdateCallback = void Function(
  RotationUpdateDetails details,
);

/// Signature for when the pointers are no longer in contact with the screen.
typedef GestureRotationEndCallback = void Function(RotationEndDetails details);

/// Recognizes a rotation gesture.
///
/// This is a variant of [ScaleGestureRecognizer] that tracks rotation gestures.
class RotateGestureRecognizer extends ScaleGestureRecognizer {
  /// Create a gesture recognizer for interactions intended for
  /// rotating content.
  ///
  /// @macro
  RotateGestureRecognizer({
    Object? debugOwner,
    Set<PointerDeviceKind>? supportedDevices,
    DragStartBehavior dragStartBehavior = DragStartBehavior.down,
  }) : super(
          debugOwner: debugOwner,
          supportedDevices: supportedDevices,
          dragStartBehavior: dragStartBehavior,
        );

  /// Cache of the last rotation angle, useful to calculate acceleration between
  /// the two rotation updates.
  double previousRotationAngle = 0;

  @override
  GestureScaleStartCallback? get onStart => _scaleStarts;

  void _scaleStarts(ScaleStartDetails details) {
    onRotationStart?.call(RotationStartDetails());
  }

  @override
  GestureScaleUpdateCallback? get onUpdate => _scaleUpdates;

  void _scaleUpdates(ScaleUpdateDetails details) {
    onRotationUpdate?.call(
      RotationUpdateDetails(
        rotationAngle: details.rotation,
        acceleration: (details.rotation - previousRotationAngle).abs(),
      ),
    );
    previousRotationAngle = details.rotation;
  }

  @override
  GestureScaleEndCallback? get onEnd => _scaleEnds;

  void _scaleEnds(ScaleEndDetails details) {
    onRotationEnd?.call(RotationEndDetails());
  }

  /// Determines what point is used as the starting point in all calculations
  /// involving this gesture.
  GestureRotationStartCallback? onRotationStart;

  /// The pointers in contact with the screen have indicated a new focal point
  /// and/or scale.
  GestureRotationUpdateCallback? onRotationUpdate;

  /// The pointers are no longer in contact with the screen.
  GestureRotationEndCallback? onRotationEnd;
}
