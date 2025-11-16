import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoreOwnerEditProfile extends StatefulWidget {
  const StoreOwnerEditProfile({Key? key}) : super(key: key);

  @override
  State<StoreOwnerEditProfile> createState() => _StoreOwnerEditProfileState();
}

class _StoreOwnerEditProfileState extends State<StoreOwnerEditProfile>
    with TickerProviderStateMixin {
  final TextEditingController _storeNameController =
      TextEditingController(text: 'My Store');
  final TextEditingController _ownerNameController =
      TextEditingController(text: 'Owner Name');

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showPasswordFields = false;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isLoading = false;

  Widget _buildPasswordField(String label, TextEditingController controller,
      bool isVisible, ValueChanged<bool> onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black54,
              ),
              onPressed: () => onToggle(!isVisible),
            ),
          ),
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Future<void> _updateProfile() async {
    // TODO: implement your Firestore/auth update logic here
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1)); // simulate saving

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Back & Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.black, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 30),

                // Card with Name, Store, Password
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Store Name
                      TextField(
                        controller: _storeNameController,
                        decoration: InputDecoration(
                          labelText: 'Store Name',
                          labelStyle: GoogleFonts.poppins(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF6A1B9A), width: 2),
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      // Owner Name
                      TextField(
                        controller: _ownerNameController,
                        decoration: InputDecoration(
                          labelText: 'Owner\'s Name',
                          labelStyle: GoogleFonts.poppins(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF6A1B9A), width: 2),
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      // Password toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Password:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showPasswordFields = !_showPasswordFields;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('EDIT'),
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _showPasswordFields
                            ? Column(
                                children: [
                                  const SizedBox(height: 20),
                                  _buildPasswordField(
                                      'Current Password:',
                                      _currentPasswordController,
                                      _isCurrentPasswordVisible, (val) {
                                    setState(() {
                                      _isCurrentPasswordVisible = val;
                                    });
                                  }),
                                  const SizedBox(height: 20),
                                  _buildPasswordField(
                                      'New Password:',
                                      _newPasswordController,
                                      _isNewPasswordVisible, (val) {
                                    setState(() {
                                      _isNewPasswordVisible = val;
                                    });
                                  }),
                                  const SizedBox(height: 20),
                                  _buildPasswordField(
                                      'Confirm Password:',
                                      _confirmPasswordController,
                                      _isConfirmPasswordVisible, (val) {
                                    setState(() {
                                      _isConfirmPasswordVisible = val;
                                    });
                                  }),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
