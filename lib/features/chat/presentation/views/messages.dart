import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/core/constants/colors.dart';
import 'package:flutter_application_1/core/shared/widgets/property_attribure.dart';
import 'package:flutter_application_1/features/chat/data/models/chat.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key, required this.chat});

  final Chat chat;

  @override
  MessagesViewState createState() => MessagesViewState();
}

class MessagesViewState extends State<MessagesView> {
  final TextEditingController _controller = TextEditingController();
  final me = "user_1";
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.chat.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.chat.users[0],
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_outlined),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Image(image: AssetImage(AppIcons.phoneCall), width: 25),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.chat.messages.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final message = widget.chat.messages[index];
                bool isMe = message.from == me;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            message.body,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 10.0,
                              color: isMe ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE9E9E9),
              border: Border(
                bottom: BorderSide(width: 0.9, color: Colors.grey),
              ),
            ),
            child: Row(
              children: [
                Image(
                  image: AssetImage(AppImages.beachHouse),
                  width: 90,
                  height: 90,
                  fit: BoxFit.fitHeight,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "MZN 125.000.00",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "/mês",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text(
                        widget.chat.fromProperty.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            widget.chat.fromProperty.location,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 12,
                        runSpacing: 5.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: widget.chat.fromProperty.attributes.entries
                            .map((el) {
                              return renderPropertyAttribute(el, size: 1.3);
                            })
                            .toList()
                            .sublist(
                              0,
                              widget
                                      .chat
                                      .fromProperty
                                      .attributes
                                      .entries
                                      .length -
                                  1,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: const BoxDecoration(color: Color(0xFFE9E9E9)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: () {
                    final message = _controller.text;
                    if (message.isNotEmpty) {
                      setState(() {
                        widget.chat.messages.add(
                          Message(
                            from: me,
                            body: message,
                            time: DateTime.now(),
                          ),
                        );
                        _controller.clear();
                      });
                      // Scroll after the list has been updated
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });
                    }
                  },
                  icon: Transform.rotate(
                    angle: -1.57,
                    child: const Icon(
                      Icons.arrow_forward_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
