import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/screens/contacts/contacts_screen.dart';
import '../presentation/screens/favorites/favorites_screen.dart';
// import 'package:sqflite/sqflite.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());

  static AppCubit get(context) => BlocProvider.of<AppCubit>(context);

  int currentIndex = 0;
  bool isBottomSheetShown = false;
  IconData floatingActionButtonIcon = Icons.person_add;

  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  List<Widget> screens = [
    const ContactsScreen(),
    const FavoritesScreen(),
  ];

  List<String> appBarTitles = [
    'Contacts',
    'Favorites',
  ];

  void changeScreensIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void changeBottomSheetState({
    required bool isShown,
    required IconData icon,
  }) {
    isBottomSheetShown = isShown;
    floatingActionButtonIcon = icon;
    emit(AppChangeBottomSheetState());
  }

  List<Map> contacts = [];
  List<Map> favorites = [];

  // late Database database;

  void createDatabase() {
    // openDatabase('contacts.db', version: 1, onCreate: (db, version) {
    //   if (kDebugMode) {
    //     print('database created!');
    //   }
    //   db
    //       .execute(
    //           'CREATE TABLE contacts (id INTEGER PRIMARY KEY, name TEXT, phoneNumber TEXT, type TEXT)')
    //       .then((value) {
    //     if (kDebugMode) {
    //       print('table created!');
    //     }
    //   }).catchError((error) {
    //     if (kDebugMode) {
    //       print('Error while creating table $error');
    //     }
    //   });
    // }, onOpen: (db) {
    //   getContacts(db);
    //   if (kDebugMode) {
    //     print('database opened!');
    //   }
    // }).then((value) {
    //   database = value;
    //   emit(AppOpenDatabaseState());
    // });

    getContacts();
    getFavorites();
  }

  void getContacts(/*Database database*/) async {
    emit(AppGetContactsLoadingState());

    // contacts.clear();
    // favorites.clear();

    // await database.rawQuery('SELECT * FROM contacts').then((value) {
    //   for (Map<String, Object?> element in value) {
    //     contacts.add(element);
    //
    //     if (element['type'] == 'favorite') {
    //       favorites.add(element);
    //     }
    //   }
    // });
    // emit(AppGetContactsDoneState());

    await fireStore.collection("contacts").get().then((value) {
      contacts.clear();
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in value.docs) {
        contacts.add(element.data());
      }

      emit(AppGetContactsDoneState());
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      emit(AppGetContactsErrorState());
    });
  }

  void getFavorites() async {
    emit(AppGetFavoritesLoadingState());

    await fireStore
        .collection("contacts")
        .where("type", isEqualTo: "favorite")
        .get()
        .then((value) {
      favorites.clear();
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in value.docs) {
        favorites.add(element.data());
      }
      emit(AppGetFavoritesDoneState());
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      emit(AppGetFavoritesErrorState());
    });
  }

  Future<void> insertContact({
    required String name,
    required String phoneNumber,
  }) async {
    // await database.transaction((txn) {
    //   return txn.rawInsert(
    //       'INSERT INTO contacts(name, phoneNumber, type) VALUES("$name", "$phoneNumber", "all")');
    // }).then((value) {
    //   if (kDebugMode) {
    //     print('Contact $value successfully inserted!');
    //   }
    //   emit(AppInsertContactsDoneState());
    //   getContacts(database);
    // }).catchError((error) {
    //   if (kDebugMode) {
    //     print('Error while inserting Contact $error');
    //   }
    // });

    int uniqueId = DateTime.now().millisecondsSinceEpoch;

    await fireStore.collection("contacts").doc(uniqueId.toString()).set({
      "id": uniqueId,
      "name": name,
      "phoneNumber": phoneNumber,
      "type": "all",
    }).then((value) {
      emit(AppInsertContactsDoneState());
      getContacts();
      getFavorites();
    });
  }

  void addOrRemoveFavorite({
    required String type,
    required int id,
  }) async {
    // await database.rawUpdate('UPDATE contacts SET type = ? WHERE id = ?',
    // [type, id]
    // ).then((value) {
    //   getContacts(database);
    //   emit(AppAddOrRemoveFavoriteState());
    // });

    await fireStore
        .collection("contacts")
        .doc(id.toString())
        .update({"type": type}).then((value) {
      emit(AppAddOrRemoveFavoriteState());
      getContacts();
      getFavorites();
    });
  }

  Future<void> editContact({
    required String name,
    required String phoneNumber,
    required int id,
  }) async {
    // await database.rawUpdate('UPDATE contacts SET name = ?, phoneNumber = ? WHERE id = ?',
    //     [name, phoneNumber, id]
    // ).then((value) {
    //   getContacts(database);
    //   emit(AppEditContactState());
    // });

    await fireStore.collection("contacts").doc(id.toString()).update({
      "name": name,
      "phoneNumber": phoneNumber,
    }).then((value) {
      emit(AppEditContactState());
      getContacts();
      getFavorites();
    });
  }

  Future<void> deleteContact({
    required int id,
  }) async {
    // await database
    //     .rawDelete('DELETE FROM contacts WHERE id = ?', [id]).then((value) {
    //   getContacts(database);
    //   emit(AppDeleteContactState());
    // });

    await fireStore
        .collection("contacts")
        .doc(id.toString())
        .delete()
        .then((value) {
      emit(AppDeleteContactState());
      getContacts();
      getFavorites();
    });
  }
}
