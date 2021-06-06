import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions{
  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  //name
  static String sharedPreferenceUserNameKey = "USERNAMEKEY";
  //email
  static String sharedPreferenceUserEmailKey = "USEREMAILKEY";
  //id
  static String sharedPreferenceUserIdKey = "USERIDKEY";
  //photo
  static String sharedPreferenceUserPhotoUrlKey = "USERPHOTOKEY";
  //about
  static String sharedPreferenceUserAboutMeKey = "USERINFOKEY";

  /// saving data to sharedpreference
  static Future<bool> saveUserLoggedInSharedPreference(bool isUserLoggedIn) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }
  static Future<bool> saveUserNameSharedPreference(String userName) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserNameKey, userName);
  }
  static Future<bool> saveUserEmailSharedPreference(String userEmail) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserEmailKey, userEmail);
  }
  static Future<bool> saveUserIdSharedPreference(String userId) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserIdKey, userId);
  }
  static Future<bool> saveUserPhotoUrlSharedPreference(String photoUrl) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserPhotoUrlKey, photoUrl);
  }
  static Future<bool> saveUserAboutMeSharedPreference(String info) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserAboutMeKey, info);
  }

  /// fetching data from sharedpreference
  static Future<bool?> getUserLoggedInSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.containsKey(sharedPreferenceUserLoggedInKey) ? preferences.getBool(sharedPreferenceUserLoggedInKey) : false;
  }
  static Future<String?> getUserNameSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserNameKey);
  }
  static Future<String?> getUserEmailSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserEmailKey);
  }
  static Future<String?> getUserIdSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserIdKey);
  }
  static Future<String?> getUserPhotoUrlSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserPhotoUrlKey);
  }
  static Future<String?> getUserAboutMeSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserAboutMeKey);
  }
  static deleteUserFromSharedPrefs() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(sharedPreferenceUserAboutMeKey);
    preferences.remove(sharedPreferenceUserEmailKey);
    preferences.remove(sharedPreferenceUserIdKey);
    preferences.remove(sharedPreferenceUserLoggedInKey);
    preferences.remove(sharedPreferenceUserNameKey);
    preferences.remove(sharedPreferenceUserPhotoUrlKey);
    preferences.clear();
  }
}