import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yanmar_app/pages/assembly/assembly.dart';
import 'package:yanmar_app/pages/checklist/checklist.dart';
import 'package:yanmar_app/pages/delivery/delivery.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yanmar App',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, mainAxisSpacing: 20, crossAxisSpacing: 40),
                  children: [
                    Card(
                      child: ListTile(
                        iconColor: Colors.blue,
                        title: const Text('Assembly Page'),
                        subtitle: const Text('Go to page'),
                        onTap: () {
                          context.go(AssemblyPage.route);
                        },
                      ),
                    ),
                    Card(
                      child: ListTile(
                        iconColor: Colors.blue,
                        title: const Text('Delivery Page'),
                        subtitle: const Text('Go to page'),
                        onTap: () {
                          context.go(DeliveryPage.route);
                        },
                      ),
                    ),
                    Card(
                      child: ListTile(
                        iconColor: Colors.blue,
                        title: const Text('Checklist Page'),
                        subtitle: const Text('Go to page'),
                        onTap: () {
                          context.go(ChecklistPage.route);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
