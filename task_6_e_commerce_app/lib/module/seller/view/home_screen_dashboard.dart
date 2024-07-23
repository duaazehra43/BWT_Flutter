import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_6_e_commerce_app/module/seller/add_item.dart';
import 'package:task_6_e_commerce_app/module/seller/all_orders.dart';
import 'package:task_6_e_commerce_app/module/seller/order_screen.dart';
import 'package:task_6_e_commerce_app/module/seller/store_detail.dart';
import 'package:task_6_e_commerce_app/module/seller/view_model/home_screen_dashboard_view_model.dart';

class HomeScreenDashboard extends StatefulWidget {
  final User user;
  HomeScreenDashboard(this.user);

  @override
  State<HomeScreenDashboard> createState() => _HomeScreenDashboardState();
}

class _HomeScreenDashboardState extends State<HomeScreenDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DashboardViewModel viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    viewModel = DashboardViewModel(user: widget.user);
    _tabController.addListener(_handleTabSelection);
    _initialize();
  }

  Future<void> _initialize() async {
    await viewModel.checkStoreStatus();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      viewModel.fetchItems(
        category: _tabController.index == 1
            ? 'Tshirts'
            : _tabController.index == 2
                ? 'Jeans'
                : _tabController.index == 3
                    ? 'Shoes'
                    : null,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => viewModel,
      child: Consumer<DashboardViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () async {
                    await viewModel.checkStoreStatus();
                  },
                ),
              ],
              elevation: 0,
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Tshirts'),
                  Tab(text: 'Jeans'),
                  Tab(text: 'Shoes'),
                ],
                labelColor: Colors.black,
                indicatorColor: Colors.black,
              ),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Text(
                            model.userName != null ? model.userName![0] : '',
                            style: TextStyle(fontSize: 30.0),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          model.userName ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          model.userEmail ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (model.userRole != null)
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text(model.userRole!),
                    ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.store),
                    title: Text('Your Store',
                        style: GoogleFonts.inter(fontSize: 16)),
                    onTap: () async {
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StoreDetailScreen(userId: widget.user.uid),
                        ),
                      );
                      if (result == true) {
                        await viewModel.checkStoreStatus();
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_bag),
                    title: Text('Current Orders',
                        style: GoogleFonts.inter(fontSize: 16)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrdersScreenSeller()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_bag),
                    title: Text('All Orders',
                        style: GoogleFonts.inter(fontSize: 16)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllOrdersScreenSeller()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title:
                        Text('Logout', style: GoogleFonts.inter(fontSize: 16)),
                    onTap: () => model.logout(context),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: model.hasStore && model.isStoreVerified
                  ? Colors.black
                  : Colors.grey,
              foregroundColor: Colors.white,
              onPressed: () {
                if (model.hasStore && model.isStoreVerified) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddItemScreen(
                                storeId: widget.user.uid,
                              )));
                } else if (!model.hasStore) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Set up your store first')),
                  );
                } else if (!model.isStoreVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Your store is not verified yet')),
                  );
                }
              },
              child: Icon(Icons.add),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildItemsGrid(model), // All items
                _buildItemsGrid(model), // Tshirts
                _buildItemsGrid(model), // Jeans
                _buildItemsGrid(model), // Shoes
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsGrid(DashboardViewModel model) {
    if (!model.hasStore) {
      return Center(
          child: Text('Store is not created. Please set up your store.'));
    }

    if (!model.isStoreVerified) {
      return Center(child: Text('Your store is not verified yet.'));
    }

    if (model.items.isEmpty) {
      return Center(child: Text('No items found.'));
    }

    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: model.items.length,
      itemBuilder: (context, index) {
        var item = model.items[index];
        return Card(
          elevation: 5,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.network(
                      item['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item['productName'],
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Price: \$${item['price']}',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => model.deleteItem(item['id']),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
