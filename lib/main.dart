import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';

import 'dart:async';
import 'dart:convert';
import 'package:tig_bluetooth_basic/tig_bluetooth_basic.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/*class _MyHomePageState extends State<MyHomePage> {
  List<String> scandevicelist = [];
  List<BluetoothDevice> bluetoothadd = [];
  bool _scanning = false;
  FlutterScanBluetooth _bluetooth = FlutterScanBluetooth();

  String _data = 't';
  @override
  void initState() {
    super.initState();

    _bluetooth.devices.listen((device) {
      setState(() {
        _data += device.name + ' (${device.address})\n';
        scandevicelist.add(device.address);
        bluetoothadd.add(device);
      });
    });

    _bluetooth.scanStopped.listen((device) {
      setState(() {
        _scanning = false;
        _data += 'scan stopped\n';
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Text('Scan Start'),
//     flutter_scan_bluetooth: ^2.1.2 testted
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                child: Text(_scanning ? 'Stop scan' : 'Start scan'),
                onPressed: () async {
                  try {
                    if (_scanning) {
                      await _bluetooth.stopScan();
                      debugPrint("scanning stoped");
                      setState(() {
                        _data = '';
                      });
                    } else {
                      await _bluetooth.startScan(pairedDevices: false);
                      debugPrint("scanning started");
                      setState(() {
                        _scanning = true;
                      });
                    }
                  } on PlatformException catch (e) {
                    debugPrint(e.toString());
                  }
                },
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                  child: Text('check permission'),
                  onPressed: () async {
                    try {
                      await _bluetooth.requestPermissions();
                      print('All good with perms');
                    } on PlatformException catch (e) {
                      debugPrint(e.toString());
                    }
                  }),
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              child: ListView.builder(
                //itemCount: scandevicelist.length,
                itemCount: bluetoothadd.length,
                itemBuilder: (context, index) {
                  //final item = scandevicelist[index];
                  return Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black87),
                        color: Colors.white),
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          bluetoothadd[index].name == ''
                              ? '(unknown device)'
                              : bluetoothadd[index].name,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                        ElevatedButton(
                            onPressed: () {
                            }, child: Text("Connect")),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ));
}*/


class _MyHomePageState extends State<MyHomePage> {
  BluetoothManager bluetoothManager = BluetoothManager.instance;

  bool _connected = false;
  BluetoothDevice _device = BluetoothDevice();
  String tips = 'no device connect';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    // bool isAvailable = await bluetoothManager.isAvailable;
    // print('cur ble device isAvailable: $isAvailable');
    // bool isOn = await bluetoothManager.isOn;
    // print('cur ble device isOn: $isOn');

    bluetoothManager.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothManager.isConnected;

    bluetoothManager.state.listen((state) {
      print('cur device status: $state');

      switch (state) {
        case BluetoothManager.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothManager.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  void _onConnect() async {
    if (_device != null && _device.address != null) {
      await bluetoothManager.connect(_device);
    } else {
      setState(() {
        tips = 'please select device';
      });
      print('please select device');
    }
  }

  void _onDisconnect() async {
    await bluetoothManager.disconnect();
  }

  void _sendData() async {
    List<int> bytes = latin1.encode('Hello world!\n\n\n').toList();

    // Set codetable west. Add import 'dart:typed_data';
    // List<int> bytes = Uint8List.fromList(List.from('\x1Bt'.codeUnits)..add(6));
    // Text with special characters
    // bytes += latin1.encode('blåbærgrød\n\n\n');

    await bluetoothManager.writeData(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            bluetoothManager.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Text(tips),
                  ),
                ],
              ),
              Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothManager.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                    title: Text(d.name ?? ''),
                    subtitle: Text(d.address),
                    onTap: () async {
                      setState(() {
                        _device = d;
                      });
                    },
                    trailing:
                    _device != null && _device.address == d.address
                        ? Icon(
                      Icons.check,
                      color: Colors.green,
                    )
                        : null,
                  ))
                      .toList(),
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          child: Text('connect'),
                          onPressed: _connected ? null : _onConnect,
                        ),
                        SizedBox(width: 10.0),
                        ElevatedButton(
                          child: Text('disconnect'),
                          onPressed: _connected ? _onDisconnect : null,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      child: Text('Send test data'),
                      onPressed: _connected ? _sendData : null,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothManager.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => bluetoothManager.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () =>
                    bluetoothManager.startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

