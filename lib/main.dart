import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atol/c_wrappers/lib_fptr.dart';
import 'Classes/FptrBridge.dart';

LibFptr libInstance = FptrBridge.getInstance("c_libs/libfptr10.so");

const int defaultStringLength = 1024;

String driverSettings = "";
String deviceModelName = "";

var fptr = calloc<libfptr_handle>();

void init(){
  libInstance.libfptr_create(fptr);
}

void setSettings(){
  int stringLength = defaultStringLength;

  Pointer<Int32> paramsPointer = FptrBridge.getInt32Pointer(stringLength);

  stringLength = libInstance.libfptr_get_settings(fptr.value, paramsPointer, stringLength);
  driverSettings = FptrBridge.getStringValue(paramsPointer, driverSettings, stringLength: stringLength);

  calloc.free(paramsPointer);
}

void assignMountedParams(){
  int stringLength = defaultStringLength;

  Pointer<Int32> deviceModelNamePointer = FptrBridge.getInt32Pointer(stringLength);

  stringLength = libInstance.libfptr_get_param_str(fptr.value, libfptr_param.LIBFPTR_PARAM_MODEL_NAME, deviceModelNamePointer, stringLength);
  deviceModelName = FptrBridge.getStringValue(deviceModelNamePointer, deviceModelName, stringLength: stringLength);

  calloc.free(deviceModelNamePointer);
}

void openDeviceConnection(){
  libInstance.libfptr_open(fptr.value);
}

void createReceipt(){
  //Opening Receipt (type = electronic)
  libInstance.libfptr_set_param_int(fptr.value, libfptr_param.LIBFPTR_PARAM_RECEIPT_TYPE, libfptr_receipt_type.LIBFPTR_RT_SELL);
  libInstance.libfptr_set_param_bool(fptr.value, libfptr_param.LIBFPTR_PARAM_RECEIPT_ELECTRONICALLY, 1);
  libInstance.libfptr_set_param_str(fptr.value, 1008, "+79819476510".toNativeUtf16().cast<Int32>());
  libInstance.libfptr_open_receipt(fptr.value);

  //Position registration (products in receipt)
  libInstance.libfptr_set_param_str(fptr.value, libfptr_param.LIBFPTR_PARAM_COMMODITY_NAME, "Kent Nano White".toNativeUtf16().cast<Int32>());
  libInstance.libfptr_set_param_double(fptr.value, libfptr_param.LIBFPTR_PARAM_PRICE, 160.0);
  libInstance.libfptr_set_param_double(fptr.value, libfptr_param.LIBFPTR_PARAM_QUANTITY, 2);
  libInstance.libfptr_set_param_int(fptr.value, libfptr_param.LIBFPTR_PARAM_TAX_TYPE, libfptr_tax_type.LIBFPTR_TAX_VAT10);
  libInstance.libfptr_set_param_int(fptr.value, 1212, 2);
  libInstance.libfptr_set_param_int(fptr.value, 1214, 1);
  libInstance.libfptr_registration(fptr.value);

  //Total registration (total sum of payment)
  libInstance.libfptr_set_param_double(fptr.value, libfptr_param.LIBFPTR_PARAM_SUM, 320.0);
  libInstance.libfptr_receipt_total(fptr.value);

  //Payment type (electronic)
  libInstance.libfptr_set_param_int(fptr.value, libfptr_param.LIBFPTR_PARAM_PAYMENT_TYPE, libfptr_payment_type.LIBFPTR_PT_ELECTRONICALLY);
  libInstance.libfptr_set_param_double(fptr.value, libfptr_param.LIBFPTR_PARAM_PAYMENT_SUM, 320.0);
  libInstance.libfptr_payment(fptr.value);

  libInstance.libfptr_close_receipt(fptr.value);

  while(libInstance.libfptr_check_document_closed(fptr.value) < 0){
    print(FptrBridge.getErrorDescription(fptr.value, libInstance));
  }
}

void main() {
  init();
  setSettings();
  //openDeviceConnection();
  //assignMountedParams();

  bool isOpened = libInstance.libfptr_is_opened(fptr.value) != 0;

  print(isOpened);

  if (isOpened){
    createReceipt();
  }

  // bool isFontDoubleWidth = libInstance.libfptr_get_param_bool(fptr.value, libfptr_param.LIBFPTR_PARAM_FONT_DOUBLE_WIDTH) == 1;
  //
  // Pointer<Int32> fontParamPointer = calloc<Int32>(libfptr_param.LIBFPTR_PARAM_FONT_DOUBLE_WIDTH);
  //
  // libInstance.libfptr_set_param_bool(fptr.value, libfptr_param.LIBFPTR_PARAM_FONT_DOUBLE_WIDTH, 1);
  // libInstance.libfptr_apply_single_settings(fptr.value);
  //
  // isFontDoubleWidth = libInstance.libfptr_get_param_bool(fptr.value, libfptr_param.LIBFPTR_PARAM_FONT_DOUBLE_WIDTH) == 1;
  //
  // print(isFontDoubleWidth);
  //
  // calloc.free(fontParamPointer);
  calloc.free(fptr);
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
              'Driver version: ${FptrBridge.getInt8PointerValueAsString(libInstance.libfptr_get_version_string())}\n'
            ),
            Text(
              'Driver settings: $driverSettings\n'
            ),
            Text(
              'Device name: $deviceModelName'
            )
          ],
        ),
      ),
    );
  }
}
