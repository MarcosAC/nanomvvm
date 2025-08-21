import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Uma classe base abstrata para ViewModels no padrão MVVM.
///
/// Estende [ChangeNotifier] para fornecer um mecanismo de notificação
/// de mudanças de estado para as Views.
abstract class NanoMvvmViewModel extends ChangeNotifier {
  /// Um indicador de carregamento genérico que pode ser usado por qualquer ViewModel.
  /// Quando seu valor muda, [notifyListeners] é chamado automaticamente.
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Método de inicialização.
  ///
  /// É chamado uma vez quando o ViewModel é associado pela primeira vez à sua View
  /// e está pronto para ser utilizado. Ideal para carregamento inicial de dados
  /// ou setup.
  ///
  /// [mustCallSuper] garante que subclasses que sobrescrevem este método
  /// chamem `super.init()` para manter o comportamento básico.
  @mustCallSuper
  void init() {
    // Implementações de inicialização padrão ou hooks podem ir aqui.
  }

  /// Método de descarte.
  ///
  /// É chamado quando o ViewModel não é mais necessário e será removido
  /// da memória. Essencial para liberar recursos (streams, timers, controllers)
  /// e evitar vazamentos de memória.
  ///
  /// [mustCallSuper] garante que subclasses que sobrescrevem este método
  /// chamem `super.dispose()` para garantir a limpeza adequada.
  @override
  @mustCallSuper
  void dispose() {
    _isLoading = false;
    super.dispose();
  }
}