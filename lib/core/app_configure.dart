// =================================================================
// 📁 ARQUIVO: lib/core/app_config.dart
// =================================================================
// 🎯 Centraliza as configurações da aplicação, como chaves de ambiente.

class AppConfig {
  // Lê a variável 'SECRET_KEY_EXAMPLE' que será injetada na compilação.
  // Se a variável não for encontrada, usa o valor 'default'.
  static const secretKeyExample = String.fromEnvironment(
    'SECRET_KEY_EXAMPLE',
    defaultValue: 'Nenhuma chave fornecida',
  );

  // Adicione outras chaves aqui conforme precisar
}
