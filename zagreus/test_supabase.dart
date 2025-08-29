// Quick test script to verify Supabase connection
import 'package:flutter/material.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Testing Supabase connection...');
  print('URL: ${SupabaseConfig.url}');
  print('Key: ${SupabaseConfig.anonKey.substring(0, 20)}...');
  
  try {
    await LunaSupabase().initialize();
    print('✅ Supabase initialized successfully!');
    
    // Test auth
    final client = LunaSupabase.client;
    print('✅ Client created');
    
    // Test if we can reach Supabase
    final response = await client.auth.signInWithPassword(
      email: 'test@example.com', 
      password: 'wrongpassword'
    );
    
  } catch (e) {
    if (e.toString().contains('Invalid login')) {
      print('✅ Supabase is responding correctly (auth working)');
    } else {
      print('❌ Error: $e');
    }
  }
}