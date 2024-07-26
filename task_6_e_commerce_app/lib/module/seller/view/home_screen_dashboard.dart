import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_6_e_commerce_app/module/seller/view/add_item.dart';
import 'package:task_6_e_commerce_app/module/seller/view/all_orders.dart';
import 'package:task_6_e_commerce_app/module/seller/view/edit_item.dart';
import 'package:task_6_e_commerce_app/module/seller/view/order_screen.dart';
import 'package:task_6_e_commerce_app/module/seller/view/store_detail.dart';
import 'package:task_6_e_commerce_app/module/seller/view/create_store.dart';
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
    // Ensure items are fetched for the initial tab (e.g., 'All')
    await viewModel.fetchItems();
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
                    await viewModel.fetchItems();
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
            floatingActionButton: _buildFloatingActionButton(model),
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
        child: Column(
          children: [
            const Text('Store is not created. Please set up your store.'),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateStoreScreen(widget.user.uid),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text("Create a store"),
            ),
          ],
        ),
      );
    }

    if (!model.isStoreVerified) {
      return const Center(
        child: Text('Your store is not verified yet. Please wait.'),
      );
    }

    if (model.items.isEmpty) {
      return const Center(
        child: Text('No items found.'),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(8),
      itemCount: model.items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final DocumentSnapshot itemSnapshot = model.items[index];
        final Map<String, dynamic> item =
            itemSnapshot.data() as Map<String, dynamic>;
        final String itemId = itemSnapshot.id;
        final imageUrl = (item['imageUrls'] as List).isNotEmpty
            ? item['imageUrls'][0]
            : null;
        return Card(
          color: Colors.white,
          elevation: 3.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: imageUrl != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(8)),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Container(
                            color: Colors.grey,
                            child: Icon(Icons.image,
                                size: 50, color: Colors.white),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${item['price'] ?? ''}',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditItemScreen(
                            itemData: item,
                            itemId: itemId, // Pass the itemId here
                          ),
                        ),
                      );
                    } else if (value == 'delete') {
                      _deleteItem(itemId);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.black),
                          SizedBox(width: 8),
                          Text('Edit', style: GoogleFonts.inter())
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: GoogleFonts.inter())
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteItem(String itemId) async {
    try {
      await FirebaseFirestore.instance.collection('items').doc(itemId).delete();
    } catch (e) {
      print('Error deleting item: $e');
      // Handle error, e.g., show a snackbar with the error message
    }
  }

  FloatingActionButton _buildFloatingActionButton(DashboardViewModel model) {
    bool fabEnabled = model.hasStore && model.isStoreVerified;
    return FloatingActionButton(
      onPressed: fabEnabled
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddItemScreen(
                    storeId: widget.user.uid,
                  ),
                ),
              );
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !model.hasStore
                        ? 'Set up your store first.'
                        : 'Your store is not verified yet.',
                  ),
                ),
              );
            },
      backgroundColor: fabEnabled ? Colors.black : Colors.grey,
      child: Icon(Icons.add, color: Colors.white),
    );
  }
}
