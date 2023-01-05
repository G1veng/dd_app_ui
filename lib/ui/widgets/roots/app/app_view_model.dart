import 'package:dd_app_ui/domain/enums/tab_item.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AppViewModel extends ChangeNotifier {
  BuildContext context;
  AppViewModel({required this.context}) {
    asyncInit();
  }

  final navigationKeys = {
    TabItemEnum.home: GlobalKey<NavigatorState>(),
    TabItemEnum.search: GlobalKey<NavigatorState>(),
    TabItemEnum.profile: GlobalKey<NavigatorState>(),
    TabItemEnum.direct: GlobalKey<NavigatorState>(),
  };

  var _currentTab = TabEnums.defTab;
  TabItemEnum? beforeTab;
  TabItemEnum get currentTab => _currentTab;
  void selectTab(TabItemEnum tabItemEnum) {
    if (tabItemEnum == _currentTab) {
      navigationKeys[tabItemEnum]!
          .currentState!
          .popUntil((route) => route.isFirst);
    } else {
      beforeTab = _currentTab;
      _currentTab = tabItemEnum;
      notifyListeners();
    }
  }

  User? _user;
  User? get user => _user;
  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  Image? _avatar;
  Image? get avatar => _avatar;
  set avatar(Image? val) {
    _avatar = val;
    notifyListeners();
  }

  void asyncInit() async {
    user = await SharedPrefs.getStoredUser();
    var img = await NetworkAssetBundle(Uri.parse("$baseUrl${user!.avatar}"))
        .load("$baseUrl${user!.avatar}?v=1");
    avatar = Image.memory(
      img.buffer.asUint8List(),
      fit: BoxFit.fill,
    );
  }
}
