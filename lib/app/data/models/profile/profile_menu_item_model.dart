
class ProfileMenuItemModel {
  final String title;
  final String icon;
  final String route;
  final bool isLogout;

  ProfileMenuItemModel({
    required this.title,
    required this.icon,
    required this.route,
    this.isLogout = false,
  });
}
