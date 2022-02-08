import 'dart:io';

import 'package:acservermanager/common/shared_manager.dart';
import 'package:acservermanager/models/enums/shared_key.dart';
import 'package:acservermanager/models/server.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

part 'loading_bloc_event.dart';
part 'loading_bloc_state.dart';

class LoadingBlocBloc extends Bloc<LoadingBlocEvent, LoadingBlocState> {
  static const String _kConfigPath = "/cfg/server_cfg.ini";

  LoadingBlocBloc() : super(LoadingBlocInitial()) {
    on<LoadingBlocLoadEvent>((event, emit) async {
      await _loadServers(emit);
    });
    on<LoadingBlocAcPathSet>((event, emit) async {
      await _saveAcPath(event.acPath, emit);
    });
    on<LoadingBlocAppearanceSet>((event, emit) async {
      await _saveAppearance(event.darkMode, emit);
    });
  }

  Future<void> _loadServers(Emitter<LoadingBlocState> emit) async {
    emit(LoadingBlocLoadingState());
    final String? acPath =
        await GetIt.instance<SharedManager>().getString(SharedKey.acPath);
    debugPrint('acPath: $acPath');
    if (acPath == null) {
      emit(LoadingBlocSetAcPathState());
      return;
    }
    final darkMode =
        GetIt.instance<SharedManager>().getBool(SharedKey.appearance);
    debugPrint('darkMode: $darkMode');
    if (darkMode == null) {
      emit(LoadingBlocSetAppAppearanceState());
      return;
    }
    List<File> files = [];
    try {
      List<String> serverNames = [];
      Directory(acPath).listSync().forEach((element) {
        Directory dir = Directory(element.path);
        if (dir.listSync().length == 2) {
          serverNames.add(dir.path.replaceAll('\\', '/').split('/').last);
        }
      });
      for (String name in serverNames) {
        files.add(File('$acPath/$name/$_kConfigPath'));
      }
      debugPrint('Servers: ${serverNames.toString()}');
    } catch (e, stacktrace) {
      debugPrint("Error: $e\nStacktrace:\n$stacktrace");
      emit(LoadingBlocErrorState("An error accoured, please try again.\n$e"));
      return;
    }
    // List<String> data = await file.readAsLines();
    // final server = await compute(Server.fromFileData, data);
    final server = [Server(), Server(name: 'Another test')];
    GetIt.instance.registerSingleton(server);
    emit(LoadingBlocLoadedState(server));
  }

  Future<void> _saveAcPath(
      String acPath, Emitter<LoadingBlocState> emit) async {
    acPath += "/server";
    await GetIt.instance<SharedManager>().setString(SharedKey.acPath, acPath);
    await _loadServers(emit);
  }

  Future<void> _saveAppearance(
      bool darkMode, Emitter<LoadingBlocState> emit) async {
    await GetIt.instance<SharedManager>()
        .setBool(SharedKey.appearance, darkMode);
    await _loadServers(emit);
  }
}