import 'package:budget_tracker/models/model.dart';
import 'package:flutter/material.dart';

List<CostItemCategory> defaultCostItemCategories = [
  CostItemCategory(
    name: "sports", 
    color: const Color.fromARGB(255, 18, 210, 50), 
    imagePath: "assets/images/sports.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "food", 
    color: Colors.limeAccent, 
    imagePath: "assets/images/food.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "transport", 
    color: Colors.amberAccent, 
    imagePath: "assets/images/train.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "shopping", 
    color: Colors.orange, 
    imagePath: "assets/images/shopping.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "entertainment", 
    color: Colors.grey, 
    imagePath: "assets/images/entertainment.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "car", 
    color: const Color.fromARGB(255, 96, 98, 231), 
    imagePath: "assets/images/car.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "home", 
    color: Colors.blueAccent, 
    imagePath: "assets/images/home.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "gift", 
    color: Colors.indigo, 
    imagePath: "assets/images/gift.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "loan", 
    color: Colors.deepOrange, 
    imagePath: "assets/images/loan.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "grocery", 
    color: Colors.deepPurpleAccent, 
    imagePath: "assets/images/grocery.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "repair", 
    color: Colors.orange, 
    imagePath: "assets/images/repair.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "luxury", 
    color: Colors.yellow, 
    imagePath: "assets/images/luxury.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "education", 
    color: const Color.fromARGB(255, 130, 55, 228), 
    imagePath: "assets/images/education.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "insurance", 
    color: Colors.cyan, 
    imagePath: "assets/images/insurance.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "medicine", 
    color: Colors.pink, 
    imagePath: "assets/images/medicine.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "pet", 
    color: Colors.teal, 
    imagePath: "assets/images/veterinary.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "travel", 
    color: Colors.indigo, 
    imagePath: "assets/images/plane.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "recreation", 
    color: Colors.lime, 
    imagePath: "assets/images/psychology.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "charity", 
    color: Colors.red, 
    imagePath: "assets/images/charity.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "subscription", 
    color: const Color.fromARGB(255, 98, 172, 221), 
    imagePath: "assets/images/subscription.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "hobby", 
    color: const Color.fromARGB(255, 231, 148, 40), 
    imagePath: "assets/images/artist.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "self-help", 
    color: const Color.fromARGB(255, 131, 197, 125), 
    imagePath: "assets/images/determination.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "business", 
    color: const Color.fromARGB(255, 131, 197, 125), 
    imagePath: "assets/images/shop.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "salary", 
    color: Colors.deepOrange, 
    imagePath: "assets/images/salary.png",
    costType: CostType.income
  ),
  CostItemCategory(
    name: "partTime", 
    color: Colors.lightBlue, 
    imagePath: "assets/images/part-time.png",
    costType: CostType.income
  ),
  CostItemCategory(
    name: "investment", 
    color: Colors.green, 
    imagePath: "assets/images/investment.png",
    costType: CostType.income
  ),
  CostItemCategory(
    name: "bonus", 
    color: Colors.brown, 
    imagePath: "assets/images/bonus.png",
    costType: CostType.income
  ),
  CostItemCategory(
    name: "allowance", 
    color: const Color.fromARGB(255, 60, 173, 107), 
    imagePath: "assets/images/allowance.png",
    costType: CostType.income
  ),
  CostItemCategory(
    name: "refund", 
    color: const Color.fromARGB(255, 71, 51, 187), 
    imagePath: "assets/images/refund.png",
    costType: CostType.income
  ),
  CostItemCategory(
    name: "cashback", 
    color: const Color.fromARGB(255, 82, 36, 50), 
    imagePath: "assets/images/cashback.png",
    costType: CostType.income
  ),
  CostItemCategory(
    name: "passive", 
    color: const Color.fromARGB(255, 33, 177, 182), 
    imagePath: "assets/images/passive-income.png",
    costType: CostType.income
  ),
];