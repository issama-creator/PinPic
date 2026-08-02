import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/widgets/app_scaffold.dart';
import 'package:pinpic/widgets/gradient_button.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  String? _category;
  bool _favoritesOnly = false;

  static const _categories = [
    CategoryEngine.documents,
    CategoryEngine.receipts,
    CategoryEngine.passwords,
    CategoryEngine.tickets,
    CategoryEngine.businessCards,
    CategoryEngine.qr,
    CategoryEngine.animals,
    CategoryEngine.plants,
    CategoryEngine.screenshots,
    CategoryEngine.cars,
    CategoryEngine.food,
    CategoryEngine.people,
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Фильтры')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Категория', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories
                    .map(
                      (item) => ChoiceChip(
                        label: Text(item),
                        selected: _category == item,
                        onSelected: (selected) {
                          setState(() => _category = selected ? item : null);
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Только избранное'),
                value: _favoritesOnly,
                onChanged: (value) => setState(() => _favoritesOnly = value),
              ),
              const Spacer(),
              GradientButton(
                label: 'Применить',
                onPressed: () => context.pop({
                  'category': _category,
                  'favoritesOnly': _favoritesOnly,
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
