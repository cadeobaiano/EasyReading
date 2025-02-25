import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/base_model.dart';

abstract class BaseRepository<T extends BaseModel> {
  final FirebaseFirestore _firestore;
  final String collection;

  BaseRepository(this._firestore, this.collection);

  /// Cria um novo documento
  Future<T> create(T model);

  /// Lê um documento pelo ID
  Future<T?> read(String id);

  /// Atualiza um documento existente
  Future<void> update(T model);

  /// Deleta um documento pelo ID
  Future<void> delete(String id);

  /// Retorna uma stream de um documento
  Stream<T?> watchDocument(String id);

  /// Retorna uma stream de uma coleção com filtros opcionais
  Stream<List<T>> watchCollection([Query? Function(Query query)? queryBuilder]);
}
