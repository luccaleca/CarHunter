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

  Future<void> fazerCadastro(String nome, String email, String senha) async {
  try {
    // Dados para Firebase Auth
    final authData = {
      "email": email,
      "senha": senha,
    };

    // Dados para MongoDB
    final mongoData = {
      "nome": nome,
      "email": email,
    };

    UserCredential userCredential;

    try {
      // Primeiro, crie o usuário no Firebase Auth
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
    } catch (error) {
      print('Erro ao criar usuário no Firebase Auth: $error');
      // Lide com o erro, como mostrar uma mensagem de erro ao usuário
      return;
    }

    if (userCredential.user != null && userCredential.user!.email != null) {
      final email = userCredential.user!.email;

      // Se o usuário foi criado no Firebase Auth com sucesso, agora envie os dados para o MongoDB
      final response = await http.post(
        Uri.parse('http://192.168.15.15:3001/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(mongoData),
      );

      if (response.statusCode == 201) {
        print('Usuário cadastrado com sucesso no Firebase e no MongoDB');
        // Lide com a resposta do servidor MongoDB ou Firebase Auth, se necessário
      } else {
        print('Erro ao cadastrar usuário no MongoDB');
        // Lide com o erro, como mostrar uma mensagem de erro ao usuário
      }
    } else {
      print('Erro ao criar usuário no Firebase Auth');
      // Lide com o erro, como mostrar uma mensagem de erro ao usuário
    }
  } catch (error) {
    print('Erro ao realizar a solicitação: $error');
    // Lide com o erro, como mostrar uma mensagem de erro ao usuário
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
          await fazerCadastro(nome, email, senha);
          // O usuário foi cadastrado com sucesso, você pode navegar para a próxima tela ou realizar alguma outra ação aqui.
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Sucesso no Cadastro'),
                content: Text('Usuário cadastrado com sucesso!'),
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
        } catch (e) {
          print('Erro ao chamar a função cadastrarUsuario: $e');
          // Se houver algum erro na chamada de API, tratar aqui e mostrar uma mensagem de erro.
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Erro no Cadastro'),
                content: Text('Ocorreu um erro ao cadastrar o usuário: $e'),
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
