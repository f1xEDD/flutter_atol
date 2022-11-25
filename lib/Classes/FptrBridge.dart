import 'dart:ffi';

import 'package:flutter_atol/c_wrappers/lib_fptr.dart';
import 'package:ffi/ffi.dart';


class FptrBridge{

  static LibFptr getInstance(String libraryPath){
    return LibFptr(DynamicLibrary.open(libraryPath));
  }

  static String getIntPointerValueAsString(Pointer<Int8> pointer){
    return pointer.cast<Utf8>().toDartString();
  }

}