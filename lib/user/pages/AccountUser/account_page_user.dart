import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';
import 'package:mockhang_app/admin/providers/user_provider.dart';
import 'package:mockhang_app/user/pages/AccountUser/constants/profile_data_service.dart';
import 'package:mockhang_app/user/pages/AccountUser/constants/ui_helpers.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// Import các phần đã tách
import 'widgets/profile_avatar_widget.dart';
import 'widgets/user_stats_widget.dart';
import 'widgets/user_info_display_widget.dart';
import 'widgets/profile_edit_form_widget.dart';
import 'constants/app_constants.dart';

class AccountPageUser extends StatefulWidget {
  const AccountPageUser({Key? key}) : super(key: key);

  @override
  State<AccountPageUser> createState() => _AccountPageUserState();
}

class _AccountPageUserState extends State<AccountPageUser> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _addressController;
  late final TextEditingController _streetAddressController;
  late final TextEditingController _wardController;
  late final TextEditingController _districtController;

  String? _selectedCity;
  bool _isDefaultAddress = false;
  File? _selectedImage;
  bool _isEditing = false;
  bool _isLoading = false;

  // User stats variables
  int _completedOrderCount = 0;
  int _favoriteCount = 0;
  double _rewardPoints = 0;

  // Service instance
  late final ProfileDataService _dataService;

  @override
  void initState() {
    super.initState();
    _dataService = ProfileDataService();

    // Initialize controllers
    _fullNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _streetAddressController = TextEditingController();
    _wardController = TextEditingController();
    _districtController = TextEditingController();

    // Load initial data
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadUserData(),
      _loadOrderCount(),
      _loadFavoriteCount(),
      _loadRewardPoints(),
    ]);
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUserData();

      final user = userProvider.currentUser;
      if (user != null && mounted) {
        _fullNameController.text = user.fullName;
        _phoneNumberController.text = user.phoneNumber ?? '';
        _addressController.text = user.address ?? '';
        _parseAddress(user.address);
      }
    } catch (error) {
      if (mounted) {
        UIHelpers.showErrorSnackBar(
          context,
          'Không thể tải thông tin người dùng: ${error.toString()}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _parseAddress(String? address) {
    if (address == null || address.isEmpty) return;

    try {
      final addressParts = address.split(',').map((e) => e.trim()).toList();
      if (addressParts.isNotEmpty) {
        _streetAddressController.text = addressParts[0];
        if (addressParts.length > 1) _wardController.text = addressParts[1];
        if (addressParts.length > 2) _districtController.text = addressParts[2];
        if (addressParts.length > 3) _selectedCity = addressParts.last;
      }
    } catch (e) {
      debugPrint("Error parsing address: $e");
    }
  }

  Future<void> _loadOrderCount() async {
    // Delegate to service
    final count = await _dataService.getCompletedOrderCount();
    if (mounted) setState(() => _completedOrderCount = count);
  }

  Future<void> _loadFavoriteCount() async {
    // Delegate to service
    final count = await _dataService.getFavoriteCount();
    if (mounted) setState(() => _favoriteCount = count);
  }

  Future<void> _loadRewardPoints() async {
    // Delegate to service
    final points = await _dataService.getRewardPoints();
    if (mounted) setState(() => _rewardPoints = points);
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (pickedFile != null && mounted) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackBar(
          context,
          'Không thể chọn ảnh: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final completeAddress = UIHelpers.buildCompleteAddress(
        street: _streetAddressController.text,
        ward: _wardController.text,
        district: _districtController.text,
        city: _selectedCity,
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final bool success = await userProvider.completeUserProfile(
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        address: completeAddress,
        avatarFile: _selectedImage,
        isDefaultAddress: _isDefaultAddress,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });

        final message =
            success
                ? 'Cập nhật thông tin thành công'
                : userProvider.errorMessage ?? 'Cập nhật thất bại';

        UIHelpers.showSnackBar(
          context,
          message,
          success ? Colors.green : Colors.red,
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        UIHelpers.showErrorSnackBar(context, 'Lỗi: ${error.toString()}');
      }
    }
  }

  // void _showLogoutDialog() {
  //   UIHelpers.showConfirmDialog(
  //     context,
  //     title: 'Đăng xuất',
  //     content: 'Bạn có chắc muốn đăng xuất?',
  //     confirmText: 'ĐĂNG XUẤT',
  //     cancelText: 'HỦY',
  //     onConfirm: () {
  //       // TODO: Xử lý đăng xuất tại đây
  //       Navigator.pop(context);
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.currentUser;

          if (_isLoading || user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                pinned: true,
                backgroundColor: AppConstants.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    user.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: ProfileHeaderBackground(
                    user: user,
                    selectedImage: _selectedImage,
                  ),
                ),
                // actions: [
                //   if (!_isEditing)
                //     IconButton(
                //       icon: const Icon(Icons.logout, color: Colors.white),
                //       onPressed: _showLogoutDialog,
                //       tooltip: 'Đăng xuất',
                //     ),
                // ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!user.isProfileCompleted)
                        ProfileCompletionMessage(
                          onEditPressed:
                              () => setState(() => _isEditing = true),
                          isEditing: _isEditing,
                        ),
                      UserStatsWidget(
                        completedOrderCount: _completedOrderCount,
                        favoriteCount: _favoriteCount,
                        rewardPoints: _rewardPoints,
                      ),
                      _isEditing
                          ? ProfileEditForm(
                            formKey: _formKey,
                            fullNameController: _fullNameController,
                            phoneNumberController: _phoneNumberController,
                            streetAddressController: _streetAddressController,
                            wardController: _wardController,
                            districtController: _districtController,
                            selectedCity: _selectedCity,
                            isDefaultAddress: _isDefaultAddress,
                            selectedImage: _selectedImage,
                            user: user,
                            onPickImage: _pickImage,
                            onCityChanged:
                                (value) =>
                                    setState(() => _selectedCity = value),
                            onDefaultAddressChanged:
                                (value) => setState(
                                  () => _isDefaultAddress = value ?? false,
                                ),
                            onCancel: () => setState(() => _isEditing = false),
                            onSave: _saveChanges,
                            isLoading: _isLoading,
                          )
                          : UserInfoDisplay(
                            user: user,
                            onSettingTapped: (setting) {
                              // Handle settings navigation
                            },
                          ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton:
          _isEditing
              ? FloatingActionButton.extended(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Lưu thông tin'),
                backgroundColor: AppConstants.primaryColor,
              )
              : FloatingActionButton(
                onPressed: () => setState(() => _isEditing = true),
                backgroundColor: AppConstants.primaryColor,
                child: const Icon(Icons.edit),
                tooltip: 'Chỉnh sửa thông tin',
              ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _streetAddressController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    super.dispose();
  }
}
