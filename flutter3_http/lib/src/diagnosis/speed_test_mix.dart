import 'dart:math';

import 'package:http/http.dart';
import 'package:xml/xml.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/11
///
///
const Map<FileSize, int> FILE_SIZE_MAPPING = {
  FileSize.SIZE_350: 350,
  FileSize.SIZE_500: 500,
  FileSize.SIZE_750: 750,
  FileSize.SIZE_1000: 1000,
  FileSize.SIZE_1500: 1500,
  FileSize.SIZE_2000: 2000,
  FileSize.SIZE_2500: 2500,
  FileSize.SIZE_3000: 3000,
  FileSize.SIZE_3500: 3500,
  FileSize.SIZE_4500: 4500,
};

enum FileSize {
  SIZE_350,
  SIZE_500,
  SIZE_750,
  SIZE_1000,
  SIZE_1500,
  SIZE_2000,
  SIZE_2500,
  SIZE_3000,
  SIZE_3500,
  SIZE_4500,
}

const configUrl = 'https://www.speedtest.net/speedtest-config.php';

const serversUrls = [
  'https://www.speedtest.net/speedtest-servers-static.php',
  'https://c.speedtest.net/speedtest-servers-static.php',
  'https://www.speedtest.net/speedtest-servers.php',
  'https://c.speedtest.net/speedtest-servers.php',
];

const defaultDownloadSizes = [
  FileSize.SIZE_350,
  FileSize.SIZE_750,
  FileSize.SIZE_1500,
  FileSize.SIZE_3000,
];
const hars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const maxUploadSize = 4; // 400 KB

class Server {
  Server(
    this.id,
    this.name,
    this.country,
    this.sponsor,
    this.host,
    this.url,
    this.latitude,
    this.longitude,
    this.distance,
    this.latency,
    this.geoCoordinate,
  );

  Server.fromXMLElement(XmlElement? element)
    : id = int.parse(element!.getAttribute('id')!),
      name = element.getAttribute('name')!,
      country = element.getAttribute('country')!,
      sponsor = element.getAttribute('sponsor')!,
      host = element.getAttribute('host')!,
      url = element.getAttribute('url')!,
      latitude = double.parse(element.getAttribute('lat')!),
      longitude = double.parse(element.getAttribute('lon')!),
      distance = 99999999999,
      latency = 99999999999,
      geoCoordinate = Coordinate(
        double.parse(element.getAttribute('lat')!),
        double.parse(element.getAttribute('lon')!),
      );

  int id;
  String name;
  String country;
  String sponsor;
  String host;
  String url;
  double latitude;
  double longitude;
  double distance;
  double latency;
  Coordinate geoCoordinate;
}

class ServersList {
  ServersList(this.servers);

  ServersList.fromXMLElement(XmlElement? element)
    : servers = element!
          .getElement('servers')!
          .children
          .whereType<XmlElement>()
          .map((element) {
            final server = Server.fromXMLElement(element);
            return server;
          });

  Iterable<Server> servers;

  void calculateDistances(Coordinate clientCoordinate) {
    for (final s in servers) {
      s.distance = clientCoordinate.getDistanceTo(s.geoCoordinate);
    }
  }
}

class Coordinate {
  Coordinate(this.latitude, this.longitude);

  double latitude;
  double longitude;

  double getDistanceTo(Coordinate other) {
    final d1 = latitude * (pi / 180.0);
    final num1 = longitude * (pi / 180.0);
    final d2 = other.latitude * (pi / 180.0);
    final num2 = other.longitude * (pi / 180.0) - num1;
    final d3 =
        pow(sin((d2 - d1) / 2.0), 2.0) +
        cos(d1) * cos(d2) * pow(sin(num2 / 2.0), 2.0);

    return 6376500.0 * (2.0 * atan2(sqrt(d3), sqrt(1.0 - d3)));
  }
}

class Settings {
  Settings(
    this.client,
    this.times,
    this.download,
    this.upload,
    this.serverConfig,
    this.servers,
    this.odometer,
  );

  Settings.fromXMLElement(XmlElement? element)
    : client = Client.fromXMLElement(element?.getElement('client')),
      times = Times.fromXMLElement(element?.getElement('times')),
      download = Download.fromXMLElement(element?.getElement('download')),
      upload = Upload.fromXMLElement(element?.getElement('upload')),
      odometer = Odometer.fromXMLElement(element?.getElement('odometer')),
      serverConfig = ServerConfig.fromXMLElement(
        element?.getElement('server-config'),
      ),
      servers = <Server>[];
  Client client;

