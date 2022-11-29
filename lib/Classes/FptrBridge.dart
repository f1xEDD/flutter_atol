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
    return String.fromCharCodes(pointer.asTypedList(length).toList());
  }

  static Pointer<Int32> getInt32Pointer(int length){
    return calloc.allocate<Int32>(length * 4);
  }

  static void setStringValue(Pointer<Int32> pointer, String resultString, {int stringLength = 1024}){
    resultString = getInt32PointerValueAsStringV2(pointer, stringLength);
  }

  static String getErrorDescription(Pointer<Void> fptr, LibFptr libInstance){
    int stringSize = 4096;
    Pointer<Int32> pointer = getInt32Pointer(stringSize);

    return getInt32PointerValueAsStringV2(pointer, libInstance.libfptr_error_description(fptr, pointer, stringSize));
  }
}