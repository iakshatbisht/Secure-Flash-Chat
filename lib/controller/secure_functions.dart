import 'package:encrypt/encrypt.dart';

class SecureFunctions{
  Key? keyAES;
  IV? ivAES;
  Encrypter? encrypterAES;
  void getKeys() async{
    keyAES = Key.fromUtf8('lqk9hroue4wbfewonfl6ekwqdweq5pir');
    ivAES = IV.fromLength(16);
    encrypterAES = Encrypter(AES(keyAES!));
  }

  String encryptMessage(String input){
    var aesEncrypted = encrypterAES!.encrypt(input, iv: ivAES);
    return aesEncrypted.base64;
  }
  String decryptMessage(String encodedMessage){
   var aesDecrypted = encrypterAES!.decrypt64(encodedMessage,iv: ivAES);
    return aesDecrypted;
  }
}