import 'package:flutter/material.dart';


class RedefinicaoSenhaSucesso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redefinição de Senha Bem-sucedida'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle, // Ícone de correto
              size: 100,
              color: Colors.green, // Cor verde para o ícone de sucesso
            ),
            Text(
              'O e-mail de redefinição de senha foi enviado.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Um e-mail de redefinição de senha foi enviado para o endereço de e-mail da sua conta, mas pode levar alguns minutos para aparecer na sua caixa de entrada. Aguarde pelo menos 10 minutos antes de tentar novamente ou verifique sua caixa de spam.',
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegue de volta para a página de login ou aonde desejar
                Navigator.of(context).pop();
              },
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
