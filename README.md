# NanoMVVM 🚀

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/MarcosAC/nanomvvm/main.yaml?branch=main)
![Pub.dev Version](https://img.shields.io/pub/v/nanomvvm?label=pub.dev)
![License](https://img.shields.io/github/license/MarcosAC/nanomvvm)

---

## Propósito e Benefícios

**NanoMVVM** é uma biblioteca **minimalista e leve** para Flutter que simplifica a implementação do padrão Model-View-ViewModel (MVVM) em seus aplicativos. Inspirada na clareza e na simplicidade do **`BindingContext` do .NET** (como em Xamarin.Forms e .NET MAUI), esta lib oferece uma arquitetura limpa e reativa. É ideal para desenvolver aplicativos **escaláveis, testáveis e de fácil manutenção** no Flutter.

Com o NanoMVVM, você obtém:

* **Separação Clara de Responsabilidades:** Mantenha sua lógica de UI distinta da sua lógica de negócios e da própria interface.

* **Reatividade Simples:** As atualizações da UI são automáticas e responsivas às mudanças no seu ViewModel, com mínimo "boilerplate".

* **Familiaridade .NET:** Uma abordagem de "binding" que será intuitiva para desenvolvedores experientes em ecossistemas .NET.

* **Leveza:** Não há dependências complexas ou abstrações desnecessárias, focando apenas no essencial do MVVM.

* **Testabilidade:** ViewModels independentes da UI, o que facilita enormemente a escrita de testes unitários.

---

## Instalação

### 1. Adicione a dependência

No arquivo `pubspec.yaml` do seu projeto Flutter, adicione `nanomvvm` na seção `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  nanomvvm: ^0.0.1 # Use a versão mais recente disponível
```

Em seguida, execute flutter pub get no terminal ou clique em "Pub get" na sua IDE.

### Como Usar

O NanoMVVM é composto por duas classes principais: NanoMvvmViewModel e NanoMvvmView (que utiliza NanoMvvmViewState internamente para gerenciar o binding).

### 1. Crie seu Model

Seu Model é uma classe Dart simples que representa seus dados e lógica de domínio.

```dart
// lib/models/item.dart
class Item {
  String name;
  bool isSelected;
  Item({required this.name, this.isSelected = false});
}
```

### 2. Crie seu ViewModel

Seu ViewModel herda de NanoMvvmViewModel. Ele expõe os dados do Model para a View e contém a lógica de UI. Chame notifyListeners() (ou altere uma propriedade observável como isLoading) para notificar a View sobre as mudanças.

```dart
// lib/viewmodels/item_view_model.dart
import 'package:nanomvvm/nanomvvm.dart';
import '../models/item.dart'; // Importe seu Model

class ItemViewModel extends NanoMvvmViewModel {
  final Item _item;

  ItemViewModel(this._item);

  String get itemName => _item.name;
  bool get isItemSelected => _item.isSelected;

  void toggleSelection() {
    isLoading = true; // Ativa o indicador de carregamento
    Future.delayed(const Duration(seconds: 1), () {
      _item.isSelected = !_item.isSelected;
      isLoading = false; // Desativa o indicador de carregamento (chama notifyListeners)
    });
  }

  @override
  void init() {
    print('ItemViewModel para "${_item.name}" inicializado!');
  }

  @override
  void dispose() {
    print('ItemViewModel para "${_item.name}" descartado!');
    super.dispose();
  }
}
```

### 3. Crie sua View

Sua View herda de NanoMvvmView e implementa o método buildView. Ela recebe a instância do seu ViewModel no construtor, funcionando como o BindingContext. A View se reconstrói automaticamente quando o ViewModel notifica mudanças.

```dart
// lib/views/item_view.dart
import 'package:flutter/material.dart';
import 'package:nanomvvm/nanomvvm.dart';
import '../viewmodels/item_view_model.dart'; // Importe seu ViewModel

class ItemView extends NanoMvvmView<ItemViewModel> {
  const ItemView({Key? key, required ItemViewModel viewModel})
      : super(key: key, viewModel: viewModel);

  @override
  _ItemViewBinding createState() => _ItemViewBinding();
}

class _ItemViewBinding extends NanoMvvmViewState<ItemViewModel> {
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
```

### 4. Integre no seu main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:nanomvvm/nanomvvm.dart';
import 'models/item.dart';
import 'viewmodels/item_view_model.dart';
import 'views/item_view.dart';

void main() {
  final item1 = Item(name: 'Comprar Leite', isSelected: false);
  final item2 = Item(name: 'Pagar Contas', isSelected: true);
  final item3 = Item(name: 'Estudar Flutter', isSelected = false);

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
```

---

### Contribuindo

Contribuições são sempre bem-vindas! Se você tiver sugestões, encontrar um bug ou quiser adicionar um recurso, por favor:

    Faça um fork do repositório.

    Crie uma nova branch (git checkout -b feature/sua-feature).

    Implemente suas mudanças.

    Certifique-se de que os testes passem.

    Envie suas mudanças (git push origin feature/sua-feature).

    Abra um Pull Request.

---

Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo LICENSE para mais detalhes.

Copyright (c) 2025 Marcos AC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
