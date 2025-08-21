import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'nanomvvm_view_model.dart';

/// Um widget base abstrato para Views no padrão MVVM.
///
/// Ele se encarrega de gerenciar o ciclo de vida do [NanoMvvmViewModel]
/// associado e de reconstruir a interface do usuário automaticamente
/// quando o ViewModel notifica uma mudança.
///
/// [T] é o tipo do ViewModel específico que esta View irá observar.
abstract class NanoMvvmView<T extends NanoMvvmViewModel> extends StatefulWidget {
  /// O ViewModel que esta View irá observar.
  ///
  /// Ele é passado diretamente no construtor da View, funcionando como
  /// o 'BindingContext' ou a fonte de dados e lógica da UI.
  final T viewModel;

  const NanoMvvmView({Key? key, required this.viewModel}) : super(key: key);

  /// Retorna o [State] associado a esta [NanoMvvmView].
  ///
  /// `@protected` indica que este método é destinado a ser implementado
  /// por subclasses da lib ou pelo framework.
  @override
  @protected
  NanoMvvmViewState<T> createState();
}

/// O estado base para uma [NanoMvvmView].
///
/// Gerencia a inscrição e o cancelamento da inscrição do ViewModel,
/// e dispara a reconstrução da UI quando o ViewModel notifica uma mudança.
abstract class NanoMvvmViewState<T extends NanoMvvmViewModel> extends State<NanoMvvmView<T>> {
  /// A instância do ViewModel que está sendo observada.
  ///
  /// Acessível pelas subclasses para construir a interface de usuário no
  /// método [buildView].
  late T _viewModel;

  /// Getter conveniente para acessar o ViewModel na classe de construção da UI.
  @protected
  T get viewModel => _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    // Assina o ViewModel para ouvir as mudanças de estado.
    _viewModel.addListener(_onViewModelChanged);
    // Chama o método de inicialização do ViewModel.
    _viewModel.init();
  }

  /// Chamado quando as configurações do widget pai são alteradas.
  ///
  /// Garante que o listener seja removido do ViewModel antigo e adicionado
  /// ao novo ViewModel, caso a referência do ViewModel mude.
  @override
  void didUpdateWidget(covariant NanoMvvmView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewModel != oldWidget.viewModel) {
      oldWidget.viewModel.removeListener(_onViewModelChanged);
      _viewModel = widget.viewModel;
      _viewModel.addListener(_onViewModelChanged);
    }
  }

  /// Método interno que é invocado quando o ViewModel notifica uma mudança.
  ///
  /// Força a reconstrução do widget para que a interface do usuário possa
  /// refletir o novo estado do ViewModel.
  void _onViewModelChanged() {
    // Verifica se o widget ainda está montado na árvore de widgets antes de
    // chamar setState para evitar erros.
    if (mounted) {
      setState(() { });
    }
  }

  /// Chamado quando o widget é removido permanentemente da árvore de widgets.
  ///
  /// Essencial para remover o listener do ViewModel e descartar o próprio
  /// ViewModel, prevenindo vazamentos de memória.
  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  /// Este é o método abstrato que as subclasses de [NanoMvvmViewState] devem
  /// implementar para construir sua interface de usuário.
  ///
  /// Ele fornece o [BuildContext] e a instância do [viewModel] para a construção.
  @protected
  Widget buildView(BuildContext context, T viewModel);

  /// O método `build` final do StatefulWidget.
  ///
  /// Simplesmente chama [buildView] para delegar a construção da UI
  /// para as classes filhas.
  @override
  Widget build(BuildContext context) {
    return buildView(context, _viewModel);
  }
}