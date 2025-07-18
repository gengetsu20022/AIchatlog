import 'package:flutter/material.dart';
import '../models/chat_log.dart';
import '../models/chat_message.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatLog chatLog;

  const ChatDetailPage({
    super.key,
    required this.chatLog,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.chatLog.chatDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              key: const Key('chat-detail-avatar'),
              radius: 18,
              backgroundColor: const Color(0xFF10b981),
              child: Text(
                widget.chatLog.aiName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.chatLog.aiName,
              key: const Key('chat-detail-ai-name'),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF5F0E8),
        foregroundColor: const Color(0xFF2D2A26),
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('search-button'),
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('menu-button'),
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: widget.chatLog.messages.isEmpty
          ? _buildEmptyState()
          : _buildChatView(context),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'メッセージがありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(BuildContext context) {
    return Column(
      children: [
        _buildCalendarWidget(),
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              itemCount: widget.chatLog.messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildDateDivider();
                }
                final message = widget.chatLog.messages[index - 1];
                return _buildMessageBubble(context, message);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarWidget() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF5F0E8),
            const Color(0xFFF5F0E8).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month - 1,
                      _selectedDate.day,
                    );
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Text(
                '${_selectedDate.year}年 ${_selectedDate.month}月',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2A26),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month + 1,
                      _selectedDate.day,
                    );
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7;
    
    final days = ['日', '月', '火', '水', '木', '金', '土'];
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((day) => SizedBox(
            width: 40,
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: day == '日' ? Colors.red : 
                         day == '土' ? Colors.blue : 
                         Colors.grey[600],
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final dayOffset = index - startingWeekday;
            final day = dayOffset + 1;
            
            if (dayOffset < 0 || day > lastDayOfMonth.day) {
              return const SizedBox();
            }
            
            final currentDate = DateTime(_selectedDate.year, _selectedDate.month, day);
            final isToday = currentDate.year == DateTime.now().year &&
                           currentDate.month == DateTime.now().month &&
                           currentDate.day == DateTime.now().day;
            final isSelected = currentDate.year == widget.chatLog.chatDate.year &&
                              currentDate.month == widget.chatLog.chatDate.month &&
                              currentDate.day == widget.chatLog.chatDate.day;
            
            return GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10b981) :
                         isToday ? const Color(0xFF10b981).withOpacity(0.1) : 
                         null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white :
                                 isToday ? const Color(0xFF10b981) :
                                 index % 7 == 0 ? Colors.red :
                                 index % 7 == 6 ? Colors.blue :
                                 Colors.black87,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateDivider() {
    final date = widget.chatLog.chatDate;
    final dateText = '${date.year}年${date.month}月${date.day}日';
    
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateText,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final isUser = message.sender == MessageSender.user;
    final time = '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF10b981).withOpacity(0.1),
              child: Text(
                widget.chatLog.aiName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10b981),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF10b981) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            Text(
              '既読',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
