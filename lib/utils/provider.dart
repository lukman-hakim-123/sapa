import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'provider.g.dart';

@riverpod
Client appwriteClient(Ref ref) {
  return Client()
    ..setEndpoint(dotenv.env['APPWRITE_ENDPOINT']!)
    ..setProject(dotenv.env['APPWRITE_PROJECT_ID']!);
}

@riverpod
Account appwriteAccount(Ref ref) {
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
}

@riverpod
Databases appwriteDatabase(Ref ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
}

@riverpod
Storage appwriteStorage(Ref ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
}

@riverpod
Realtime appwriteRealtime(Ref ref) {
  final client = ref.watch(appwriteClientProvider);
  return Realtime(client);
}
