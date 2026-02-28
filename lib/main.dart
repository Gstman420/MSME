import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PricingScreen(),
    );
  }
}

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}
 
class _PricingScreenState extends State<PricingScreen> {
  String? selectedProduct;

  final Map<String, Map<String, dynamic>> products = {
    "Smart Watch": {
      "cost_price": 70,
      "selling_price": 120,
      "stock_quantity": 60,
      "base_sales": 150,
    },
    "Running Shoes": {
      "cost_price": 40,
      "selling_price": 90,
      "stock_quantity": 100,
      "base_sales": 220,
    },
    "Bluetooth Speaker": {
      "cost_price": 35,
      "selling_price": 75,
      "stock_quantity": 45,
      "base_sales": 130,
    },
    "Fitness Band": {
      "cost_price": 25,
      "selling_price": 60,
      "stock_quantity": 75,
      "base_sales": 180,
    },
    "Leather Wallet": {
      "cost_price": 15,
      "selling_price": 40,
      "stock_quantity": 120,
      "base_sales": 90,
    },
  };

  final competitorPriceController = TextEditingController();
  

  bool isHoliday = false;
  double discount = 0.1;
  double marketingEffect = 1.0;
  Map<String, dynamic>? result;
  bool loading = false;

  

  void generateAnalysis() {
    if (selectedProduct == null) return;

    final product = products[selectedProduct]!;

    double cost = (product["cost_price"] as num).toDouble();
    double selling = (product["selling_price"] as num).toDouble();
    double stock = (product["stock_quantity"] as num).toDouble();
    double baseSales = (product["base_sales"] as num).toDouble();

    // Smart pricing formula
    double recommendedPrice = selling + (discount * 20) + (marketingEffect * 5);

    String demandLevel = baseSales > 180
        ? "High"
        : baseSales > 120
        ? "Moderate"
        : "Low";

    String inventoryAction = stock < 50
        ? "Restock Soon"
        : stock > 100
        ? "Overstock Risk"
        : "Hold";

    String pricingFlag = recommendedPrice > selling
        ? "Premium Positioning"
        : "Competitive";

    String customerBehavior = marketingEffect > 1.2
        ? "High Engagement Expected"
        : "Stable Demand";

    result = {
      "product_name": selectedProduct,
      "recommended_price": recommendedPrice.toStringAsFixed(2),
      "pricing_flag": pricingFlag,
      "demand_level": demandLevel,
      "inventory_action": inventoryAction,
      "customer_behavior": customerBehavior,
    };

    setState(() {});
  }


  Widget buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1F2937),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildResultCard() {
    if (result == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result!["product_name"],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          buildInfoRow(
            "💰 Recommended Price",
            "₹${result!["recommended_price"]}",
          ),
          buildInfoRow("📊 Pricing Flag", result!["pricing_flag"]),
          buildInfoRow("📈 Demand Level", result!["demand_level"]),
          buildInfoRow("📦 Inventory Action", result!["inventory_action"]),
          buildInfoRow("👥 Customer Behavior", result!["customer_behavior"]),
        ],
      ),
    );
  }

  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF111827)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome,",
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                  const Text(
                    "MSME Store",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedProduct,
                          dropdownColor: const Color(0xFF1E293B),
                          decoration: InputDecoration(
                            labelText: "Select Product",
                            labelStyle: const TextStyle(color: Color.fromARGB(179, 8, 3, 3)),
                            filled: true,
                            fillColor: const Color(0xFF1F2937),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: products.keys.map((product) {
                            return DropdownMenuItem(
                              value: product,
                              child: Text(
                                product,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedProduct = value;
                            });
                          },
                        ),

                        const SizedBox(height: 15),

                        buildInput(
                          "Competitor Price",
                          competitorPriceController,
                        ),
                        
                        const SizedBox(height: 15),

                        // ===== Discount Slider =====
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Discount (${discount.toStringAsFixed(2)})",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Slider(
                              value: discount,
                              min: 0,
                              max: 0.5,
                              divisions: 50,
                              activeColor: Colors.greenAccent,
                              inactiveColor: Colors.white24,
                              onChanged: (value) {
                                setState(() {
                                  discount = value;
                                });
                              },
                            ),
                          ],
                        ),

                        // ===== Marketing Effect Slider =====
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Marketing Effect (${marketingEffect.toStringAsFixed(2)})",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Slider(
                              value: marketingEffect,
                              min: 0.5,
                              max: 2.0,
                              divisions: 30,
                              activeColor: Colors.blueAccent,
                              inactiveColor: Colors.white24,
                              onChanged: (value) {
                                setState(() {
                                  marketingEffect = value;
                                });
                              },
                            ),
                          ],
                        ),

                        SwitchListTile(
                          title: const Text(
                            "Holiday",
                            style: TextStyle(color: Colors.white),
                          ),
                          value: isHoliday,
                          activeColor: Colors.blueAccent,
                          onChanged: (val) {
                            setState(() => isHoliday = val);
                          },
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: generateAnalysis,
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Get Recommendation",
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "AI Pricing Analysis",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                  buildResultCard(
                    
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
