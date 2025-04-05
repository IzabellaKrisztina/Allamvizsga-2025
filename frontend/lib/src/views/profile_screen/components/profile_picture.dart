import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../constants/color_list.dart';
import '../../../models/auth_provider.dart';

class ProfilePicture extends StatefulWidget {
  final String name;

  const ProfilePicture({super.key, required this.name});

  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  File? _image;
  String? _profileImageUrl;
  bool _isLoading = false;
  Uint8List? _decodedBase64Image; // Store decoded image data

  @override
  void initState() {
    super.initState();
    _fetchProfilePicture();
  }

  /// Function to decode Base64 image
  Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      final String base64Data = base64String.split(',').last; // Remove prefix
      return base64Decode(base64Data);
    } catch (e) {
      print("Error decoding Base64 image: $e");
      return null;
    }
  }

  Future<void> _fetchProfilePicture() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return;

    final String token = authProvider.token!;
    final String apiUrl =
        "https://2c67-217-73-170-83.ngrok-free.app/users/${widget.name}";

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? profileImage = data['profile_picture'];

        setState(() {
          _profileImageUrl = profileImage;
          if (profileImage != null && profileImage.startsWith("data:image")) {
            _decodedBase64Image = decodeBase64Image(profileImage);
          }
        });
      } else {
        print("Failed to fetch profile picture: ${response.body}");
      }
    } catch (e) {
      print("Error fetching profile picture: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _decodedBase64Image = null; // Reset Base64 image if a new one is picked
      });

      await _uploadProfilePicture(_image!);
    }
  }

  Future<void> _uploadProfilePicture(File image) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return;

    final String token = authProvider.token!;
    final String username = "your-username"; // Replace dynamically
    final String apiUrl =
        "https://2c67-217-73-170-83.ngrok-free.app/users/$username";

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "profile_picture": base64Image,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String? uploadedImage = responseData['profile_picture'];

        setState(() {
          _profileImageUrl = uploadedImage;
          if (uploadedImage != null && uploadedImage.startsWith("data:image")) {
            _decodedBase64Image = decodeBase64Image(uploadedImage);
          }
        });
      } else {
        print("Failed to upload profile picture: ${response.body}");
      }
    } catch (e) {
      print("Error uploading profile picture: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const String textHex = COLOR_CHARCOAL;
    final Color textColor = Color(int.parse('0xFF$textHex'));

    return Column(
      children: [
        _isLoading
            ? CircularProgressIndicator()
            : CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _decodedBase64Image != null
                    ? MemoryImage(_decodedBase64Image!) // Base64 Image
                    : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? NetworkImage(_profileImageUrl!) // Normal URL Image
                        : (_image != null
                                ? FileImage(_image!) // Picked Image
                                : AssetImage(
                                    "assets/images/default_profile.webp"))
                            as ImageProvider? // Default Fallback
                    ),
                child:
                    (_profileImageUrl == null || _profileImageUrl!.isEmpty) &&
                            _image == null
                        ? Image.asset(
                            "assets/images/default_profile.webp") // Default
                        : null,
              ),
        TextButton(
          onPressed: _pickImage,
          child: Text(
            "Edit Profile Picture",
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    );
  }
}
