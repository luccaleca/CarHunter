import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class CadastroPage extends StatefulWidget {
  @override
  CadastroPageState createState() => CadastroPageState();
}

class CadastroPageState extends State<CadastroPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController =
      TextEditingController();
  String senhaError = '';

  bool aceitouTermos = false;
  bool senhaVisivel = false;

  bool senhasIguais() {
    return senhaController.text == confirmarSenhaController.text;
  }

  String nomeDoUsuario = '';

  Future<void> cadastrarUsuario(String nome, String email, String senha) async {
    if (senha.length < 6) {
      setState(() {
        senhaError = 'A senha deve ter pelo menos 6 caracteres.';
      });
      return;
    }

    // Limpar o erro se a senha for válida.
    setState(() {
      senhaError = '';
    });
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  void fazerCadastro(email, senha) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (userCredential.user != null && userCredential.user!.email != null) {
        final email = userCredential.user!.email;

        if (userCredential.user != null && userCredential.user!.email != null) {
          final email = userCredential.user!.email!;

          if (isValidEmail(email)) {
            // O e-mail é válido, faça o que precisa com ele
            print('Usuário cadastrado com sucesso e autenticado no Firebase');
            // Salvar o e-mail no MongoDB
            final emailParaMongoDB = email;
            final nomeParaMongoDB = nomeDoUsuario;
            // Realize a chamada de API para salvar no MongoDB
            final response = await http.post(
              Uri.parse(
                  'http://192.168.15.15:3001/users'), // URL do servidor Node.js
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                'nome': nomeParaMongoDB,
                'email': emailParaMongoDB,
              }),
            );

            if (response.statusCode == 200) {
              // Você não precisa autenticar novamente no Firebase aqui, pois o usuário já está autenticado.
              final emailParaMongoDB = email; // Corrija a variável para usar o e-mail correto
              // Faça o que precisa com o email
              print('Usuário cadastrado com sucesso e autenticado no Firebase');
            } else {
              throw Exception('Falha ao cadastrar usuário');
            }
          } else {
            // O e-mail é inválido
            print('E-mail inválido');
          }
        } else {
          // O usuário ou o email é nulo
          print('Usuário ou email nulos');
        }
      }
    } catch (error) {
      // Trate erros de autenticação aqui
      print('Erro ao criar conta no Firebase: $error');
      throw error;
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
              const Text(
                'Faça seu Cadastro',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              FractionallySizedBox(
                widthFactor: 0.6,
                child: TextField(
                  controller: nomeController,
                  onChanged: (value) {
                    setState(() {
                      nomeDoUsuario = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: 0.6,
                child: TextField(
                  controller: senhaController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          senhaVisivel = !senhaVisivel;
                        });
                      },
                      icon: Icon(senhaVisivel
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                  ),
                  obscureText: !senhaVisivel,
                ),
              ),
              const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: 0.6,
                child: TextField(
                  controller: confirmarSenhaController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: aceitouTermos,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Política de Privacidade'),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    // Texto da política de privacidade
                                    ''' Termos de Uso - Car Hunters


                                    ''',
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        aceitouTermos = !aceitouTermos;
                                        if (!aceitouTermos) {
                                          confirmarSenhaController.text = '';
                                        }
                                      });
                                    },
                                    child: Text(aceitouTermos
                                        ? 'Desmarcar Termos de Privacidade'
                                        : 'Aceitar Termos de Privacidade'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(aceitouTermos
                        ? 'Termos de Privacidade Aceitos'
                        : 'Toque para Ler Termos de Privacidade'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (aceitouTermos) {
                    String nome = nomeController.text;
                    String email = emailController.text;
                    String senha = senhaController.text;

                    if (senha.length < 6) {
                      // A senha tem menos de 6 caracteres, mostra um aviso.
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Senha Inválida'),
                            content: Text(
                                'A senha deve ter pelo menos 6 caracteres.'),
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
                    } else {
                      try {
                        // Fazer a chamada de API para cadastrar o usuário
                        await cadastrarUsuario(nome, email, senha);
                        // O usuário foi cadastrado com sucesso, você pode navegar para a próxima tela ou realizar alguma outra ação aqui.
                      } catch (e) {
                        // Se houver algum erro na chamada de API, tratar aqui
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Erro no Cadastro'),
                              content: Text(
                                  'Ocorreu um erro ao cadastrar o usuário: $e'),
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
                      }
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Termos de Privacidade'),
                          content: Text(
                              'Você deve aceitar os termos de privacidade para continuar.'),
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
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF0E3B50),
                  onPrimary: Colors.white,
                ),
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
