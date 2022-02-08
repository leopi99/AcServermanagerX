import 'package:acservermanager/common/inherited_widgets/selected_server_inherited.dart';
import 'package:acservermanager/models/server.dart';
import 'package:acservermanager/presentation/homepage/homepage.dart';
import 'package:acservermanager/presentation/settings/settings_page.dart';
import 'package:acservermanager/presentation/skeleton/bloc/skeleton_bloc.dart';
import 'package:acservermanager/presentation/skeleton/presentation/widgets/server_selector_widget.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:get_it/get_it.dart';

class SkeletonPage extends StatelessWidget {
  SkeletonPage({Key? key}) : super(key: key);

  final SkeletonBloc _bloc = SkeletonBloc();

  @override
  Widget build(BuildContext context) {
    return SelectedServerInheritedWidget(
      selectedServer: GetIt.I<List<Server>>().first,
      child: StreamBuilder<int>(
        stream: _bloc.currentPage,
        initialData: 0,
        builder: (context, snapshot) {
          return StreamBuilder<bool>(
            stream: _bloc.panelOpen,
            initialData: true,
            builder: (context, panelOpenSnapshot) {
              return NavigationView(
                content: NavigationBody(
                  index: snapshot.data!,
                  children: const [
                    Homepage(),
                    SettingsPage(),
                  ],
                ),
                pane: NavigationPane(
                  onChanged: _bloc.changePage,
                  menuButton: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: panelOpenSnapshot.data!
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(material.Icons.menu),
                          onPressed: () {
                            _bloc.changePaneOpen(!panelOpenSnapshot.data!);
                          },
                        ),
                      ],
                    ),
                  ),
                  displayMode: panelOpenSnapshot.data!
                      ? PaneDisplayMode.open
                      : PaneDisplayMode.compact,
                  selected: snapshot.data!,
                  header: Button(
                    child: const Text('Select server'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => ContentDialog(
                          content: ServerSelectorWidget(
                            servers: [
                              GetIt.I<Server>(),
                            ],
                          ),
                          actions: [
                            FilledButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  footerItems: [
                    PaneItem(
                      icon: const Icon(FluentIcons.settings),
                      title: const Text('Settings'),
                    ),
                  ],
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.home),
                      title: const Text('Home'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
