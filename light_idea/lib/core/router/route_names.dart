/// 路由名称常量定义
///
/// 使用示例:
/// ```dart
/// context.goNamed(RouteNames.home);
/// context.goNamed(RouteNames.ideaDetail, pathParameters: {'id': '123'});
/// ```
class RouteNames {
  RouteNames._(); // 私有构造函数，防止实例化

  /// 首页
  static const String home = 'home';

  /// 灵感详情页
  static const String ideaDetail = 'ideaDetail';

  /// 关联内容页
  static const String association = 'association';

  /// 回收站
  static const String recycleBin = 'recycleBin';

  /// 数据管理
  static const String dataManagement = 'dataManagement';

  /// 设置
  static const String settings = 'settings';

  /// AI灵感中心
  static const String aiHub = 'aiHub';

  /// AI设置
  static const String aiSettings = 'aiSettings';

  /// 帮助
  static const String help = 'help';

  /// 分类管理
  static const String categoryManagement = 'categoryManagement';

  /// 系统日志
  static const String systemLogs = 'systemLogs';
}

/// 路由路径常量定义
class RoutePaths {
  RoutePaths._(); // 私有构造函数，防止实例化

  /// 首页
  static const String home = '/';

  /// 灵感详情页
  static const String ideaDetail = '/idea/:id';

  /// 关联内容页
  static const String association = '/idea/:id/association';

  /// 回收站
  static const String recycleBin = '/recycle-bin';

  /// 数据管理
  static const String dataManagement = '/data-management';

  /// 设置
  static const String settings = '/settings';

  /// AI灵感中心
  static const String aiHub = '/ai-hub';

  /// AI设置
  static const String aiSettings = '/ai-settings';

  /// 帮助
  static const String help = '/help';

  /// 分类管理
  static const String categoryManagement = '/category-management';

  /// 系统日志
  static const String systemLogs = '/system-logs';

  /// 构建灵感详情页路径
  static String ideaDetailPath(String id) => '/idea/$id';

  /// 构建关联内容页路径
  static String associationPath(String id) => '/idea/$id/association';
}
