import 'package:acservermanager/common/inherited_widgets/selected_server_inherited.dart';
import 'package:acservermanager/models/server.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ServerSelectorWidget extends StatefulWidget {
  final List<Server> servers;
  const ServerSelectorWidget({
    Key? key,
    required this.servers,
  }) : super(key: key);

  @override
  _ServerSelectorWidgetState createState() => _ServerSelectorWidgetState();
}

class _ServerSelectorWidgetState extends State<ServerSelectorWidget> {
  final FlyoutController _flyoutController = FlyoutController();
  int selectedServer = 0;

  @override
  Widget build(BuildContext context) {
    return DropDownButton(
      controller: _flyoutController,
      title: Text(widget.servers[selectedServer].name),
      contentWidth: 156,
      items: List.generate(
        widget.servers.length,
        (index) => DropDownButtonItem(
          onTap: () {
            selectedServer = index;
            SelectedServerInheritedWidget.of(context).selectedServer =
                widget.servers[index];
          },
          title: Text(widget.servers[index].name),
        ),
      ),
    );
  }
}
