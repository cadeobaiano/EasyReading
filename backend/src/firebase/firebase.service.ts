import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private firebaseApp: admin.app.App;

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    const serviceAccount = this.configService.get('FIREBASE_SERVICE_ACCOUNT');
    
    if (!serviceAccount) {
      throw new Error('Firebase service account não configurado');
    }

    this.firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(serviceAccount)),
      storageBucket: this.configService.get('FIREBASE_STORAGE_BUCKET'),
    });
  }

  get auth() {
    return this.firebaseApp.auth();
  }

  get firestore() {
    return this.firebaseApp.firestore();
  }

  get storage() {
    return this.firebaseApp.storage();
  }

  async verifyToken(token: string): Promise<admin.auth.DecodedIdToken> {
    return this.auth.verifyIdToken(token);
  }

  async getUserById(uid: string): Promise<admin.auth.UserRecord> {
    return this.auth.getUser(uid);
  }

  async createUser(email: string, password: string): Promise<admin.auth.UserRecord> {
    return this.auth.createUser({
      email,
      password,
      emailVerified: false,
    });
  }

  async deleteUser(uid: string): Promise<void> {
    return this.auth.deleteUser(uid);
  }

  // Métodos para o Firestore
  async getDocument(collection: string, id: string): Promise<FirebaseFirestore.DocumentData | undefined> {
    const doc = await this.firestore.collection(collection).doc(id).get();
    return doc.data();
  }

  async setDocument(collection: string, id: string, data: any): Promise<void> {
    await this.firestore.collection(collection).doc(id).set(data, { merge: true });
  }

  async updateDocument(collection: string, id: string, data: any): Promise<void> {
    await this.firestore.collection(collection).doc(id).update(data);
  }

  async deleteDocument(collection: string, id: string): Promise<void> {
    await this.firestore.collection(collection).doc(id).delete();
  }

  async queryCollection(
    collection: string,
    queries: Array<{ field: string; operator: admin.firestore.WhereFilterOp; value: any }>,
  ): Promise<FirebaseFirestore.QuerySnapshot> {
    let query = this.firestore.collection(collection);
    
    for (const q of queries) {
      query = query.where(q.field, q.operator, q.value) as any;
    }
    
    return query.get();
  }

  // Métodos para o Storage
  async uploadFile(
    path: string,
    file: Buffer,
    metadata?: admin.storage.UploadMetadata,
  ): Promise<string> {
    const bucket = this.storage.bucket();
    const fileRef = bucket.file(path);
    
    await fileRef.save(file, {
      metadata,
    });

    return fileRef.publicUrl();
  }

  async deleteFile(path: string): Promise<void> {
    const bucket = this.storage.bucket();
    await bucket.file(path).delete();
  }

  async getSignedUrl(path: string, expires: number): Promise<string> {
    const bucket = this.storage.bucket();
    const [url] = await bucket.file(path).getSignedUrl({
      action: 'read',
      expires: Date.now() + expires,
    });
    return url;
  }
}
