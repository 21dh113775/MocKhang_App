import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';

class ProfileEditForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController streetAddressController;
  final TextEditingController wardController;
  final TextEditingController districtController;
  final String? selectedCity;
  final bool isDefaultAddress;
  final File? selectedImage;
  final UserModel user;
  final VoidCallback onPickImage;
  final Function(String?) onCityChanged;
  final Function(bool?) onDefaultAddressChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isLoading;

  const ProfileEditForm({
    Key? key,
    required this.formKey,
    required this.fullNameController,
    required this.phoneNumberController,
    required this.streetAddressController,
    required this.wardController,
    required this.districtController,
    this.selectedCity,
    required this.isDefaultAddress,
    this.selectedImage,
    required this.user,
    required this.onPickImage,
    required this.onCityChanged,
    required this.onDefaultAddressChanged,
    required this.onCancel,
    required this.onSave,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Chỉnh sửa thông tin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarEditor(),
              const SizedBox(height: 24),
              _buildBasicInfoCard(),
              const SizedBox(height: 20),
              _buildAddressCard(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarEditor() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 57,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  selectedImage != null
                      ? FileImage(selectedImage!)
                      : (user.avatarUrl != null
                          ? CachedNetworkImageProvider(user.avatarUrl!)
                              as ImageProvider
                          : null),
              child:
                  selectedImage == null && user.avatarUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.brown)
                      : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: onPickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.brown,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cơ bản',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person, color: Colors.brown),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.brown, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone, color: Colors.brown),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.brown, width: 2),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                if (value.length < 10) {
                  return 'Số điện thoại không hợp lệ';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.brown),
                const SizedBox(width: 8),
                const Text(
                  'Địa chỉ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 24),
            TextFormField(
              controller: streetAddressController,
              decoration: InputDecoration(
                labelText: 'Số nhà, tên đường',
                hintText: 'Ví dụ: 123 Nguyễn Văn A',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.home, color: Colors.brown),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.brown, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập địa chỉ đường';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: wardController,
              decoration: InputDecoration(
                labelText: 'Phường/Xã',
                hintText: 'Ví dụ: Phường 1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(
                  Icons.location_city,
                  color: Colors.brown,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.brown, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập phường/xã';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: districtController,
              decoration: InputDecoration(
                labelText: 'Quận/Huyện',
                hintText: 'Ví dụ: Quận 1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(
                  Icons.location_city,
                  color: Colors.brown,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.brown, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập quận/huyện';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCity,
              decoration: InputDecoration(
                labelText: 'Tỉnh/Thành phố',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(
                  Icons.location_city,
                  color: Colors.brown,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.brown, width: 2),
                ),
              ),
              items:
                  AppConstants.vietnamCities.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: onCityChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn tỉnh/thành phố';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text(
                'Đặt làm địa chỉ mặc định',
                style: TextStyle(fontSize: 14),
              ),
              value: isDefaultAddress,
              activeColor: Colors.brown,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: onDefaultAddressChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('HỦY'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text('LƯU THAY ĐỔI'),
          ),
        ),
      ],
    );
  }
}
