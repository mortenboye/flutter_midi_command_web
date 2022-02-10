import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command_web_example/fire_midi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<MidiPacket>? _rxSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  Uint8List? lastMidiMesg;

  @override
  void initState() {
    super.initState();
    _rxSubscription = _midiCommand.onMidiDataReceived?.listen((packet) {
      print('received packet: ${packet.data}');
      setState(() {
        lastMidiMesg = packet.data;
      });
    });
  }

  @override
  void dispose() {
    _rxSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: FutureBuilder<List<MidiDevice>?>(
                future: _midiCommand.devices,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const CircularProgressIndicator();
                  }
                  final devices = snapshot.data;
                  if (devices == null) {
                    return const Text('No Devices');
                  }
                  return Column(
                    children: [
                      Container(
                        height: 200,
                        child: ListView.builder(
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              return MaterialButton(
                                child: Text(_deviceLabel(devices[index])),
                                onPressed: () {
                                  setState(() {
                                    _midiCommand
                                        .connectToDevice(devices[index]);
                                  });
                                },
                              );
                            }),
                      ),
                      Text('Last midi: $lastMidiMesg'),
                      MaterialButton(
                          child: Text('FIRE ALL PADS OFF'),
                          onPressed: () {
                            print('send all off');
                            _midiCommand.sendData(
                                Uint8List.fromList(fireAllPads(0, 0, 0)));
                          })
                    ],
                  );
                })),
      ),
    );
  }

  String _deviceLabel(MidiDevice device) {
    return device.connected
        ? '${device.name} CONNECTED'
        : 'connect: ${device.name}';
  }
}
