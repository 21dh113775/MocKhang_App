import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';

class ProfileHeaderBackground extends StatelessWidget {
  final UserModel user;
  final File? selectedImage;

  const ProfileHeaderBackground({
    Key? key,
    required this.user,
    this.selectedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.brown.shade800, Colors.brown.shade400],
            ),
          ),
        ),

        // Profile avatar
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Center(
            child: ProfileAvatar(user: user, selectedImage: selectedImage),
          ),
        ),
      ],
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final UserModel user;
  final File? selectedImage;

  const ProfileAvatar({Key? key, required this.user, this.selectedImage})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'profile-image',
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 47,
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
                  ? const Icon(
                    Icons.person,
                    size: 50,
                    color: AppConstants.primaryColor,
                  )
                  : null,
        ),
      ),
    );
  }
}
