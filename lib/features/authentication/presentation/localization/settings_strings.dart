import 'package:flutter/widgets.dart';

class SettingsStrings {
  const SettingsStrings._(this._values);

  final Map<String, String> _values;

  static SettingsStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return SettingsStrings._(_translations[code] ?? _translations['en']!);
  }

  String get settings => _values['settings']!;
  String get notifications => _values['notifications']!;
  String get pushNotifications => _values['pushNotifications']!;
  String get pushSubtitle => _values['pushSubtitle']!;
  String get journeyAlerts => _values['journeyAlerts']!;
  String get journeySubtitle => _values['journeySubtitle']!;
  String get reviewResponses => _values['reviewResponses']!;
  String get reviewSubtitle => _values['reviewSubtitle']!;
  String get notificationPending => _values['notificationPending']!;
  String get languageRegion => _values['languageRegion']!;
  String get language => _values['language']!;
  String get cityRegion => _values['cityRegion']!;
  String get privacyData => _values['privacyData']!;
  String get privacyPolicy => _values['privacyPolicy']!;
  String get privacySubtitle => _values['privacySubtitle']!;
  String get locationData => _values['locationData']!;
  String get locationSubtitle => _values['locationSubtitle']!;
  String get deleteAccount => _values['deleteAccount']!;
  String get deleteSubtitle => _values['deleteSubtitle']!;
  String get deletionPending => _values['deletionPending']!;
  String get saved => _values['saved']!;
  String get saveFailed => _values['saveFailed']!;
  String get klPilot => _values['klPilot']!;

  static const _translations = <String, Map<String, String>>{
    'en': {
      'settings': 'Settings',
      'notifications': 'NOTIFICATIONS',
      'pushNotifications': 'Push Notifications',
      'pushSubtitle': 'Journey tips, rewards & updates',
      'journeyAlerts': 'Journey Alerts',
      'journeySubtitle': 'Alerts during active journeys',
      'reviewResponses': 'Review Responses',
      'reviewSubtitle': 'When someone replies to your review',
      'notificationPending': 'Available after notification setup',
      'languageRegion': 'LANGUAGE & REGION',
      'language': 'Language',
      'cityRegion': 'City / Region',
      'privacyData': 'PRIVACY & DATA',
      'privacyPolicy': 'Privacy Policy',
      'privacySubtitle': 'How we use your data',
      'locationData': 'Location Data',
      'locationSubtitle': 'Used only during active journeys',
      'deleteAccount': 'Delete Account',
      'deleteSubtitle': 'Permanently remove your data',
      'deletionPending': 'Choose immediate or recoverable deletion first.',
      'saved': 'Settings saved across your devices.',
      'saveFailed': 'Unable to save settings.',
      'klPilot': 'Kuala Lumpur is the only region in the current pilot.',
    },
    'ms': {
      'settings': 'Tetapan',
      'notifications': 'PEMBERITAHUAN',
      'pushNotifications': 'Pemberitahuan Tolak',
      'pushSubtitle': 'Petua perjalanan, ganjaran dan kemas kini',
      'journeyAlerts': 'Makluman Perjalanan',
      'journeySubtitle': 'Makluman semasa perjalanan aktif',
      'reviewResponses': 'Balasan Ulasan',
      'reviewSubtitle': 'Apabila seseorang membalas ulasan anda',
      'notificationPending': 'Tersedia selepas pemberitahuan disediakan',
      'languageRegion': 'BAHASA & WILAYAH',
      'language': 'Bahasa',
      'cityRegion': 'Bandar / Wilayah',
      'privacyData': 'PRIVASI & DATA',
      'privacyPolicy': 'Dasar Privasi',
      'privacySubtitle': 'Cara kami menggunakan data anda',
      'locationData': 'Data Lokasi',
      'locationSubtitle': 'Digunakan semasa perjalanan aktif sahaja',
      'deleteAccount': 'Padam Akaun',
      'deleteSubtitle': 'Padam data anda secara kekal',
      'deletionPending': 'Pilih pemadaman segera atau boleh dipulihkan dahulu.',
      'saved': 'Tetapan disimpan pada semua peranti anda.',
      'saveFailed': 'Tetapan tidak dapat disimpan.',
      'klPilot': 'Kuala Lumpur ialah satu-satunya wilayah untuk perintis ini.',
    },
    'zh': {
      'settings': '设置',
      'notifications': '通知',
      'pushNotifications': '推送通知',
      'pushSubtitle': '旅程提示、奖励与更新',
      'journeyAlerts': '旅程提醒',
      'journeySubtitle': '在进行中的旅程中提醒',
      'reviewResponses': '评论回复',
      'reviewSubtitle': '有人回复您的评论时通知',
      'notificationPending': '将在通知功能配置后开放',
      'languageRegion': '语言与地区',
      'language': '语言',
      'cityRegion': '城市／地区',
      'privacyData': '隐私与数据',
      'privacyPolicy': '隐私政策',
      'privacySubtitle': '我们如何使用您的数据',
      'locationData': '位置数据',
      'locationSubtitle': '仅在进行中的旅程中使用',
      'deleteAccount': '删除账户',
      'deleteSubtitle': '永久删除您的数据',
      'deletionPending': '请先选择立即删除或可恢复删除。',
      'saved': '设置已同步至您的所有设备。',
      'saveFailed': '无法保存设置。',
      'klPilot': '当前试点仅支持吉隆坡。',
    },
  };
}
