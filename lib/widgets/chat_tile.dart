import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final String avatarPath;
  final bool isOnline;
  final int unreadCount;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const ChatTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarPath,
    this.isOnline = false,
    this.unreadCount = 0,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  Widget _buildAvatar(String path, String name) {
    if (path.isEmpty) {
      return _buildFallbackAvatar(name);
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
        );
      } else {
        return _buildFallbackAvatar(name);
      }
    }
  }

  Widget _buildFallbackAvatar(String name) {
    return Container(
      color: ShamsColors.avatarFallbackBg,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '؟',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w700,
            color: ShamsColors.primaryBlue,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? ShamsColors.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // الصورة مع حالة الاتصال
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF0F2F5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildAvatar(avatarPath, name),
                  ),
                  if (isSelected)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ShamsColors.primaryBlue.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  if (isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366), // أخضر للاتصال
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(width: 16),
            // تفاصيل المحادثة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.bold, color: ShamsColors.textGray),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.tajawal(fontSize: 12, color: unreadCount > 0 ? ShamsColors.primaryBlue : const Color(0xFF9EA3B0)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                            color: unreadCount > 0 ? ShamsColors.textGray : const Color(0xFF9EA3B0),
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: ShamsColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: GoogleFonts.tajawal(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
   );
  }
}