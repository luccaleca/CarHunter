import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../pagina_pesquisa.dart';
import 'mudarSenha/esqueci_senha.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final storage = FlutterSecureStorage();

  bool isLoading = false;

  Future<bool> fazerLogin(String email, String senha) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://192.168.15.15:3001/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'senha': senha,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      String authToken = data['token'];
      await storage.write(key: 'authToken', value: authToken);
      return true;
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro no Login'),
            content: Text('Credenciais inválidas. Tente novamente.'),
            actions: <Widget>[
              TextButton(
                child: Text('Fechar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return false;
    }
  }

  Future<void> fazerSolicitacaoAutenticada() async {
    try {
      String? authToken = await storage.read(key: 'authToken');

      if (authToken != null) {
        var response = await http.get(
          Uri.parse('http://192.168.15.15:3001/login'),
          headers: {'Authorization': 'Bearer $authToken'},
        );
        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
        } else {
          print('Erro na solicitação autenticada: ${response.statusCode}');
        }
      } else {
        print('Token de autenticação não encontrado.');
      }
    } catch (e) {
      print('Erro na solicitação autenticada: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Faça seu Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Icon(Icons.account_circle_sharp, size: 100),
              SizedBox(height: 20),
              FractionallySizedBox(
                widthFactor: 0.6,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: 0.6,
                child: TextField(
                  controller: senhaController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => EsqueciSenhaPage()),
                      );
                    },
                    child: Text(
                      "Esqueci minha senha",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        String email = emailController.text;
                        String senha = senhaController.text;
                        final loginSuccess = await fazerLogin(email, senha);
                        if (loginSuccess) {
                          await fazerSolicitacaoAutenticada();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaginaPrincipal()),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF0E3B50),
                  onPrimary: Colors.white,
                ),
                child: Text('Entrar'),
              ),
              if (isLoading)
                SizedBox(
                  height: 20,
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
