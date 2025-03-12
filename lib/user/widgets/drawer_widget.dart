import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  final String shopName;
  final String shopLogo;
  final Color primaryColor;
  final Color textColor;
  final Function? onProfileTap;
  final Function? onHomeTap;
  final Function? onCategoryTap;
  final Function? onCartTap;
  final Function? onOrderHistoryTap;
  final Function? onWishlistTap;
  final Function? onContactTap;
  final Function? onAboutTap;
  final Function? onLogoutTap;
  final bool isLoggedIn;
  final String? userName;
  final String? userEmail;
  final String? userAvatar;

  const DrawerWidget({
    Key? key,
    this.shopName = 'Phong Thuỷ Shop',
    this.shopLogo = 'assets/images/logo.png',
    this.primaryColor = Colors.brown,
    this.textColor = Colors.white,
    this.onProfileTap,
    this.onHomeTap,
    this.onCategoryTap,
    this.onCartTap,
    this.onOrderHistoryTap,
    this.onWishlistTap,
    this.onContactTap,
    this.onAboutTap,
    this.onLogoutTap,
    this.isLoggedIn = false,
    this.userName,
    this.userEmail,
    this.userAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.home_rounded,
                    title: 'Trang chủ',
                    onTap: () {
                      Navigator.pop(context);
                      if (onHomeTap != null) {
                        onHomeTap!();
                      }
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.category_rounded,
                    title: 'Danh mục sản phẩm',
                    onTap: () {
                      Navigator.pop(context);
                      if (onCategoryTap != null) {
                        onCategoryTap!();
                      } else {
                        // Mặc định: Điều hướng đến trang danh mục
                        Navigator.pushNamed(context, '/categories');
                      }
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.shopping_cart_rounded,
                    title: 'Giỏ hàng',
                    onTap: () {
                      Navigator.pop(context);
                      if (onCartTap != null) {
                        onCartTap!();
                      } else {
                        // Mặc định: Điều hướng đến trang giỏ hàng
                        Navigator.pushNamed(context, '/cart');
                      }
                    },
                    showBadge: true,
                    badgeCount: 3, // Có thể thay đổi thành tham số động
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite_rounded,
                    title: 'Danh sách yêu thích',
                    onTap: () {
                      Navigator.pop(context);
                      if (onWishlistTap != null) {
                        onWishlistTap!();
                      } else {
                        Navigator.pushNamed(context, '/wishlist');
                      }
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    title: 'Lịch sử đơn hàng',
                    onTap: () {
                      Navigator.pop(context);
                      if (onOrderHistoryTap != null) {
                        onOrderHistoryTap!();
                      } else {
                        Navigator.pushNamed(context, '/order-history');
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.local_offer_rounded,
                    title: 'Khuyến mãi',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/discount');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.phone_rounded,
                    title: 'Liên hệ',
                    onTap: () {
                      Navigator.pop(context);
                      if (onContactTap != null) {
                        onContactTap!();
                      } else {
                        Navigator.pushNamed(context, '/contact');
                      }
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_rounded,
                    title: 'Về chúng tôi',
                    onTap: () {
                      Navigator.pop(context);
                      if (onAboutTap != null) {
                        onAboutTap!();
                      } else {
                        Navigator.pushNamed(context, '/about');
                      }
                    },
                  ),
                  _buildDivider(),
                  if (isLoggedIn)
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Đăng xuất',
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutConfirmation(context);
                      },
                      textColor: Colors.red.shade700,
                      iconColor: Colors.red.shade700,
                    )
                  else
                    _buildMenuItem(
                      icon: Icons.login_rounded,
                      title: 'Đăng Xuất',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login');
                      },
                      textColor: primaryColor,
                      iconColor: primaryColor,
                    ),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      decoration: BoxDecoration(color: primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(5),
                child: Image.asset(
                  shopLogo,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.spa_rounded,
                      size: 30,
                      color: primaryColor,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  shopName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          if (isLoggedIn && userName != null) ...[
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (onProfileTap != null) {
                  onProfileTap!();
                } else {
                  Navigator.pushNamed(context, '/profile');
                }
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child:
                        userAvatar != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                userAvatar!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 30,
                                    color: primaryColor,
                                  );
                                },
                              ),
                            )
                            : Icon(Icons.person, size: 30, color: primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName!,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (userEmail != null)
                          Text(
                            userEmail!,
                            style: TextStyle(
                              color: textColor.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textColor.withOpacity(0.7),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Function onTap,
    bool showBadge = false,
    int badgeCount = 0,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading:
          showBadge
              ? Badge(
                label: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: Icon(icon, color: iconColor ?? Colors.grey[800]),
              )
              : Icon(icon, color: iconColor ?? Colors.grey[800]),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey[400],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      dense: true,
      onTap: () => onTap(),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Divider(color: Colors.grey[300], thickness: 1),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Phiên bản 1.0.0',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            '© 2025 Phong Thuỷ Shop. All rights reserved.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Huỷ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (onLogoutTap != null) {
                  onLogoutTap!();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// Extension cho Badge widget nếu không có sẵn trong dependencies
class Badge extends StatelessWidget {
  final Widget child;
  final Widget label;
  final Color backgroundColor;

  const Badge({
    Key? key,
    required this.child,
    required this.label,
    this.backgroundColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Center(child: label),
          ),
        ),
      ],
    );
  }
}
