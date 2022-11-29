import 'dart:ffi';

import 'package:flutter_atol/c_wrappers/lib_fptr.dart';
import 'package:ffi/ffi.dart';


class FptrBridge{

  static LibFptr getInstance(String libraryPath){
    return LibFptr(DynamicLibrary.open(libraryPath));
  }

  static String getInt8PointerValueAsString(Pointer<Int8> pointer){
    return pointer.cast<Utf8>().toDartString();
  }

  static String getInt32PointerValueAsString(Pointer<Int32> pointer){
    return pointer.cast<Utf8>().toDartString();
  }

  static String getInt32PointerValueAsStringV2(Pointer<Int32> pointer, int length){
    var list = pointer.asTypedList(length).toList();

    return String.fromCharCodes(list);
  }

  static Pointer<Int32> getInt32Pointer(int length){
    return calloc.allocate<Int32>(length * 4);
  }

  static void setStringValue(Pointer<Int32> pointer, String resultString, {int stringLength = 1024}){
    resultString = getInt32PointerValueAsStringV2(pointer, stringLength);
  }

}