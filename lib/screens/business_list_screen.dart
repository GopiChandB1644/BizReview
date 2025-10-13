import 'dart:convert';

import 'package:bizreview/provider/bizprovider.dart';
import 'package:bizreview/screens/add_business_screen.dart';
import 'package:bizreview/screens/business_detail_screen.dart';
import 'package:bizreview/widgets/profileDrawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({super.key});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Bizprovider>(context, listen: false).loadAllBusinesses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BizReview"), centerTitle: true),
      drawer: ProfileDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<Bizprovider>(
          builder: (context, provider, child) {
            if (provider.isLoadingBusinesses) {
              return Center(child: CircularProgressIndicator());
            }
            if (provider.businesses.isEmpty) {
              return Center(child: Text("No businesses found"));
            }

            return ListView.builder(
              itemCount: provider.businesses.length,
              itemBuilder: (context, index) {
                final business = provider.businesses[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: business.imageUrl != null
                          ? MemoryImage(base64Decode(business.imageUrl!))
                          : null,
                      child: business.imageUrl == null
                          ? Icon(Icons.business, color: Colors.grey[600])
                          : null,
                    ),
                    title: Text(
                      business.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(business.category ?? 'Uncategorized'),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(
                              '${business.averageRating.toStringAsFixed(1)} (${business.totalReviews} reviews)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BusinessDetailScreen(business: business),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBusinessScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
