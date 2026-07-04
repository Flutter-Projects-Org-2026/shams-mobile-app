import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ChatInputField extends StatefulWidget {
  final ValueChanged<String> onSendMessage;

  const ChatInputField({super.key, required this.onSendMessage});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final isNotEmpty = _messageController.text.trim().isNotEmpty;
      if (isNotEmpty != _isTyping) {
        setState(() => _isTyping = isNotEmpty);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: ext.inputFill,
        border: Border(top: BorderSide(color: ext.borderLight, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints:
                      const BoxConstraints(minHeight: 45, maxHeight: 120),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: ext.borderLight),
                  ),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    style: GoogleFonts.tajawal(
                        fontSize: 15, color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      hintText: 'اكتب رسالتك...',
                      hintStyle: GoogleFonts.tajawal(
                          color: ext.textHint, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: _isTyping
                      ? colorScheme.secondary
                      : colorScheme.onSurface.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, size: 20),
                  color: _isTyping
                      ? colorScheme.onSecondary
                      : colorScheme.onSurfaceVariant,
                  onPressed: _isTyping ? _handleSend : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}