import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tugas_1/app/modules/home/controllers/home_controller.dart';
import 'package:tugas_1/app/modules/home/views/home_view.dart';
import 'package:tugas_1/app/page/keranjang_page.dart';

// Controller for managing state
class ProductController extends GetxController {
  // Color and size selection state
  var selectedColor = 0.obs;
  var selectedSize = 41.obs;

  // Function to change color
  void changeColor(int index) {
    selectedColor.value = index;
  }

  // Function to change size
  void changeSize(int size) {
    selectedSize.value = size;
  }
}

class ProductPage extends StatelessWidget {
  ProductController controller = Get.put(ProductController());
  HomeController cardController = Get.put(HomeController());
  final bool isEdit;
  final String documentId;
  final String name;
  final String price;
  final String discount;
  final String location;
  final String originalPrice;
  final String index_color;
  final String index_size;
  final String image_path;

  ProductPage({
    required this.isEdit,
    this.documentId = '',
    required this.name,
    required this.price,
    required this.discount,
    required this.location,
    required this.originalPrice,
    required this.index_color,
    required this.index_size,
    required this.image_path,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedColor.value = int.parse(index_color);
      controller.selectedSize.value = int.parse(index_size);
    });
    return Scaffold(
      appBar: AppBar(
        title: SearchBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            Image.asset(
              image_path,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp. ${price}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      'Rp. ${originalPrice}',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '${discount} %',
                      style: TextStyle(color: Colors.green, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            // Product Name
            Row(
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  location,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Icon(Icons.star, color: Colors.orange, size: 20),
                Text("4.7 (285 Review)"),
              ],
            ),
            // "Buy Now" and "Add to Basket" buttons, etc.
            SizedBox(height: 20),
            // Color selection
            Row(
              children: [
                Text("Color: "),
                Obx(
                  () => Row(
                    children: List.generate(2, (index) {
                      return GestureDetector(
                        onTap: () {
                          controller.changeColor(index);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == 0 ? Colors.black : Colors.white,
                            border: Border.all(
                              color: controller.selectedColor.value == index
                                  ? Colors.blue
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Size selection
            Row(
              children: [
                Text("Size: "),
                Obx(
                  () => Row(
                    children: List.generate(4, (index) {
                      int size = 41 + index;
                      return GestureDetector(
                        onTap: () {
                          controller.changeSize(size);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: controller.selectedSize.value == size
                                  ? Colors.blue
                                  : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            size.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: controller.selectedSize.value == size
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            Spacer(),
            // Buttons for "Buy Now" and "Add to Basket"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.changeSize(41);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text("Buy Now"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (isEdit) {
                      // Update the existing item in Firestore
                      await FirebaseFirestore.instance
                          .collection('cart')
                          .doc(documentId)
                          .update({
                        'color': controller.selectedColor.value.toString(),
                        'size': controller.selectedSize.value.toString(),
                      });
                      Get.back(
                          result:
                              true); // Go back to CartPage with update status
                    } else {
                      // Add a new item to the cart
                      cardController.addItemToCart(
                        name,
                        discount,
                        price,
                        originalPrice,
                        location,
                        controller.selectedColor.value.toString(),
                        controller.selectedSize.value.toString(),
                        image_path,
                      );
                    }
                  },
                  child:
                      Text(isEdit ? "Update Keranjang" : "Tambah Keranjang"), // Dynamic text
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          hintText: "Search Product",
        ),
      ),
    );
  }
}
