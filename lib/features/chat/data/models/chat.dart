
import 'package:flutter_application_1/features/home/data/models/property.dart';

class Chat{
  final List<String> users;
  final List<Message> messages;
  final Property fromProperty;
  const Chat({required this.users, required this.messages, required this.fromProperty, });
}

class Message {
  final String from;
  final String body;
  final DateTime time;

  const Message({required this.from, required this.body, required this.time});
}

final List<Chat> dummyChats = [
  Chat(
    users: ["user_2", "user_1"],
    fromProperty: properties[0], // Referring to the first property in your list
    messages: [
      Message(
        from: "user_1",
        body: "Olá, esta casa ainda está disponível para arrendar?",
        time: DateTime.now().subtract(Duration(minutes: 10)),
      ),
      Message(
        from: "user_2",
        body: "Sim, está disponível. Gostaria de marcar uma visita?",
        time: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      Message(
        from: "user_1",
        body: "Sim, amanhã às 15h estaria ótimo!",
        time: DateTime.now().subtract(Duration(minutes: 2)),
      ),
    ],
  ),
  Chat(
    users: ["user_3", "user_1"],
    fromProperty: properties[1], // Referring to the second property in your list
    messages: [
      Message(
        from: "user_1",
        body: "Oi, o terreno ainda está à venda?",
        time: DateTime.now().subtract(Duration(hours: 1)),
      ),
      Message(
        from: "user_3",
        body: "Sim, está. Posso fornecer mais detalhes se precisar.",
        time: DateTime.now().subtract(Duration(minutes: 50)),
      ),
      Message(
        from: "user_3",
        body: "Ótimo! Pode me enviar a documentação disponível?",
        time: DateTime.now().subtract(Duration(minutes: 30)),
      ),
      Message(
        from: "user_4",
        body: "Claro, vou enviar agora mesmo.",
        time: DateTime.now().subtract(Duration(minutes: 20)),
      ),
    ],
  ),
];
