import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/generated/simple_grpc.pbgrpc.dart';
import 'package:grpc/grpc.dart';

const coordFactor = 1e7;

class SimpleGrpcBloc {
  final controller = StreamController<String>();
  Stream<String> get stream => controller.stream;
  StreamSink<String> get sink => controller.sink;
  late final SimpleGrpcClient _stub;
  late final ClientChannel _channel;

  SimpleGrpcBloc() {
    _channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _stub = SimpleGrpcClient(_channel,
        options: CallOptions(timeout: const Duration(seconds: 30)));
  }

  void dispose() {
    controller.close();
    _channel.shutdown();
  }

  /// Run the getFeature demo. Calls getFeature with a point known to have a
  /// feature and a point known not to have a feature.
  Future<void> runGetFeature() async {
    final point1 = Point()
      ..latitude = 409146138
      ..longitude = -746188906;
    final point2 = Point()
      ..latitude = 0
      ..longitude = 0;

    sink.add('Start Simple RPC');
    await Future.delayed(const Duration(seconds: 1));

    sink.add(_printFeature(await _stub.getFeature(point1)));

    await Future.delayed(const Duration(seconds: 1));

    sink.add(_printFeature(await _stub.getFeature(point2)));
  }

  /// Run the listFeatures demo. Calls listFeatures with a rectangle containing
  /// all of the features in the pre-generated database. Prints each response as
  /// it comes in.
  Future<void> runListFeatures() async {
    final lo = Point()
      ..latitude = 400000000
      ..longitude = -750000000;
    final hi = Point()
      ..latitude = 420000000
      ..longitude = -730000000;
    final rect = Rectangle()
      ..lo = lo
      ..hi = hi;

    debugPrint('Looking for features between 40, -75 and 42, -73');
    sink.add('Start Server-side streaming RPC');
    await Future.delayed(const Duration(seconds: 1));
    try {
      await for (var feature in _stub.listFeatures(rect)) {
        await Future.delayed(const Duration(seconds: 1));
        sink.add(_printFeature(feature));
      }
    } catch (e) {
      debugPrint('over 30 seconds');
    }
  }

  /// Run the recordRoute demo. Sends several randomly chosen points from the
  /// pre-generated feature database with a variable delay in between. Prints
  /// the statistics when they are sent from the server.
  Future<void> runRecordRoute() async {
    Stream<Point> generateRoute(int count) async* {
      final random = Random();

      final featuresDb = await _readDatabase();

      for (var i = 0; i < count; i++) {
        final point = featuresDb[random.nextInt(featuresDb.length)].location;
        debugPrint(
            'Visiting point ${point.latitude / coordFactor}, ${point.longitude / coordFactor}');
        yield point;
        await Future.delayed(Duration(milliseconds: 200 + random.nextInt(100)));
      }
    }

    sink.add('Start Client-side streaming RPC');
    await Future.delayed(const Duration(seconds: 1));

    final summary = await _stub.recordRoute(generateRoute(10));
    debugPrint('Finished trip with ${summary.pointCount} points');
    debugPrint('Passed ${summary.featureCount} features');
    debugPrint('Travelled ${summary.distance} meters');
    debugPrint('It took ${summary.elapsedTime} seconds');

    sink.add('Finished trip with ${summary.pointCount} points');
  }

  String _printFeature(Feature feature) {
    final latitude = feature.location.latitude;
    final longitude = feature.location.longitude;
    final name = feature.name.isEmpty
        ? 'no feature'
        : 'feature called "${feature.name}"';
    final str =
        'Found $name at ${latitude / coordFactor}, ${longitude / coordFactor}';
    debugPrint(str);

    return str;
  }

  /// Run the routeChat demo. Send some chat messages, and print any chat
  /// messages that are sent from the server.
  Future<void> runRouteChat() async {
    RouteNote createNote(String message, int latitude, int longitude) {
      final location = Point()
        ..latitude = latitude
        ..longitude = longitude;
      return RouteNote()
        ..message = message
        ..location = location;
    }

    final notes = <RouteNote>[
      createNote('First message', 0, 0),
      createNote('Second message', 0, 1),
      createNote('Third message', 1, 0),
      createNote('Fourth message', 0, 0),
    ];

    Stream<RouteNote> outgoingNotes() async* {
      for (final note in notes) {
        // Short delay to simulate some other interaction.
        await Future.delayed(const Duration(milliseconds: 10));
        debugPrint(
            'Sending message ${note.message} at ${note.location.latitude}, '
            '${note.location.longitude}');
        yield note;
      }
    }

    sink.add('Start Bidirectional streaming RPC');
    await Future.delayed(const Duration(seconds: 1));

    try {
      final call = _stub.routeChat(outgoingNotes());
      await for (var note in call) {
        await Future.delayed(const Duration(seconds: 1));
        sink.add(
            'Got message ${note.message} at ${note.location.latitude}, ${note.location.longitude}');
      }
    } catch (e) {
      debugPrint('over 30 seconds');
    }
  }

  Future<List<Feature>> _readDatabase() async {
    final dbData = await rootBundle.loadString('data/route_guide_db.json');
    final List db = jsonDecode(dbData);
    return db.map((entry) {
      final location = Point()
        ..latitude = entry['location']['latitude']
        ..longitude = entry['location']['longitude'];
      return Feature()
        ..name = entry['name']
        ..location = location;
    }).toList();
  }
}
