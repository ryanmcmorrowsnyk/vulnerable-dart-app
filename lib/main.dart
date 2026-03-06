// Intentionally Vulnerable Flutter/Dart Application
// DO NOT USE IN PRODUCTION - FOR SECURITY TESTING ONLY

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';

// VULNERABILITY: Hardcoded Secrets (CWE-798)
const String JWT_SECRET = 'super_secret_jwt_key_12345';
const String ADMIN_PASSWORD = 'admin123';
const String DB_PASSWORD = 'password123';
const String API_KEY = 'AKIA_FAKE_DART_KEY_FOR_TESTING_ONLY';
const String AWS_SECRET_KEY = 'fake_aws_secret_key_12345678901234567890';

void main() {
  runApp(VulnerableApp());
}

class VulnerableApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vulnerable Dart App',
      home: VulnerableHomePage(),
    );
  }
}

class VulnerableHomePage extends StatefulWidget {
  @override
  _VulnerableHomePageState createState() => _VulnerableHomePageState();
}

class _VulnerableHomePageState extends State<VulnerableHomePage> {
  String _output = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vulnerable Dart App'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Intentionally Vulnerable Flutter/Dart Application',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => testSqlInjection(),
                child: Text('Test SQL Injection'),
              ),
              ElevatedButton(
                onPressed: () => testCommandInjection(),
                child: Text('Test Command Injection'),
              ),
              ElevatedButton(
                onPressed: () => testPathTraversal(),
                child: Text('Test Path Traversal'),
              ),
              ElevatedButton(
                onPressed: () => testSSRF(),
                child: Text('Test SSRF'),
              ),
              SizedBox(height: 20),
              Text('Output:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_output),
            ],
          ),
        ),
      ),
    );
  }

  // VULNERABILITY 1: SQL Injection (CWE-89)
  Future<void> testSqlInjection() async {
    String username = "admin' OR '1'='1";
    String password = "anything";

    final database = await openDatabase(
      join(await getDatabasesPath(), 'vulnerable.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT, email TEXT)',
        );
      },
      version: 1,
    );

    // Vulnerable: String concatenation in SQL query
    String query =
        "SELECT * FROM users WHERE username = '$username' AND password = '$password'";

    setState(() {
      _output = 'Vulnerable SQL Query: $query';
    });
  }

  // VULNERABILITY 2: Command Injection (CWE-78)
  Future<void> testCommandInjection() async {
    String cmd = 'ls; whoami';

    // Vulnerable: Direct execution of user input
    ProcessResult result = await Process.run('sh', ['-c', cmd]);

    setState(() {
      _output = 'Command Output: ${result.stdout}';
    });
  }

  // VULNERABILITY 3: Path Traversal (CWE-22)
  Future<void> testPathTraversal() async {
    String filename = '../../../etc/passwd';

    // Vulnerable: No sanitization of file path
    String path = './uploads/$filename';

    try {
      String content = await File(path).readAsString();
      setState(() {
        _output = 'File Content: $content';
      });
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    }
  }

  // VULNERABILITY 4: Server-Side Request Forgery (SSRF) (CWE-918)
  Future<void> testSSRF() async {
    String url = 'http://169.254.169.254/latest/meta-data/';

    // Vulnerable: No URL validation
    try {
      final response = await http.get(Uri.parse(url));
      setState(() {
        _output = 'Response: ${response.body.substring(0, 100)}';
      });
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    }
  }
}

// VULNERABILITY 5: Insecure Deserialization (CWE-502)
class VulnerableDeserializer {
  static dynamic deserialize(String data) {
    // Vulnerable: Deserializing untrusted data without validation
    return jsonDecode(data);
  }
}

// VULNERABILITY 6: Hardcoded Credentials (CWE-798)
class AuthService {
  static bool login(String username, String password) {
    // Vulnerable: Hardcoded admin credentials
    if (username == 'admin' && password == ADMIN_PASSWORD) {
      return true;
    }
    return false;
  }

  // VULNERABILITY 7: Weak Cryptography (CWE-327)
  static String hashPassword(String password) {
    // Vulnerable: Using MD5 for password hashing
    var bytes = utf8.encode(password);
    var digest = md5.convert(bytes);
    return digest.toString();
  }

  // VULNERABILITY 8: Insecure Random (CWE-330)
  static String generateToken() {
    // Vulnerable: Using predictable random
    int token = DateTime.now().millisecondsSinceEpoch % 999999999;
    return token.toString();
  }
}

// VULNERABILITY 9: Mass Assignment (CWE-915)
class User {
  int? id;
  String? username;
  String? email;
  String? role;

  User.fromJson(Map<String, dynamic> json) {
    // Vulnerable: Allows setting any field including 'role'
    id = json['id'];
    username = json['username'];
    email = json['email'];
    role = json['role']; // Attacker can set role=admin
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
    };
  }
}

// VULNERABILITY 10: Missing Input Validation (CWE-20)
class DataProcessor {
  static String processInput(String input) {
    // Vulnerable: No input validation or sanitization
    return '<div>User input: $input</div>';
  }
}

