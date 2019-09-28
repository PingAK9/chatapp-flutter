
import 'package:flutter/material.dart';

class ValueUpdate<T>
{
  ValueNotifier<T> valueNotifier;

  ValueUpdate(T init){
    valueNotifier = ValueNotifier(init);
  }
}