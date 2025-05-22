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
    imagePath: "assets/images/bus.png",
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
    color: Colors.green, 
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
    color: Colors.redAccent, 
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
    imagePath: "assets/images/group.png",
    costType: CostType.expense
  ),
  CostItemCategory(
    name: "charity", 
    color: Colors.red, 
    imagePath: "assets/images/charity.png",
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
];