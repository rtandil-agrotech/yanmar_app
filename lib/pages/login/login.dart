import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yanmar_app/bloc/auth_bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const route = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword = false;
  final GlobalKey<FormState> formKey = GlobalKey();

  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_back),
        onPressed: () {
          context.go('/');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) {
          return p != c;
        },
        listener: (context, state) {
          if (state is AuthenticatedState) {
            context.go('/');
          } else if (state is FailedToAuthenticate) {
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('Failed to Login'),
                    content: Text(state.message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _.pop();
                        },
                        child: const Text('Dismiss'),
                      )
                    ],
                  );
                });
          }
        },
        child: Form(
          key: formKey,
          child: Center(
            child: SizedBox(
              width: 450,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      setState(() {
                        email = value?.trim() ?? '';
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Your email",
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      obscureText: !showPassword,
                      onSaved: (value) {
                        password = value?.trim() ?? '';
                      },
                      decoration: InputDecoration(
                        hintText: "Your password",
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(Icons.lock),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            icon: Icon(showPassword == false ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (context.read<AuthBloc>().state is AuthenticatedState) {
                        await showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text('You are already logged in'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _.pop();
                                    },
                                    child: const Text('Dismiss'),
                                  )
                                ],
                              );
                            });
                      } else {
                        formKey.currentState?.save();
                        final valid = formKey.currentState?.validate();
                        if (valid != null && valid) {
                          context.read<AuthBloc>().add(LogIn(email: email, password: password));
                        }
                      }
                    },
                    child: const Text('Submit'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