// VULNERABILITY 11: Information Exposure (CWE-200)
class DebugService {
  static Map<String, dynamic> getDebugInfo() {
    // Vulnerable: Exposes sensitive information
    return {
      'jwt_secret': JWT_SECRET,
      'admin_password': ADMIN_PASSWORD,
      'db_password': DB_PASSWORD,
      'api_key': API_KEY,
      'aws_secret_key': AWS_SECRET_KEY,
    };
  }
}

// VULNERABILITY 12: Unvalidated Redirects (CWE-601)
class NavigationService {
  static void redirect(String url) {
    // Vulnerable: No validation of redirect URL
    // In a real app, this would navigate to the URL
    print('Redirecting to: $url');
  }
}

// VULNERABILITY 13: XML External Entity (XXE) (CWE-611)
class XmlParser {
  static void parseXml(String xmlData) {
    // Vulnerable: Would parse XML without disabling external entities
    // Dart's XML parsers are generally safe by default, but this pattern is vulnerable
    print('Parsing XML: $xmlData');
  }
}

// VULNERABILITY 14: Insecure Direct Object Reference (IDOR) (CWE-639)
class UserRepository {
  static Future<User?> getUser(int userId) async {
    // Vulnerable: No authorization check, any user can access any user's data
    final database = await openDatabase(
      join(await getDatabasesPath(), 'vulnerable.db'),
    );

    final List<Map<String, dynamic>> maps = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  // VULNERABILITY 15: Missing Authentication (CWE-306)
  static Future<bool> deleteUser(int userId) async {
    // Vulnerable: No authentication required to delete users
    final database = await openDatabase(
      join(await getDatabasesPath(), 'vulnerable.db'),
    );

    await database.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    return true;
  }
}

// VULNERABILITY 16: Sensitive Data in Logs (CWE-532)
class Logger {
  static void logUserData(String username, String password, String email) {
    // Vulnerable: Logging sensitive data
    print('User login attempt: username=$username, password=$password, email=$email');
  }
}

// VULNERABILITY 17: Race Condition (CWE-362)
class Counter {
  static int _count = 0;

  // Vulnerable: No synchronization
  static void increment() {
    _count++;
  }

  static int getCount() {
    return _count;
  }
}

// VULNERABILITY 18: Insufficient Logging (CWE-778)
class PaymentService {
  static Future<bool> processPayment(double amount) async {
    // Vulnerable: No logging of payment transactions
    // Process payment without audit trail
    return true;
  }
}

// API Endpoints Simulation (would be in a backend service)
class ApiEndpoints {
  // VULNERABILITY: SQL Injection endpoint
  static Future<Map<String, dynamic>> login(String username, String password) async {
    String query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
    return {'query': query, 'vulnerable': true};
  }

  // VULNERABILITY: Command Injection endpoint
  static Future<Map<String, dynamic>> exec(String cmd) async {
    ProcessResult result = await Process.run('sh', ['-c', cmd]);
    return {'success': true, 'output': result.stdout};
  }

  // VULNERABILITY: Path Traversal endpoint
  static Future<Map<String, dynamic>> getFile(String filename) async {
    String path = './uploads/$filename';
    try {
      String content = await File(path).readAsString();
      return {'content': content};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // VULNERABILITY: SSRF endpoint
  static Future<Map<String, dynamic>> proxy(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return {'data': response.body.substring(0, 500)};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // VULNERABILITY: Code Injection endpoint
  static Future<Map<String, dynamic>> eval(String code) async {
    // Dart doesn't have eval, but this pattern is vulnerable
    return {'message': 'Code evaluation endpoint (vulnerable pattern)', 'input': code};
  }

  // VULNERABILITY: Mass Assignment endpoint
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    User newUser = User.fromJson(data);
    return {'success': true, 'user': newUser.toJson()};
  }

  // VULNERABILITY: IDOR endpoint
  static Future<Map<String, dynamic>> getUser(int userId) async {
    User? user = await UserRepository.getUser(userId);
    return {'user': user?.toJson()};
  }

  // VULNERABILITY: Missing Authentication endpoint
  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    await UserRepository.deleteUser(userId);
    return {'success': true, 'deleted': userId};
  }

  // VULNERABILITY: Sensitive Data Exposure endpoint
  static Future<Map<String, dynamic>> debug() async {
    return DebugService.getDebugInfo();
  }

  // VULNERABILITY: Open Redirect endpoint
  static void redirect(String url) {
    NavigationService.redirect(url);
  }

  // VULNERABILITY: Weak Cryptography endpoint
  static Future<Map<String, dynamic>> hash(String password) async {
    String hash = AuthService.hashPassword(password);
    return {'hash': hash, 'algorithm': 'MD5'};
  }

  // VULNERABILITY: Insecure Random endpoint
  static Future<Map<String, dynamic>> generateToken() async {
    String token = AuthService.generateToken();
    return {'token': token, 'algorithm': 'Predictable'};
  }

  // VULNERABILITY: Information Exposure endpoint
  static Future<Map<String, dynamic>> databaseConnect() async {
    String errorMsg =
        "Connection failed: Access denied for user 'postgres'@'localhost' using password '$DB_PASSWORD'";
    return {'error': errorMsg, 'stackTrace': 'Simulated stack trace'};
  }

  // VULNERABILITY: Missing Rate Limiting endpoint
  static Future<Map<String, dynamic>> bruteForceTarget(String password) async {
    if (password == 'correct_password') {
      return {'success': true};
    } else {
      return {'success': false};
    }
  }
}