  Times times;

  Download download;

  Upload upload;

  ServerConfig serverConfig;

  List<Server> servers;

  Odometer odometer;
}

class Client {
  Client(
    this.ip,
    this.latitude,
    this.longitude,
    this.isp,
    this.ispRating,
    this.rating,
    this.ispAvarageDownloadSpeed,
    this.ispAvarageUploadSpeed,
    this.geoCoordinate,
  );

  Client.fromXMLElement(XmlElement? element)
    : ip = element!.getAttribute('ip')!,
      latitude = double.parse(element.getAttribute('lat')!),
      longitude = double.parse(element.getAttribute('lon')!),
      isp = element.getAttribute('isp')!,
      ispRating = double.parse(element.getAttribute('isprating')!),
      rating = double.parse(element.getAttribute('rating')!),
      ispAvarageDownloadSpeed = int.parse(element.getAttribute('ispdlavg')!),
      ispAvarageUploadSpeed = int.parse(element.getAttribute('ispulavg')!),
      geoCoordinate = Coordinate(
        double.parse(element.getAttribute('lat')!),
        double.parse(element.getAttribute('lon')!),
      );

  String ip;
  double latitude;
  double longitude;
  String isp;
  double ispRating;
  double rating;
  int ispAvarageDownloadSpeed;
  int ispAvarageUploadSpeed;
  Coordinate geoCoordinate;
}

class Times {
  Times(
    this.download1,
    this.download2,
    this.download3,
    this.upload1,
    this.upload2,
    this.upload3,
  );

  Times.fromXMLElement(XmlElement? element)
    : download1 = int.parse(element!.getAttribute('dl1')!),
      download2 = int.parse(element.getAttribute('dl2')!),
      download3 = int.parse(element.getAttribute('dl3')!),
      upload1 = int.parse(element.getAttribute('ul1')!),
      upload2 = int.parse(element.getAttribute('ul2')!),
      upload3 = int.parse(element.getAttribute('ul3')!);

  int download1;
  int download2;
  int download3;

  int upload1;
  int upload2;
  int upload3;
}

class ServerConfig {
  ServerConfig(this.ignoreIds);

  /// Factory constructor for creating a new ServerConfig from a [XmlElement].
  ServerConfig.fromXMLElement(XmlElement? element)
    : ignoreIds = element!.getAttribute('ignoreids')!;

  String ignoreIds;
}

class Upload {
  Upload(
    this.testLength,
    this.ratio,
    this.initialTest,
    this.minTestSize,
    this.threads,
    this.maxChunkSize,
    this.maxChunkCount,
    this.threadsPerUrl,
  );

  Upload.fromXMLElement(XmlElement? element)
    : testLength = int.parse(element!.getAttribute('testlength')!),
      ratio = int.parse(element.getAttribute('ratio')!),
      initialTest = int.parse(element.getAttribute('initialtest')!),
      minTestSize = element.getAttribute('mintestsize')!,
      threads = int.parse(element.getAttribute('threads')!),
      maxChunkSize = element.getAttribute('maxchunksize')!,
      maxChunkCount = element.getAttribute('maxchunkcount')!,
      threadsPerUrl = int.parse(element.getAttribute('threadsperurl')!);

  int testLength;
  int ratio;
  int initialTest;
  String minTestSize;
  int threads;
  String maxChunkSize;
  String maxChunkCount;
  int threadsPerUrl;
}

class Download {
  Download(
    this.testLength,
    this.initialTest,
    this.minTestSize,
    this.threadsPerUrl,
  );

  Download.fromXMLElement(XmlElement? element)
    : testLength = int.parse(element!.getAttribute('testlength')!),
      initialTest = element.getAttribute('initialtest')!,
      minTestSize = element.getAttribute('mintestsize')!,
      threadsPerUrl = int.parse(element.getAttribute('threadsperurl')!);

  int testLength;
  String initialTest;
  String minTestSize;
  int threadsPerUrl;
}

class Odometer {
  int start;
  int rate;

  Odometer(this.start, this.rate);

  Odometer.fromXMLElement(XmlElement? element)
    : start = int.parse(element!.getAttribute('start')!),
      rate = int.parse(element.getAttribute('rate')!);
}
