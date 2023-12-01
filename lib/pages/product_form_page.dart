import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product_list.dart';

import '../models/product.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final priceFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final imageUrlFocus = FocusNode();
  final imageUrlController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final formData = <String, Object>{};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    imageUrlFocus.addListener(updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg != null) {
        final product = arg as Product;
        formData['id'] = product.id;
        formData['name'] = product.name;
        formData['price'] = product.price;
        formData['description'] = product.description;
        formData['imageUrl'] = product.imageUrl;
        imageUrlController.text = product.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    priceFocus.dispose();
    descriptionFocus.dispose();
    imageUrlFocus.removeListener(updateImage);
    imageUrlFocus.dispose();
  }

  void updateImage() {
    setState(() {});
  }

  Future<void> submitForm() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    formKey.currentState?.save();
    setState(() => isLoading = true);

    try {
      await Provider.of<ProductList>(
        context,
        listen: false,
      ).saveProduct(formData);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (e) {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Erro!!!'),
            content: const Text('Ocorreu um erro ao salvar o produto.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Ok'),
              )
            ],
          );
        },
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool isValidImageUrl(String url) =>
      Uri.tryParse(url)?.hasAbsolutePath ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulário de produto'),
        actions: [
          IconButton(
            onPressed: submitForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: formData['name']?.toString(),
                      decoration: const InputDecoration(labelText: 'Nome'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(priceFocus);
                      },
                      onSaved: (value) => formData['name'] = value ?? '',
                      validator: (value) {
                        value = value ?? '';
                        if (value.trim().isEmpty) return 'Nome é obrigatório';
                        if (value.trim().length < 3) {
                          return 'Nome precisa no mínimo de 3 letras';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: formData['price']?.toString(),
                      decoration: const InputDecoration(labelText: 'Preço'),
                      textInputAction: TextInputAction.next,
                      focusNode: priceFocus,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(descriptionFocus);
                      },
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onSaved: (value) => formData['price'] =
                          double.tryParse(value ?? '0') ?? 0,
                      validator: (value) {
                        final price = double.tryParse(value ?? '0') ?? 0;
                        if (price <= 0) return 'Informe um preço válido';
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: formData['description']?.toString(),
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      focusNode: descriptionFocus,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      onSaved: (value) => formData['description'] = value ?? '',
                      validator: (value) {
                        value = value ?? '';
                        if (value.trim().isEmpty)
                          return 'Descrição é obrigatório';
                        if (value.trim().length < 10) {
                          return 'Descricao precisa no mínimo de 10 letras';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: imageUrlController,
                            decoration: const InputDecoration(
                                labelText: 'Url da Imagem'),
                            focusNode: imageUrlFocus,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.url,
                            onFieldSubmitted: (_) => submitForm(),
                            onSaved: (value) =>
                                formData['imageUrl'] = value ?? '',
                            validator: (value) {
                              value = value ?? '';
                              if (!isValidImageUrl(value)) {
                                return 'Informe uma url válida';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(
                            top: 10,
                            left: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: imageUrlController.text.isEmpty
                              ? const Text('Informe a Url')
                              : Image.network(imageUrlController.text),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
