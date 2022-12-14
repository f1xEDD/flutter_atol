import 'dart:convert';
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
  //libInstance.libfptr_set_param_int(fptr.value, libfptr_param.LIBFPTR_PARAM_REPORT_TYPE, libfptr_report_type.LIBFPTR_RT_CLOSE_SHIFT);
  //libInstance.libfptr_report(fptr.value);

  //print(libInstance.libfptr_check_document_closed(fptr.value));

  print("Setting JSON OFD task");

  var ofdSettings = "\"type\" : \"registration\", \"ofd\" : { \"name\" : \"ООО \\\"Такском\\\"\", \"vatin\" : \"7704211201\", \"host\" : \"f1.taxcom.ru\", \"port\": 7777, \"dns\" : \"0.0.0.0\"}";
  //var ofdSettings = "{\"type\" : \"getRegistrationInfo\"}";

  print(ofdSettings);

  libInstance.libfptr_set_param_str(fptr.value, libfptr_param.LIBFPTR_PARAM_JSON_DATA, FptrBridge.getInt32PointerFromString(ofdSettings));
  int jsonTaskResult = libInstance.libfptr_validate_json(fptr.value);
  print(FptrBridge.getErrorDescription(fptr.value, libInstance));
  print(jsonTaskResult);

  bool isJSONTaskSetCorrectly = jsonTaskResult == 0;

  print("OFD task complete");
  print(isJSONTaskSetCorrectly);


  if (isJSONTaskSetCorrectly){
    //libInstance.libfptr_process_json(fptr.value);
    print(FptrBridge.getErrorDescription(fptr.value, libInstance));

    int stringLength = defaultStringLength * 4;

    var resultPointer = FptrBridge.getInt32Pointer(stringLength);
    stringLength = libInstance.libfptr_get_param_str(fptr.value, libfptr_param.LIBFPTR_PARAM_JSON_DATA, resultPointer, stringLength);
    print(FptrBridge.getStringValue(resultPointer, driverSettings, stringLength: stringLength));
  }


  libInstance.libfptr_set_param_int(fptr.value, 1055, libfptr_taxation_type.LIBFPTR_TT_USN_INCOME);

  print("Creating Receipt");

  //Opening Receipt (type = electronic)
  libInstance.libfptr_set_param_int(fptr.value, libfptr_param.LIBFPTR_PARAM_RECEIPT_TYPE, libfptr_receipt_type.LIBFPTR_RT_SELL);
  libInstance.libfptr_set_param_bool(fptr.value, libfptr_param.LIBFPTR_PARAM_RECEIPT_ELECTRONICALLY, 1);
  libInstance.libfptr_set_param_str(fptr.value, 1008, FptrBridge.getInt32PointerFromString("binnn852@gmail.com"));
  libInstance.libfptr_open_receipt(fptr.value);

  print("Receipt Opened");
  print(FptrBridge.getErrorDescription(fptr.value, libInstance));

  //Position registration (products in receipt)
  libInstance.libfptr_set_param_str(fptr.value, libfptr_param.LIBFPTR_PARAM_COMMODITY_NAME, FptrBridge.getInt32PointerFromString("Kent Nano White"));
  libInstance.libfptr_set_param_double(fptr.value, libfptr_param.LIBFPTR_PARAM_PRICE, 160.0);
  libInstance.libfptr_set_param_double(fptr.value, libfptr_param.LIBFPTR_PARAM_QUANTITY, 2);
  libInstance.libfptr_set_param_int(fptr.value, libfptr_param.LIBFPTR_PARAM_TAX_TYPE, libfptr_tax_type.LIBFPTR_TAX_VAT10);
  libInstance.libfptr_set_param_int(fptr.value, 1212, 1);
  libInstance.libfptr_set_param_int(fptr.value, 1214, 7);
  libInstance.libfptr_registration(fptr.value);

  print("Positions registered");
  print(FptrBridge.getErrorDescription(fptr.value, libInstance));

  //Total registration (total sum of payment)
  libInstance.libfptr_set_param_double(fptr.value, libfptr_param.LIBFPTR_PARAM_SUM, 320.0);
  libInstance.libfptr_receipt_total(fptr.value);

  print("Total registered");
  print(FptrBridge.getErrorDescription(fptr.value, libInstance));

  //Payment type (electronic)
  libInstance.libfptr_set_param_int(fptr.value, libfptr_param.LIBFPTR_PARAM_PAYMENT_TYPE, libfptr_payment_type.LIBFPTR_PT_ELECTRONICALLY);
  libInstance.libfptr_set_param_double(fptr.value, libfptr_param.LIBFPTR_PARAM_PAYMENT_SUM, 320.0);
  libInstance.libfptr_payment(fptr.value);

  print("Payment set");
  print(FptrBridge.getErrorDescription(fptr.value, libInstance));

  libInstance.libfptr_close_receipt(fptr.value);

  print("Receipt closed");
  print(FptrBridge.getErrorDescription(fptr.value, libInstance));

  while(libInstance.libfptr_check_document_closed(fptr.value) < 0){
    print(FptrBridge.getErrorDescription(fptr.value, libInstance));
  }

  libInstance.libfptr_set_param_int(fptr.value, libfptr_param.LIBFPTR_PARAM_FN_DATA_TYPE, libfptr_fn_data_type.LIBFPTR_FNDT_LAST_DOCUMENT);
  libInstance.libfptr_fn_query_data(fptr.value);

  int length = defaultStringLength;
  var resultPointer = FptrBridge.getInt32Pointer(length);
  length = libInstance.libfptr_get_param_str(fptr.value, libfptr_param.LIBFPTR_PARAM_FISCAL_SIGN, resultPointer, length);
  String fiscalSign = "";
  fiscalSign = FptrBridge.getStringValue(resultPointer, fiscalSign, stringLength: length);
  print(fiscalSign);
  print(libInstance.libfptr_get_param_int(fptr.value, libfptr_param.LIBFPTR_PARAM_DOCUMENT_NUMBER));
}

void main() {
  init();
  setSettings();
  openDeviceConnection();
  assignMountedParams();

  bool isOpened = libInstance.libfptr_is_opened(fptr.value) != 0;

  print(isOpened);

  if (isOpened){
    createReceipt();
  }

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
