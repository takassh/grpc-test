import 'package:flutter/material.dart';
import 'package:flutter_client/simple_grpc_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final simpleGrpcBloc = SimpleGrpcBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Please press following button',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            StreamBuilder(
                stream: simpleGrpcBloc.stream,
                builder: (context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Text(
                      snapshot.data!,
                      style: Theme.of(context).textTheme.bodyText2,
                    );
                  }

                  return Text(
                    '',
                    style: Theme.of(context).textTheme.bodyText2,
                  );
                }),
            Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    simpleGrpcBloc.runGetFeature();
                  },
                  child: const Text('runGetFeature'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    simpleGrpcBloc.runListFeatures();
                  },
                  child: const Text('runListFeatures'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    simpleGrpcBloc.runRecordRoute();
                  },
                  child: const Text('runRecordRoute'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    simpleGrpcBloc.runRouteChat();
                  },
                  child: const Text('runRouteChat'),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
