import 'package:flow_sphere/Services/User_services/profile_service.dart';
import 'package:flow_sphere/Services/login_api_services.dart';
import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flow_sphere/screens/userScreens/navigation_drawer.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  // Profile data
  String _fullName = '';
  String _email = '';
  String _department = '';
  String _role = '';
  String _status = '';
  String _joiningDate = '';
  String _employeeId = '';

  // Text controllers for password fields
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  // Text controllers for editable profile fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  // State variables for profile view
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isUpdatingPassword = false;
  String? _profileImageUrl;

  // State variables for password visibility
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmNewPassword = false;

  // Validation state variables
  bool _isAtLeast6Chars = false;
  bool _passwordsMatch = false;
  bool _isDifferentFromCurrent = false;
  bool _isCurrentPasswordFilled = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    // Add listeners to the password fields for real-time validation
    _currentPasswordController.addListener(_validatePasswords);
    _newPasswordController.addListener(_validatePasswords);
    _confirmNewPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  // Load profile data from API
  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get the stored user data first
      final storedUser = await _authService.getStoredUser();
      if (storedUser == null) {
        _showErrorSnackBar('No user data found. Please login again.');
        return;
      }

      final employeeId = storedUser['_id'] ?? storedUser['id'];
      if (employeeId == null) {
        _showErrorSnackBar('Employee ID not found. Please login again.');
        return;
      }

      // Fetch fresh data from API
      final result = await _profileService.getEmployeeProfile(employeeId);
      
      if (result['success']) {
        final data = result['data'];
        setState(() {
          _employeeId = employeeId;
          _fullName = data['name'] ?? '';
          _email = data['email'] ?? '';
          _department = data['department'] ?? '';
          _role = data['role'] ?? '';
          _status = data['status'] ?? '';
          _joiningDate = _formatDate(data['createdAt']);
          
          // Update text controllers
          _fullNameController.text = _fullName;
          _emailController.text = _email;
        });
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to load profile data');
      }
    } catch (e) {
      _showErrorSnackBar('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Format date string
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // A function to handle the simulated image selection
  // ignore: unused_element
  void _pickImage() {
    // In a real application, you would use a package like 'image_picker'
    // to open the device's gallery or camera.
    // For this example, we'll just simulate a successful selection.
    setState(() {
      _profileImageUrl = 'https://placehold.co/100x100';
    });
    _showSuccessSnackBar('Image selected successfully!');
  }

  // A function to handle save and cancel logic
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save the profile changes
        // _saveProfileChanges();
      }
    });
  }

  // Save profile changes
  // ignore: unused_element
  Future<void> _saveProfileChanges() async {
    try {
      final profileData = {
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
      };

      final result = await _profileService.updateEmployeeProfile(
        employeeId: _employeeId,
        profileData: profileData,
      );

      if (result['success']) {
        setState(() {
          _fullName = _fullNameController.text.trim();
          _email = _emailController.text.trim();
        });
        _showSuccessSnackBar('Profile saved successfully!');
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to save profile');
      }
    } catch (e) {
      _showErrorSnackBar('Error saving profile: $e');
    }
  }

  // Update password
  Future<void> _updatePassword() async {
    if (!(_isAtLeast6Chars && _passwordsMatch && _isDifferentFromCurrent && _isCurrentPasswordFilled)) {
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
    });

    try {
      final result = await _profileService.resetPassword(
        email: _email,
        oldPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (result['success']) {
        _showSuccessSnackBar('Password updated successfully!');
        // Clear password fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to update password');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating password: $e');
    } finally {
      setState(() {
        _isUpdatingPassword = false;
      });
    }
  }

  void _validatePasswords() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmNewPasswordController.text;
    final currentPassword = _currentPasswordController.text;

    setState(() {
      _isAtLeast6Chars = newPassword.length >= 6;
      _passwordsMatch = newPassword == confirmPassword && newPassword.isNotEmpty;
      _isDifferentFromCurrent = newPassword != currentPassword && newPassword.isNotEmpty;
      _isCurrentPasswordFilled = currentPassword.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomNavigationDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header Section
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  // Personal Information Card
                  _buildPersonalInformationCard(),
                  const SizedBox(height: 16),
                  // Change Password Card
                  _buildChangePasswordCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage your personal information and view your details',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _toggleEditMode,
          icon: Icon(_isEditing ? Icons.save : Icons.edit, size: 18),
          label: Text(_isEditing ? 'Save Profile' : 'Edit Profile'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInformationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: _profileImageUrl != null
                          ? Colors.transparent
                          : Colors.teal,
                      radius: 30,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null
                          ? Text(
                              _getInitials(_fullName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          // onTap: _pickImage,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _role.toUpperCase(),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _department,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isEditing
                ? _buildEditableField('Full Name', _fullNameController)
                : _buildInfoRow('Full Name', _fullName, Icons.person),
            _isEditing
                ? _buildEditableField('Email', _emailController)
                : _buildInfoRow('Email', _email, Icons.email),
            _buildInfoRow('Department', _department, Icons.business),
            _buildInfoRow('Role', _role, Icons.badge),
            _buildInfoRow('Status', _status, Icons.info),
            _buildInfoRow('Joining Date', _joiningDate, Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  'Change Password',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Update your password to keep your account secure',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              'Current Password',
              _currentPasswordController,
              _showCurrentPassword,
              (bool show) {
                setState(() {
                  _showCurrentPassword = show;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              'New Password',
              _newPasswordController,
              _showNewPassword,
              (bool show) {
                setState(() {
                  _showNewPassword = show;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              'Confirm New Password',
              _confirmNewPasswordController,
              _showConfirmNewPassword,
              (bool show) {
                setState(() {
                  _showConfirmNewPassword = show;
                });
              },
            ),
            const SizedBox(height: 16),
            // Password validation checklist
            _buildValidationRow('At least 6 characters', _isAtLeast6Chars),
            _buildValidationRow('Passwords match', _passwordsMatch),
            _buildValidationRow(
              'Different from current password',
              _isDifferentFromCurrent,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdatingPassword
                    ? null
                    : (_isAtLeast6Chars &&
                            _passwordsMatch &&
                            _isDifferentFromCurrent &&
                            _isCurrentPasswordFilled)
                        ? _updatePassword
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isUpdatingPassword
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : 'Not specified',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter $label',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isVisible,
    Function(bool) onVisibilityChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            obscureText: !isVisible,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  onVisibilityChanged(!isVisible);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            // color: isValid ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              // color: isValid ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return parts[0].substring(0, 1).toUpperCase() +
          parts.last.substring(0, 1).toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '';
  }
}