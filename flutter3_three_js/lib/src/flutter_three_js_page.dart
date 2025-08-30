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
      settings: three.Settings(clearAlpha: 1, clearColor: 0x000000),
      onSetupComplete: () {
        updateState();
      },
      setup: setup,
    );
    super.initState();
  }

  @override
  void dispose() {
    controls.dispose();
    threeJs.dispose();
    three.loading.clear();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context, WidgetList? children) {
    return threeJs.build();
  }

  @override
  void reassemble() {
    super.reassemble();
    threeJs.camera.position.setValues(3, 7, 10);
    //threeJs.camera.position.setValues(0.5, 0.5, 10);
    threeJs.render();
  }

  /// 轨道控制器
  late three.OrbitControls controls;

  /// 设置
  Future<void> setup() async {
    //摄像机
    threeJs.camera = three.PerspectiveCamera(
      45,
      threeJs.width / threeJs.height,
      1,
      2200,
    );
    threeJs.camera.position.setValues(3, 6, 10);

    //控制器
    controls = three.OrbitControls(threeJs.camera, threeJs.globalKey);

    //场景 背景色
    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(0xffffff);

    //是否激活光照
    final enableLight = false;
    if (enableLight) {
      //环境光
      final ambientLight = three.AmbientLight(0xffffff, 0.9);
      threeJs.scene.add(ambientLight);

      //点光源
      final pointLight = three.PointLight(0xffffff, 0.8);
      pointLight.position.setValues(0, 0, 0);
      //添加点光源
      threeJs.camera.add(pointLight);
    }

    threeJs.scene.add(threeJs.camera);
    //摄像机对准场景
    threeJs.camera.lookAt(threeJs.scene.position);

    //加载模型
    final src = widget.src.toLowerCase();
    final isHttpScheme =
        src.startsWith("http://") || src.startsWith("https://");
    final three.Loader loader = src.endsWith(".obj")
        ? three.OBJLoader()
        : (src.endsWith(".glb") || src.endsWith(".gltf")
              ? three.GLTFLoader()
              : (src.endsWith(".gcode") ||
                    src.endsWith(".nc") ||
                    src.endsWith(".gc"))
              ? three.GCodeLoader()
              : three.STLLoader());

    try {
      final object = isHttpScheme
          ? await loader.fromNetwork(widget.src.toUri()!)
          : await loader.fromFile(widget.src.toFile());
      assert(() {
        l.i("${loader.runtimeType} 加载-> ${widget.src}");
        return true;
      }());
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
