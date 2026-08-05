import 'dart:math' as math;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/05
///
/// Fast Fourier Transform (FFT) 快速傅里叶变换测试
///
/// https://pub.dev/packages/fftea
void main() {
  const int sampleRate = 1024; // 采样率 1024 Hz
  const int n = 1024; // 1024 个采样点

  print('1. 生成测试信号: 1.0*sin(2*pi*50*t) + 0.5*sin(2*pi*120*t)');
  final timeDomain = List<Complex>.generate(n, (i) {
    final t = i / sampleRate;
    // 50Hz 振幅为 1.0 的波形 + 120Hz 振幅为 0.5 的波形
    final signal =
        1.0 * math.sin(2 * math.pi * 50 * t) +
        0.5 * math.sin(2 * math.pi * 120 * t) +
        0.2 * math.sin(2 * math.pi * 100 * t) /* 100Hz 振幅为 0.2 的波形*/;
    return Complex(signal, 0.0);
  });

  print('2. 运行 Cooley-Tukey FFT...');
  final stopwatch = Stopwatch()..start();
  final fftResult = FastFourierTransform.fft(timeDomain);
  stopwatch.stop();

  print(
    '计算完成，耗时: ${stopwatch.elapsedMicroseconds} 微秒 (${stopwatch.elapsedMilliseconds} ms)\n',
  );

  // 3. 计算实际幅值
  final magnitudes = FastFourierTransform.getMagnitudes(fftResult);

  // 频率分辨率 deltaF = sampleRate / N = 1024 / 1024 = 1 Hz
  const double deltaF = sampleRate / n;

  print('--- 显著频点检测结果 (幅度大于 0.1) ---');
  for (int k = 0; k < magnitudes.length; k++) {
    if (magnitudes[k] > 0.1) {
      final freq = k * deltaF;
      print(
        '频率: ${freq.toStringAsFixed(1).padLeft(6)} Hz -> 振幅: ${magnitudes[k].toStringAsFixed(3)}',
      );
    }
  }

  //1. 生成测试信号: 1.0*sin(2*pi*50*t) + 0.5*sin(2*pi*120*t)
  // 2. 运行 Cooley-Tukey FFT...
  // 计算完成，耗时: 2150 微秒 (2 ms)
  //
  // --- 显著频点检测结果 (幅度大于 0.1) ---
  // 频率:   50.0 Hz -> 振幅: 1.000
  // 频率:  120.0 Hz -> 振幅: 0.500
}

//--

/// 1. 基础复数类，表示 z = real + imag * i
class Complex {
  final double real; // 实部
  final double imag; // 虚部

  const Complex(this.real, [this.imag = 0.0]);

  // 复数加法: (a + bi) + (c + di) = (a + c) + (b + d)i
  Complex operator +(Complex other) =>
      Complex(real + other.real, imag + other.imag);

  // 复数减法: (a + bi) - (c + di) = (a - c) + (b - d)i
  Complex operator -(Complex other) =>
      Complex(real - other.real, imag - other.imag);

  // 复数乘法: (a + bi) * (c + di) = (ac - bd) + (ad + bc)i
  Complex operator *(Complex other) => Complex(
    real * other.real - imag * other.imag,
    real * other.imag + imag * other.real,
  );

  /// 计算复数的模长 (Magnitude / Amplitude)
  /// |z| = sqrt(real^2 + imag^2)
  double get magnitude => math.sqrt(real * real + imag * imag);

  /// 计算复数的相位 (Phase Angle in Radians)
  /// theta = atan2(imag, real)
  double get phase => math.atan2(imag, real);

  @override
  String toString() {
    final sign = imag >= 0 ? '+' : '-';
    if (imag == 0.0) {
      return real.toStringAsFixed(3);
    }
    return '${real.toStringAsFixed(3)} $sign ${imag.abs().toStringAsFixed(3)}i';
  }
}

class FastFourierTransform {
  /// 校验点数是否为 2 的幂次方 (N = 2^m)
  static bool _isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;

  /// 二进制位反转置换 (Bit-Reversal Permutation)
  /// 将原始顺序按二进制位倒序重排，以便后续在原数组上直接执行自底向上的蝶形运算
  static void _bitReversePermutation(List<Complex> buffer) {
    final n = buffer.length;
    int j = 0;

    for (int i = 0; i < n; i++) {
      if (i < j) {
        // 交换 i 与倒序后的索引 j 的位置
        final temp = buffer[i];
        buffer[i] = buffer[j];
        buffer[j] = temp;
      }

      // 位反转递增逻辑
      int bit = n >> 1;
      while (j & bit != 0) {
        j ^= bit;
        bit >>= 1;
      }
      j ^= bit;
    }
  }

  /// 计算前向离散傅里叶变换 (FFT)
  /// [input] 时间域实数或复数信号列表 (长度必须为 2 的幂)
  static List<Complex> fft(List<Complex> input) {
    final n = input.length;
    if (!_isPowerOfTwo(n)) {
      throw ArgumentError('采样点数 N 必须为 2 的幂次方，例如 8, 16, 1024。当前点数为: $n');
    }

    // 创建输入数据的副本，避免修改原数据（In-Place 变换缓冲区）
    final buffer = List<Complex>.from(input);

    // 步骤 1：原位置换（比特反转重排）
    _bitReversePermutation(buffer);

    // 步骤 2：逐层（Stage）迭代执行蝶形运算
    // len 表示当前合并的子变换块大小，从 2 递增到 N (2, 4, 8, ..., N)
    for (int len = 2; len <= n; len <<= 1) {
      final halfLen = len >> 1;

      // 计算当前子块的基本旋转因子 W_len = e^(-i * 2 * pi / len)
      // 根据欧拉公式 e^(i*theta) = cos(theta) + i*sin(theta)
      final angle = -2.0 * math.pi / len;
      final wBase = Complex(math.cos(angle), math.sin(angle));

      // 遍历所有长度为 len 的组
      for (int i = 0; i < n; i += len) {
        Complex w = const Complex(1.0, 0.0); // 旋转因子 W_len^0 = 1

        // 在组内执行半长 (halfLen) 次蝶形单元计算
        for (int j = 0; j < halfLen; j++) {
          final u = buffer[i + j];
          final v = buffer[i + j + halfLen] * w;

          // 核心蝶形计算 (Butterfly Equations)
          buffer[i + j] = u + v; // 上支路: X[k] = E[k] + W * O[k]
          buffer[i + j + halfLen] = u - v; // 下支路: X[k + N/2] = E[k] - W * O[k]

          // 更新旋转因子: W_len^(j+1) = W_len^j * W_len
          w = w * wBase;
        }
      }
    }

    return buffer;
  }

  /// 提取双边频谱的前半部分，计算单边物理幅值谱 (Magnitude Spectrum)
  static List<double> getMagnitudes(List<Complex> fftResult) {
    final n = fftResult.length;
    final numBins = n ~/ 2; // 根据奈奎斯特采样定理，只保留 0 ~ N/2 的频点
    final magnitudes = List<double>.filled(numBins, 0.0);

    for (int k = 0; k < numBins; k++) {
      // 归一化振幅：除以总点数 N (对于 DC 直流分量 k=0 不乘以 2)
      double mag = fftResult[k].magnitude / n;
      if (k > 0) {
        mag *= 2.0; // 非 DC 分量需要乘以 2 补全负频率侧能量
      }
      magnitudes[k] = mag;
    }

    return magnitudes;
  }
}
