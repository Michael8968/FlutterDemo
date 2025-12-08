import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/user_list_item.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户列表'),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const LoadingIndicator();
          } else if (state is UserError) {
            return ErrorMessage(message: state.message);
          } else if (state is UserLoaded && state.users != null) {
            final users = state.users!;
            if (users.isEmpty) {
              return const Center(
                child: Text('暂无用户数据'),
              );
            }
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return UserListItem(
                  user: users[index],
                  onDelete: (id) {
                    context.read<UserBloc>().add(DeleteUser(id));
                  },
                );
              },
            );
          }
          return const Center(
            child: Text('点击刷新按钮加载数据'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<UserBloc>().add(const LoadAllUsers());
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

