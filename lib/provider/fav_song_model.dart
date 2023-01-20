import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavSongProvider with ChangeNotifier{
  List<int> fav=[];

  List<String> fav1 = [];

  void addToFav(int i){
    fav.add(i);
    setLocal();
    notifyListeners();
  }

  void remFav(int i){
    fav.remove(i);
    setLocal();
    notifyListeners();
  }

  bool isFav(int i){
    return fav.contains(i);
  }

  Future<void> getLocal() async{
    final pref = await SharedPreferences.getInstance();
    fav1 =  pref.getStringList('favorite') ?? [];
    notifyListeners();
  }

  Future<void> setLocal() async{
    final pref = await SharedPreferences.getInstance();
    await pref.setStringList('favorite',fav.toString() as List<String>);
  }

}