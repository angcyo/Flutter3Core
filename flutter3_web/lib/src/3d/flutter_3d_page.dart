part of '../../flutter3_web.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/08/29
///
/// 使用`flutter_3d_controller`渲染3D模型页面
///
/// - Toothy_Baby_Croc.stl ✘
/// - Football.obj         ✘
/// - Football.mtl         ✘
/// - flutter_dash.obj     ✘
/// - flutter_dash.mtl     ✘
/// - sheen_chair.glb      ︎︎✔ ︎
/// - business_man.glb     ︎︎✔ ︎
///
/// https://pub.dev/packages/flutter_3d_controller
/// https://modelviewer.dev/
///
class Flutter3dPage extends StatefulWidget {
  /// 模型的数据
  ///
  /// - 支持assets
  /// - 支持file, 需要scheme: file://
  /// - 支持url, 需要scheme: https://
  final String src;

  const Flutter3dPage({super.key, required this.src});

  @override
  State<Flutter3dPage> createState() => _Flutter3dPageState();
}

class _Flutter3dPageState extends State<Flutter3dPage> with AbsScrollPage {
  late Flutter3DController controller;

  @override
  String? getTitle(BuildContext context) {
    return widget.src.toFile().filename;
    //return super.getTitle(context);
  }

  @override
  void initState() {
    //Create controller object to control 3D model.
    controller = Flutter3DController();

    //Listen to model loading state via controller
    controller.onModelLoaded.addListener(() {
      l.d('model is loaded : ${controller.onModelLoaded.value}');
    });

    /*//It will play 3D model animation, you can use it to play or switch between animations.
    controller.playAnimation();

    //If you pass specific animation name it will play that specific animation.
    //If you pass null and your model has at least 1 animation it will play first animation.
    controller.playAnimation(animationName: chosenAnimation);

    //If you pass loopCount > 0, the animation will repeat for the specified number of times.
    //To play the animation only once, set loopCount to 1.
    controller.playAnimation(loopCount: 1);

    //The loopCount argument can also be used with a specific animation.
    controller.playAnimation(loopCount: 2, animationName: chosenAnimation);

    //It will pause the animation at current frame.
    controller.pauseAnimation();

    //It will reset and play animation from first frame (from beginning).
    controller.resetAnimation();

    //It will stop the animation.
    controller.stopAnimation();

    //It will return available animation list of 3D model.
    await controller.getAvailableAnimations();

    //It will load desired texture of 3D model, you need to pass texture name.
    controller.setTexture(textureName: chosenTexture);

    //It will return available textures list of 3D model.
    await controller.getAvailableTextures();

    //It will set your desired camera target.
    controller.setCameraTarget(0.3, 0.2, 0.4);

    //It will reset the camera target to default.
    controller.resetCameraTarget();

    //It will set your desired camera orbit.
    controller.setCameraOrbit(20, 20, 5);

    //It will reset the camera orbit to default.
    controller.resetCameraOrbit();*/
    super.initState();
  }

  @override
  Widget buildBody(BuildContext context, WidgetList? children) {
    final globalTheme = GlobalTheme.of(context);
    final src = widget.src.toLowerCase();
    final isObj = src.endsWith(".obj");

    if (isObj) {
      /*只支持加载http / assets 中的obj数据*/
      //The 3D viewer widget for obj format
      return Flutter3DViewer.obj(
        src: widget.src /*'assets/flutter_dash.obj'*/,
        //src: 'https://raw.githubusercontent.com/m-r-davari/content-holder/refs/heads/master/flutter_3d_controller/flutter_dash_model/flutter_dash.obj',
        // Initial scale of obj model
        scale: 5,
        // Initial cameraX position of obj model
        cameraX: 0,
        //Initial cameraY position of obj model
        cameraY: 0,
        //Initial cameraZ position of obj model
        cameraZ: 10,
        //This callBack will return the loading progress value between 0 and 1.0
        onProgress: (double progressValue) {
          l.d('model loading progress : $progressValue');
        },
        //This callBack will call after model loaded successfully and will return model address
        onLoad: (String modelAddress) {
          l.d('model loaded : $modelAddress');
        },
        //this callBack will call when model failed to load and will return failure erro
        onError: (String error) {
          l.e('model failed to load : $error');
        },
      );
    }

    return //The 3D viewer widget for glb and gltf format
    Flutter3DViewer(
      //If you pass 'true' the flutter_3d_controller will add gesture interceptor layer
      //to prevent gesture recognizers from malfunctioning on iOS and some Android devices.
      //the default value is true
      activeGestureInterceptor: true,
      //You can disable viewer touch response by setting 'enableTouch' to 'false'
      enableTouch: true,
      //If you don't pass progressBarColor, the color of defaultLoadingProgressBar will be grey.
      //You can set your custom color or use [Colors.transparent] for hiding loadingProgressBar.
      progressBarColor: globalTheme.accentColor /*Colors.orange*/,
      //This callBack will return the loading progress value between 0 and 1.0
      onProgress: (double progressValue) {
        l.d('model loading progress : $progressValue');
      },
      //This callBack will call after model loaded successfully and will return model address
      onLoad: (String modelAddress) {
        l.d('model loaded : $modelAddress');
      },
      //this callBack will call when model failed to load and will return failure error
      onError: (String error) {
        l.e('model failed to load : $error');
      },
      //You can have full control of 3d model animations, textures and camera
      controller: controller,
      src: widget
          .src /*'assets/business_man.glb'*/, //3D model with different animations
      //src: 'assets/sheen_chair.glb', //3D model with different textures
      //src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb', // 3D model from URL
    );
  }
}
