import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double cost;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.cost,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image'] ?? '', // Update this based on your API response
      cost: json['cost'] != null ? double.parse(json['cost'].toString()) : 0.0,
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Product ${product.id}'),
            product.imageUrl.isNotEmpty
                ? Image.network(
              product.imageUrl,
              width: 150,
              height: 150,
            )
                : Placeholder(
              fallbackHeight: 150,
              fallbackWidth: 150,
            ),
            Text(product.name),
            Text('Cost: \$${product.cost.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class ProductGridScreen extends StatefulWidget {
  const ProductGridScreen({Key? key}) : super(key: key);

  @override
  _ProductGridScreenState createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> {
  late List<Product> products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('fetchProducts loading');
      final response = await http.get(Uri.parse('https://dummyjson.com/products'));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        print('API Data: $data');

        if (data is Map<String, dynamic> &&
            data.containsKey('products') &&
            data['products'] is List) {
          setState(() {
            products = (data['products'] as List).map((item) {
              if (item is Map<String, dynamic>) {
                print('Item: $item');
                return Product.fromJson(item);
              } else {
                print('Invalid item format: $item');
                return Product(id: 0, name: '', imageUrl: '', cost: 0.0);
              }
            }).toList();
          });
        } else {
          print('Invalid data format. Expected a map with a "products" key containing a list.');
          showErrorSnackBar('Invalid data format');
        }
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
        showErrorSnackBar('Failed to load products');
      }
    } catch (error) {
      print('Error: $error');
      showErrorSnackBar('Failed to load products. Please try again later.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Grid'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailScreen(product: products[index]),
                ),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Product ${products[index].id}'),
                  products[index].imageUrl.isNotEmpty
                      ? Image.network(
                    products[index].imageUrl,
                    width: 100,
                    height: 100,
                  )
                      : Placeholder(
                    fallbackHeight: 100,
                    fallbackWidth: 100,
                  ),
                  Text(products[index].name),
                  Text('Cost: \$${products[index].cost.toStringAsFixed(2)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductGridScreen(),
    );
  }
}

void main() {
  runApp(MyApp());
}
