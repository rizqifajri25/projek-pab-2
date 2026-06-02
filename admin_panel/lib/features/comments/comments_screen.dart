import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/providers.dart';
final allCommentsProvider = StreamProvider((ref)=>ref.watch(adminRepositoryProvider).comments());
class CommentsScreen extends ConsumerWidget { const CommentsScreen({super.key}); @override Widget build(BuildContext context, WidgetRef ref)=>Scaffold(appBar: AppBar(title: const Text('Moderasi Komentar')), body: ref.watch(allCommentsProvider).when(data:(items)=>ListView(padding: const EdgeInsets.all(16), children: items.map((c)=>Card(child: ListTile(title: Text(c.comment), subtitle: Text('Court: ${c.courtId} • User: ${c.userId}'), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed:()=>ref.read(adminRepositoryProvider).deleteComment(c.commentId)))) .toList()), error:(e,_)=>Center(child:Text('$e')), loading:()=>const Center(child:CircularProgressIndicator()))); }
