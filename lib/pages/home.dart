import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yanmar_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:yanmar_app/helper/circle_avatar_name.dart';
import 'package:yanmar_app/pages/assembly/assembly.dart';
import 'package:yanmar_app/pages/checklist/checklist.dart';
import 'package:yanmar_app/pages/delivery/delivery.dart';
import 'package:yanmar_app/pages/upload_daily_plan/upload_daily_plan.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const route = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthenticatedState) {
                    return MenuAnchor(
                      builder: (context, controller, child) {
                        return GestureDetector(
                          onTap: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          child: CircleAvatar(
                            child: Text(getInitialsFromName(state.user.username)),
                          ),
                        );
                      },
                      alignmentOffset: const Offset(0, 10),
                      menuChildren: [
                        MenuItemButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(LogOut());
                          },
                          leadingIcon: const Icon(Icons.logout),
                          child: const Text('Log Out'),
                        ),
                      ],
                    );
                  } else {
                    return TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text('Log In'));
                  }
                },
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: SizedBox(
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
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthenticatedState) {
                            if (UploadDailyPlanPage.allowedUserRoles.contains(state.user.role.name)) {
                              return Card(
                                child: ListTile(
                                  iconColor: Colors.blue,
                                  title: const Text('Upload Daily Plan'),
                                  subtitle: const Text('Go to page'),
                                  onTap: () {
                                    context.go(UploadDailyPlanPage.route);
                                  },
                                ),
                              );
                            }
                          }
                          return Container();
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
