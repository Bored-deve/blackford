import 'dart:convert';

import 'package:blackford/api_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wp_woocommerce/woocommerce.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  
  RxBool isPLoading = false.obs;
  //formkey
  final formKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();


   Future<void> changePassword(String oldPassword, String newPassword) async {
    isPLoading.value = true;

    try {
      // Retrieve customer data from shared preferences (if needed for updating)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jsonData = prefs.getString('userrecord') ?? '';

      if (jsonData.isEmpty) {
        Get.snackbar("Error", "No customer data found. Please log in first.", backgroundColor: Colors.red);
        return;
      }

      // Parse the customer data (assuming it's saved as JSON)
      final customerData = WooCustomer.fromJson(jsonDecode(jsonData));

      // Prepare the data for updating the password
      Map<String, dynamic> data = {
        'email': customerData.email,  // Customer email (required for updating)
        'password': newPassword,  // New password
      };

      // Call the updateCustomer function to update the password
      final updatedCustomer = await woocommerce.updateCustomer(id: customerData.id!, data: data);

      // Handle the response
      if (updatedCustomer != null) {
        // Optionally, you can update shared preferences with the updated data
        await saveDataToSharedPreferences(updatedCustomer);

        // Success message
        Get.snackbar("Success", "Password updated successfully.", backgroundColor: Colors.green);
      } else {
        Get.snackbar("Error", "Failed to update password. Please try again.", backgroundColor: Colors.red);
      }
    } catch (e) {
      // Handle any errors
      String errorMessage = "An error occurred while updating the password. Please try again later.";
      if (e is Exception) {
        errorMessage = "Error: ${e.toString()}";
      }

      Get.snackbar("Error", errorMessage, backgroundColor: Colors.red);
      print("Error updating password: $e");
    } finally {
      isPLoading.value = false;
    }
  }

  // Save updated customer data to shared preferences
  Future<void> saveDataToSharedPreferences(WooCustomer data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(data.toJson());
    await prefs.setString('userrecord', jsonData);
  }
}
