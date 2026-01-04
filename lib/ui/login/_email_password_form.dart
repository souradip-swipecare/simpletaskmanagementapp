import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodel/auth_cubit.dart';

class _EmailPasswordForm extends StatefulWidget {
  const _EmailPasswordForm({Key? key}) : super(key: key);

  @override
  State<_EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (v) => (v == null || v.length < 6)
                ? 'Password must be 6+ chars'
                : null,
          ),
          const SizedBox(height: 12),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.loading)
                return const CircularProgressIndicator();
              return ElevatedButton(
                child: const Text('Sign in'),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final cubit = context.read<AuthCubit>();
                  await cubit.signIn(
                    email: _email.text.trim(),
                    password: _password.text,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
