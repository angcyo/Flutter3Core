part of '../flutter3_three_js.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/08/29
///
/// https://github.com/Knightro63/three_js
/// https://github.com/wasabia/three_dart
///
class FlutterThreeJsPage extends StatefulWidget {
  final String src;

  const FlutterThreeJsPage({super.key, required this.src});

  @override
  State<FlutterThreeJsPage> createState() => _FlutterThreeJsPageState();
}

class _FlutterThreeJsPageState extends State<FlutterThreeJsPage>
    with AbsScrollPage {
  late three.ThreeJS threeJs;

  @override
  String? getTitle(BuildContext context) {
    return widget.src.toFile().filename;
    //return super.getTitle(context);
  }

  @override
  void initState() {
    threeJs = three.ThreeJS(
      onSetupComplete: () {
        updateState();
      },
      setup: setup,
    );
    super.initState();
  }

  @override
  void dispose() {
    threeJs.dispose();
    three.loading.clear();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context, WidgetList? children) {
    return threeJs.build();
  }

  Future<void> setup() async {
    threeJs.camera = three.PerspectiveCamera(
      45,
      threeJs.width / threeJs.height,
      1,
      2200,
    );
    threeJs.camera.position.setValues(3, 6, 10);

    threeJs.scene = three.Scene();
    threeJs.scene.add(threeJs.camera);
    threeJs.camera.lookAt(threeJs.scene.position);

    final src = widget.src.toLowerCase();
    final isHttpScheme =
        src.startsWith("http://") || src.startsWith("https://");
    final three.Loader loader = src.endsWith(".obj")
        ? three.OBJLoader()
        : (src.endsWith(".glb") || src.endsWith(".gltf")
              ? three.GLTFLoader()
              : three.STLLoader());

    try {
      final object = isHttpScheme
          ? await loader.fromNetwork(widget.src.toUri()!)
          : await loader.fromFile(widget.src.toFile());
      debugger();
      if (object != null) {
        if (object is three.GLTFData) {
          threeJs.scene.add(object.scene);
        } else {
          threeJs.scene.add(object);
        }
      }
    } catch (e, s) {
      debugger();
      assert(() {
        printError(e, s);
        return true;
      }());
      toast(e.toString().text());
    }
  }
}
