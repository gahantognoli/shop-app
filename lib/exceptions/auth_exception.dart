class AuthException implements Exception {
  static const Map<String, String> errors = {
    'EMAIL_EXISTS': 'E-mail já cadastrado.',
    'OPERATION_NOT_ALLOWED': 'Operacao não permitida.',
    'TOO_MANY_ATTEMPTS_TRY_LATER':
        'Acesso bloqueado temporariamente, tente novamente mais tarde.',
    'EMAIL_NOT_FOUND': 'E-mail não encontrado.',
    'INVALID_LOGIN_CREDENTIALS': 'Usuário ou senha inválido.',
    'INVALID_PASSWORD': 'Senha informada não confere',
    'USER_DISABLED': 'A conta do usuário foi desabilitada.',
  };

  final String key;

  AuthException({required this.key});

  @override
  String toString() {
    return errors[key] ?? 'Ocorreu um erro inesperado.';
  }
}
