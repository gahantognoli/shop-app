import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/models/order_list.dart';

import '../components/order.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  Future<void> _getOrders(BuildContext context) =>
      Provider.of<OrderList>(context, listen: false).loadOrders();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus pedidos'),
      ),
      body: FutureBuilder(
        future: _getOrders(context),
        initialData: null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Consumer<OrderList>(
              builder: (context, orders, child) {
                return RefreshIndicator(
                  onRefresh: () => _getOrders(context),
                  child: ListView.builder(
                    itemCount: orders.itemsCount,
                    itemBuilder: (context, index) =>
                        OrderWidget(order: orders.items[index]),
                  ),
                );
              },
            );
          }
        },
      ),
      drawer: const AppDrawer(),
    );
  }
}
