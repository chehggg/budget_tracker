import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/enum.dart';
import 'package:flutter/material.dart';

List<CostItemCategory> defaultCostItemCategories = [
  CostItemCategory(
    id: "1",
    name: "sports", 
    color: const Color.fromARGB(255, 18, 210, 50), 
    imagePath: "assets/images/sport.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "2",
    name: "food", 
    color: Colors.limeAccent, 
    imagePath: "assets/images/food.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "3",
    name: "transport", 
    color: Colors.amberAccent, 
    imagePath: "assets/images/train.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "4",
    name: "shopping", 
    color: Colors.orange, 
    imagePath: "assets/images/shopping.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "5",
    name: "entertainment", 
    color: Colors.grey, 
    imagePath: "assets/images/party.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "6",
    name: "car", 
    color: const Color.fromARGB(255, 96, 98, 231), 
    imagePath: "assets/images/car.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "7",
    name: "home", 
    color: Colors.blueAccent, 
    imagePath: "assets/images/home.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "8",
    name: "gift", 
    color: Colors.indigo, 
    imagePath: "assets/images/gift.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "9",
    name: "loan", 
    color: Colors.deepOrange, 
    imagePath: "assets/images/loan.svg",
    costType: CostType.expense
  ),
  // CostItemCategory(
  //   id: "10",
  //   name: "grocery", 
  //   color: Colors.deepPurpleAccent, 
  //   imagePath: "assets/images/grocery.png",
  //   costType: CostType.expense
  // ),
  CostItemCategory(
    id: "11",
    name: "repair", 
    color: Colors.orange, 
    imagePath: "assets/images/repair.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "12",
    name: "luxury", 
    color: Colors.yellow, 
    imagePath: "assets/images/luxury.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "13",
    name: "education", 
    color: const Color.fromARGB(255, 130, 55, 228), 
    imagePath: "assets/images/education.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "14",
    name: "insurance", 
    color: Colors.cyan, 
    imagePath: "assets/images/umbrella.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "15",
    name: "medicine", 
    color: Colors.pink, 
    imagePath: "assets/images/medicine.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "16",
    name: "pet", 
    color: Colors.teal, 
    imagePath: "assets/images/pet.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "17",
    name: "travel", 
    color: Colors.indigo, 
    imagePath: "assets/images/plane.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "18",
    name: "recreation", 
    color: Colors.lime, 
    imagePath: "assets/images/wellbeing.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "19",
    name: "charity", 
    color: Colors.red, 
    imagePath: "assets/images/charity.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "20",
    name: "subscription", 
    color: const Color.fromARGB(255, 98, 172, 221), 
    imagePath: "assets/images/subscription.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "21",
    name: "hobby", 
    color: const Color.fromARGB(255, 231, 148, 40), 
    imagePath: "assets/images/paint.svg",
    costType: CostType.expense
  ),
  // CostItemCategory(
  //   id: "22",
  //   name: "self-help", 
  //   color: const Color.fromARGB(255, 131, 197, 125), 
  //   imagePath: "assets/images/determination.png",
  //   costType: CostType.expense
  // ),
  CostItemCategory(
    id: "23",
    name: "business", 
    color: const Color.fromARGB(255, 131, 197, 125), 
    imagePath: "assets/images/shop.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "24",
    name: "salary", 
    color: Colors.deepOrange, 
    imagePath: "assets/images/work.svg",
    costType: CostType.income
  ),
  // CostItemCategory(
  //   id: "25",
  //   name: "partTime", 
  //   color: Colors.lightBlue, 
  //   imagePath: "assets/images/part-time.png",
  //   costType: CostType.income
  // ),
  CostItemCategory(
    id: "26",
    name: "investment", 
    color: Colors.green, 
    imagePath: "assets/images/investment.svg",
    costType: CostType.income
  ),
  // CostItemCategory(
  //   id: "27",
  //   name: "bonus", 
  //   color: Colors.brown, 
  //   imagePath: "assets/images/bonus.png",
  //   costType: CostType.income
  // ),
  // CostItemCategory(
  //   id: "28",
  //   name: "allowance", 
  //   color: const Color.fromARGB(255, 60, 173, 107), 
  //   imagePath: "assets/images/allowance.png",
  //   costType: CostType.income
  // ),
  // CostItemCategory(
  //   id: "29",
  //   name: "refund", 
  //   color: const Color.fromARGB(255, 71, 51, 187), 
  //   imagePath: "assets/images/refund.png",
  //   costType: CostType.income
  // ),
  // CostItemCategory(
  //   id: "30",
  //   name: "cashback", 
  //   color: const Color.fromARGB(255, 82, 36, 50), 
  //   imagePath: "assets/images/cashback.png",
  //   costType: CostType.income
  // ),
  // CostItemCategory(
  //   id: "31",
  //   name: "passive", 
  //   color: const Color.fromARGB(255, 33, 177, 182), 
  //   imagePath: "assets/images/passive-income.png",
  //   costType: CostType.income
  // ),
  CostItemCategory(
    id: "31",
    name: "sell", 
    color: const Color.fromARGB(255, 33, 177, 182), 
    imagePath: "assets/images/sell.svg",
    costType: CostType.income
  ),
  CostItemCategory(
    id: "32",
    name: "business", 
    color: const Color.fromARGB(255, 33, 177, 182), 
    imagePath: "assets/images/shop.svg",
    costType: CostType.income
  ),
  CostItemCategory(
    id: "33",
    name: "reward", 
    color: const Color.fromARGB(255, 33, 177, 182), 
    imagePath: "assets/images/reward.svg",
    costType: CostType.income
  ),
  CostItemCategory(
    id: "34",
    name: "gig", 
    color: const Color.fromARGB(255, 33, 177, 182), 
    imagePath: "assets/images/delivery.svg",
    costType: CostType.income
  ),
  CostItemCategory(
    id: "35",
    name: "back", 
    color: const Color.fromARGB(255, 33, 177, 182), 
    imagePath: "assets/images/back.svg",
    costType: CostType.income
  ),
  CostItemCategory(
    id: "36",
    name: "gamba", 
    color: const Color.fromARGB(255, 33, 177, 182), 
    imagePath: "assets/images/dice.svg",
    costType: CostType.income
  ),
  CostItemCategory(
    id: "37",
    name: "gamba", 
    color: const Color.fromARGB(255, 33, 177, 182), 
    imagePath: "assets/images/dice.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "38",
    name: "utility", 
    color: const Color.fromARGB(255, 33, 177, 182), 
    imagePath: "assets/images/utility.svg",
    costType: CostType.expense
  ),
  CostItemCategory(
    id: "39",
    name: "internet", 
    color: const Color.fromARGB(255, 33, 177, 182), 
    imagePath: "assets/images/internet.svg",
    costType: CostType.expense
  ),
];