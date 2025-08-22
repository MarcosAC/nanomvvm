import 'package:flutter/material.dart';
import 'package:nanomvvm/nanomvvm.dart';

/// --- MODEL ---
/// Representa a estrutura de dados para um item simples.
/// Contém apenas dados e lógica de domínio pura.
class Item {
  String name;
  bool isSelected;

  Item({required this.name, this.isSelected = false});
}

/// --- VIEW MODEL ---
/// Gerencia o estado e a lógica da UI para um único Item.
/// Estende [NanoMvvmViewModel] da sua lib para notificação de mudanças.
class ItemViewModel extends NanoMvvmViewModel {
  final Item _item;

  ItemViewModel(this._item);

  /// Exposição das propriedades do modelo para a View.
  String get itemName => _item.name;
  bool get isItemSelected => _item.isSelected;

  /// Método para alternar o estado de seleção do item.
  /// Notifica a View da mudança usando [notifyListeners()].
  void toggleSelection() {
    isLoading = true;
    Future.delayed(const Duration(seconds: 1), () {
      _item.isSelected = !_item.isSelected;
      isLoading = false;
    });
  }

  /// Método [init()] do [NanoMvvmViewModel] para inicialização.
  /// Chamado uma vez quando o ViewModel é associado à View.
  @override
  void init() {
    super.init();     
    debugPrint('ItemViewModel para "${_item.name}" inicializado com NanoMVVM!');
  }

  /// Método [dispose()] do [NanoMvvmViewModel] para limpeza.
  /// Chamado quando o ViewModel não é mais necessário.
  @override
  void dispose() {
    debugPrint('ItemViewModel para "${_item.name}" descartado com NanoMVVM!');    
    super.dispose();
  }
}

/// --- VIEW ---
/// Representa a interface do usuário para um item.
/// Estende [NanoMvvmView] da sua lib, conectando-se ao [ItemViewModel].
class ItemView extends NanoMvvmView<ItemViewModel> {  
  const ItemView({super.key, required super.viewModel});

  /// Retorna a instância do [NanoMvvmViewState] que gerenciará o estado da View.
  @override
  ItemViewBinding createState() => ItemViewBinding();
}

/// --- BINDING (State da View) ---
/// A classe que faz a ligação entre a [ItemView] e o [ItemViewModel].
/// Estende [NanoMvvmViewState] da sua lib, que automatiza a notificação e reconstrução.
class ItemViewBinding extends NanoMvvmViewState<ItemViewModel> {
  /// Constrói a interface do usuário usando os dados do [viewModel].
  /// Este método é reconstruído automaticamente quando o ViewModel notifica mudanças.
  @override
  Widget buildView(BuildContext context, ItemViewModel viewModel) {
    return Card(
      color: viewModel.isItemSelected ? Colors.lightBlue[100] : Colors.white,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(viewModel.itemName),        
        trailing: viewModel.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Checkbox(
                value: viewModel.isItemSelected,
                onChanged: (bool? value) => viewModel.toggleSelection(),
              ),        
        onTap: viewModel.toggleSelection,
      ),
    );
  }
}

/// --- PONTO DE ENTRADA DA APLICAÇÃO ---
/// Função principal que executa o aplicativo Flutter.
void main() {  
  final item1 = Item(name: 'Comprar Leite', isSelected: false);
  final item2 = Item(name: 'Pagar Contas', isSelected: true);
  final item3 = Item(name: 'Estudar Flutter', isSelected: false);
  
  final itemViewModel1 = ItemViewModel(item1);
  final itemViewModel2 = ItemViewModel(item2);
  final itemViewModel3 = ItemViewModel(item3);

  runApp(
    MaterialApp(
      title: 'NanoMVVM Exemplo de App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Tarefas (NanoMVVM)'),
        ),
        body: ListView(
          children: [            
            ItemView(viewModel: itemViewModel1),
            ItemView(viewModel: itemViewModel2),
            ItemView(viewModel: itemViewModel3),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Como funciona:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                      '- Cada item na lista é uma `ItemView` que usa um `ItemViewModel`.'),
                  Text(
                      '- O `ItemViewModel` herda de `NanoMvvmViewModel` e notifica as Views quando o estado muda.'),
                  Text(
                      '- Ao clicar em um item, o `ItemViewModel` atualiza o estado e notifica a `ItemView` que, por sua vez, se reconstrói (graças ao `NanoMvvmViewState`).'),
                  Text(
                      '- Há um atraso de 1 segundo para simular uma operação assíncrona (ex: chamada de API) e mostrar o `CircularProgressIndicator`.'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
