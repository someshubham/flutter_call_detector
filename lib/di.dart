import 'package:flutter_call_detector/flavor.dart';
import 'package:flutter_call_detector/hive_constants.dart';
import 'package:flutter_call_detector/hive_data_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

GetIt locator = GetIt.instance;

class AppInjector {
  static final AppInjector _singleton = AppInjector._internal();

  factory AppInjector() => _singleton;

  AppInjector._internal();

  Flavor get flavor => _flavor;

  late Flavor _flavor;

  Future<void> configure(Flavor flavor) async {
    _flavor = flavor;

    await _initRepos();
  }

  Future<void> unregisterSingeltons() async {
    locator.unregister<MessageRepository>();
  }

  Future<void> _initRepos() async {
    locator.registerLazySingleton<MessageRepository>(
      () => switch (flavor) {
        Flavor.mock => MockMessageRepositoryImpl(),
        Flavor.prod => HiveMessageRepositoryImpl(Hive),
      },
    );
  }
}
