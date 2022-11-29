import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atol/c_wrappers/lib_fptr.dart';
import 'Classes/FptrBridge.dart';

LibFptr libInstance = FptrBridge.getInstance("c_libs/libfptr10.so");


void main() {
  Pointer<Pointer<Void>> fptrPointerPointer = calloc();

  int libfptrCreateStatus = libInstance.libfptr_create(fptrPointerPointer);

  libfptr_handle fptr = Pointer<Void>.fromAddress(fptrPointerPointer.address);

  print(fptr);
  print(fptrPointerPointer);
  print(libfptrCreateStatus);

  var b = '                                                                   ';

  print(libInstance);

  //Pointer<Int32> paramsPointer = calloc.allocate(b.length * 4);
  //
  //int c = libInstance.libfptr_get_settings(fptr, paramsPointer, b.length);

  int d = libInstance.libfptr_get_param_int(fptr, libfptr_param.LIBFPTR_PARAM_ETHERNET_PORT);
  print("35 => $d");

  bool isDoubleWidth = libInstance.libfptr_get_param_bool(fptr, libfptr_param.LIBFPTR_PARAM_FONT_DOUBLE_WIDTH) == 1;

  print(isDoubleWidth);

  libInstance.libfptr_set_param_bool(fptr, libfptr_param.LIBFPTR_PARAM_FONT_DOUBLE_WIDTH, 1);

  //libInstance.libfptr_apply_single_settings(fptr);

  isDoubleWidth = libInstance.libfptr_get_param_bool(fptr, libfptr_param.LIBFPTR_PARAM_FONT_DOUBLE_WIDTH) == 1;

  print(isDoubleWidth);
  //calloc.free(paramsPointer);

  //print(d);

  calloc.free(fptr);
  //calloc.free(paramsPointer);

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ATOL driver test app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Driver version: ${FptrBridge.getInt8PointerValueAsString(libInstance.libfptr_get_version_string())}',
            ),
          ],
        ),
      ),
    );
  }
}
