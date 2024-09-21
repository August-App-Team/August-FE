import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  String crucialButton = 'crucial_button';
  String button = 'button';

/* --- schedule page ---- */
  Future<void> autoGenerate() async {
    await _analytics.logSelectContent(
      contentType: button,
      itemId: '',
    );
  }

/* --- group page ---- */
  Future<void> groupCreate() async {
    await _analytics.logSelectContent(
      contentType: button,
      itemId: 'auto_gen_set_group',
    );
  }

/* --- wizard page ---- */
  Future<void> wizardCreate(String count) async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'auto_gen_get_timetables',
      parameters: {
        'filter_click_count_sum': count,
      },
    );
  }

  Future<void> wizardBack() async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'auto_gen_not_get_timetables',
    );
  }

/* --- select page ---- */
  Future<void> select() async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'auto_gen_select_timetable',
    );
  }

  Future<void> deselect() async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'auto_gen_deselect_timetable',
    );
  }

  Future<void> selectDone() async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'auto_gen_save_timetables',
    );
  }

  Future<void> selectBack() async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'auto_gen_not_save_timetables',
    );
  }

/* --- manually create page ---- */
  Future<void> manuallyCreate() async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'manual_gen_save_timetable',
    );
  }

/* --- edit page ---- */
  Future<void> editCreate() async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'edit_timetable_save',
    );
  }

/* --- bottom nav bar --- */
  Future<void> bottomNavBar(int index) async {
    String itemId = '';

    switch (index) {
      case 0:
        itemId = 'tab_search_course';
        break;
      case 1:
        itemId = 'tab_timetables';
        break;
      case 2:
        itemId = 'tab_friends';
        break;
      case 3:
        itemId = 'tab_mypage';
        break;
    }
    await _analytics.logSelectContent(
      contentType: button,
      itemId: itemId,
    );
  }

/* --- Friends page--- */
  Future<void> copyMyCode(String time) async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'friends_copy_code',
      parameters: {
        'time': time,
      },
    );
  }

  Future<void> addFriends(String code, String time) async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'friends_add_friend',
      parameters: {
        'code': code,
        'time': time,
      },
    );
  }

  Future<void> checkFriendSchedule() async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'friends_view_timetable',
    );
  }

  Future<void> checkFriendHangout() async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'friends_view_hangout',
    );
  }

  Future<void> changeIcon(String name) async {
    String itemId = '';
    switch (name) {
      case 'dark_prime':
        itemId = 'misc_set_icon1';
        break;
      case 'light_prime':
        itemId = 'misc_set_icon2';
        break;
      case 'dark_pencil':
        itemId = 'misc_set_icon3';
        break;
      case 'light_pencil':
        itemId = 'misc_set_icon4';
        break;
      default:
        Exception('Invalid icon name');
        break;
    }
    print(name);
    await _analytics.logSelectContent(contentType: button, itemId: itemId);
  }

  Future<void> deleteAccount() async {
    await _analytics.logSelectContent(
      contentType: crucialButton,
      itemId: 'user_delete_account',
    );
  }
}



/* 
To use, below is the example
  AnalyticsService().groupPageWizardCreate('button_clicked', {'button_name': 'example_button'});

*/