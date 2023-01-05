import 'package:flutter/cupertino.dart';

class FavSongProvider with ChangeNotifier{
  final List<int> fav=[];

  void addToFav(int i){
    fav.add(i);
    notifyListeners();
  }

  void remFav(int i){
    fav.remove(i);
    notifyListeners();
  }

  bool isFav(int i){
    return fav.contains(i);
  }
}