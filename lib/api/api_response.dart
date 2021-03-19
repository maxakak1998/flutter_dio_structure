typedef T GenericObject<T>();

abstract class Decoder<T> {
  T fromJSON(Map<String, dynamic> json);
}

