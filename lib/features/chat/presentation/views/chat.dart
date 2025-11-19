import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/features/chat/data/models/chat.dart';
import 'package:flutter_application_1/features/chat/presentation/views/messages.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('pt_BR_short', timeago.PtBrShortMessages());
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Mensagens",
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            final chat = dummyChats[index];
            final lastMessageTime = chat.messages.last.time;
            return InkWell(
              onTap: (){
                //open chats
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> MessagesView(chat: chat)));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage(AppIcons.userTwo),
                        width: 45,
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15.0),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey))
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat.users[0],
                                    style: const TextStyle(
                                        fontSize: 17, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    chat.fromProperty.title,
                                    style: const TextStyle(
                                        fontSize: 9, fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    chat.messages.last.body,
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Text(
                                timeago.format(lastMessageTime,
                                    locale: "pt_BR_short"), style: const TextStyle(
                                fontSize: 9
                              ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: dummyChats.length,
        ));
  }
}
