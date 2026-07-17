import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).valueOrNull;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'S';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No active session found'));
          }

          final initials = _getInitials(user.name);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar & Display
                  Center(
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        // Email Display
                        const Text(
                          'Email Address',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name Display / Edit
                        const Text(
                          'Full Name',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        if (_isEditing) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your name',
                                    isDense: true,
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.primary),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check, color: AppColors.primary),
                                onPressed: () async {
                                  final newName = _nameController.text.trim();
                                  if (newName.isNotEmpty && newName != user.name) {
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .updateProfileName(newName);
                                  }
                                  setState(() {
                                    _isEditing = false;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  _nameController.text = user.name;
                                  setState(() {
                                    _isEditing = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading profile: $err')),
      ),
    );
  }
}
