import 'package:acservermanager/common/appearance_bloc/appearance_bloc.dart';
import 'package:acservermanager/common/inherited_widgets/selected_server_inherited.dart';
import 'package:acservermanager/common/loading_bloc/loading_bloc_bloc.dart';
import 'package:acservermanager/common/shared_manager.dart';
import 'package:acservermanager/common/singletons.dart';
import 'package:acservermanager/models/server.dart';
import 'package:acservermanager/presentation/onboarding_page/presentation/select_ac_path_page.dart';
import 'package:acservermanager/presentation/onboarding_page/presentation/select_app_theme_page.dart';
import 'package:acservermanager/presentation/skeleton/presentation/skeleton_page.dart';
import 'package:acservermanager/presentation/splash_screen/presentation/splash_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  await Singletons.initSingletons();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LoadingBlocBloc _bloc;
  late final AppearanceBloc _appearanceBloc;
  late BehaviorSubject<Server> _selectedServer;

  @override
  void initState() {
    _selectedServer = BehaviorSubject();
    _appearanceBloc = GetIt.instance<AppearanceBloc>();
    _bloc = LoadingBlocBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SelectedServerInherited(
      selectedServer: _selectedServer,
      child: Builder(builder: (context) {
        //Sets the loading state of the app
        if (_bloc.state is LoadingBlocInitial) {
          _bloc.add(LoadingBlocLoadEvent(context: context));
        }
        return StreamBuilder<bool>(
          stream: _appearanceBloc.darkMode,
          initialData: true,
          builder: (context, snapshot) {
            return FluentApp(
              title: 'Assetto Corsa Server Manager X',
              theme: snapshot.data! ? ThemeData.dark() : ThemeData.light(),
              home: BlocListener<LoadingBlocBloc, LoadingBlocState>(
                bloc: _bloc,
                listener: (context, state) {
                  if (state is LoadingBlocErrorState) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => ContentDialog(
                        title: Text(
                          'Ops! Something went wrong',
                          style: TextStyle(color: Colors.red),
                        ),
                        content: Text(state.error),
                        actions: [
                          FilledButton(
                            child: const Text('Reset the app'),
                            onPressed: () async {
                              await GetIt.I<SharedManager>().reset();
                              const MyApp();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: BlocBuilder<LoadingBlocBloc, LoadingBlocState>(
                  bloc: _bloc,
                  builder: (context, state) {
                    if (state is LoadingBlocLoadingState) {
                      return const SplashScreen();
                    } else if (state is LoadingBlocInitial) {
                      return Container(
                        color: _appearanceBloc.backgroundColor,
                      );
                    } else if (state is LoadingBlocLoadedState) {
                      return SkeletonPage();
                    } else if (state is LoadingBlocShowOnboardingState) {
                      if (state.showAcPath) {
                        return SelectAcPathPage(
                          onDone: () {
                            _bloc.add(LoadingBlocShowOnboardingEvent(
                                showAcPath: false, showAppearance: true));
                          },
                        );
                      } else if (state.showAppearance) {
                        return SelectAppThemePage(
                          onDone: () {
                            _bloc.add(LoadingBlocLoadEvent(context: context));
                          },
                        );
                      }
                    }
                    return Container(
                      color: _appearanceBloc.backgroundColor,
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
