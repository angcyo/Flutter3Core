part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/02
///
/// OpenCV DNN 深度神经网络 模块
///
/// https://docs.opencv.org/4.13.0/d6/d0f/group__dnn.html?__cf_chl_f_tk=7xuf0EjfevBfP7tL2szlqt1_rzmcI1TBRMobz3CyUgg-1782959698-1.0.1.1-D.LBNkg5rL78_q8Wl_ugRRN_QRoumpoSWvTawEomDO8#ga4823489a689bf4edfae7447eb807b067
///
/// 加载模型
///
/// - [path] 路径不能包含中文
/// Binary file contains trained weights. The following file extensions are expected for models from different frameworks:
/// - *.caffemodel (Caffe, http://caffe.berkeleyvision.org/)
/// - *.pb (TensorFlow, https://www.tensorflow.org/)
/// - *.t7 | *.net (Torch, http://torch.ch/)
/// - *.weights (Darknet, https://pjreddie.com/darknet/)
/// - *.bin | *.onnx (OpenVINO, https://software.intel.com/openvino-toolkit)
/// - *.onnx (ONNX, https://onnx.ai/)
///
/// - [config]
/// Text file contains network configuration. It could be a file with the following extensions:
/// -  *.prototxt (Caffe, http://caffe.berkeleyvision.org/)
/// -  *.pbtxt (TensorFlow, https://www.tensorflow.org/)
/// -  *.cfg (Darknet, https://pjreddie.com/darknet/)
/// -  *.xml (OpenVINO, https://software.intel.com/openvino-toolkit)
///
///  - [cv.Net.fromCaffe] : Reads a network model stored in Caffe framework's format.
///  - [cv.Net.fromOnnx] : Reads a network model ONNX.
///  - [cv.Net.fromTensorflow] : Reads a network model stored in TensorFlow framework's format.
///  - [cv.Net.fromTFLite] : Reads a network model stored in TFLite framework's format.
///  - [cv.Net.fromTorch] : Reads a network model stored in Torch7 framework's format.
///
/// ```
/// Cannot determine an origin framework of files
/// ```
/// - [CvException]
cv.Net cvNetFromFile(String path, {String config = "", String framework = ""}) {
  return cv.Net.fromFile(path, config: config, framework: framework);
}

/// - [image] 需要一个三通道的图片
/// - [size] 指定输出图片的大小
/// ```
/// Number of input channels should be multiple of 3 but got 1
/// Number of input channels should be multiple of 3 but got 4
/// ```
/// https://docs.opencv.org/4.x/d6/d0f/group__dnn.html#ga29f34df9376379a603acd8df581ac8d7
cv.Mat? cvBlobFromImage(
  cv.InputArray? image, {
  double scalefactor = 1.0,
  (int, int) size = (0, 0),
  cv.Scalar? mean,
  bool swapRB = false,
  bool crop = false,
  int ddepth = cv.MatType.CV_32F,
}) {
  if (image == null) {
    return null;
  }
  return cv.blobFromImage(
    image,
    scalefactor: scalefactor,
    size: size,
    mean: mean,
    swapRB: swapRB,
    crop: crop,
    ddepth: ddepth,
  );
}

/// - [cv.Net]
typedef CvNet = cv.Net;

void testDnn() {
  try {
    cvNetFromFile("");
  } catch (e) {
    print(e);
  }
}
