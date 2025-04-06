import 'package:flutter/material.dart';

class BuscadorWidget<T extends Object> extends StatelessWidget {
  final List<T> items;
  final String Function(T) displayStringForOption;
  final void Function(T) onSelected;
  final String hintText;

  const BuscadorWidget({
    super.key,
    required this.items,
    required this.displayStringForOption,
    required this.onSelected,
    this.hintText = 'Buscar...',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Autocomplete<T>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return Iterable<T>.empty();
            }
            return items.where((T item) {
              return displayStringForOption(item)
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: displayStringForOption,
          onSelected: onSelected,
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
              ),
            );
          },
        ),
      ),
    );
  }
}
