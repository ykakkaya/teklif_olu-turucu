import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teklif/widgets/custom_appbar.dart';
import 'package:teklif/widgets/client_form.dart';

class IndexPage extends ConsumerWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: ClientForm(),
      ),
    );
  }
}
