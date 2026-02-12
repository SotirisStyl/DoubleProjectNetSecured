import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_page.dart';

class MultiplayerModePage extends StatefulWidget {
  const MultiplayerModePage({super.key});

  @override
  _MultiplayerModePageState createState() => _MultiplayerModePageState();
}

class _MultiplayerModePageState extends State<MultiplayerModePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool isLoading = true;
  String status = '';
  List<Map<String, dynamic>> friends = [];
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString('username');

    if (currentUsername == null) {
      setState(() {
        isLoading = false;
        status = 'Error: User not found';
      });
      return;
    }

    try {
      print('Loading friends for $currentUsername...');
      final response = await supabase
          .from('friendships')
          .select()
          .or('user_id_1.eq.$currentUsername,user_id_2.eq.$currentUsername')
          .eq('status', 'accepted');

      print('Friendships found: ${response.length}');

      // Fetch user data for each friend
      List<Map<String, dynamic>> enrichedFriends = [];
      for (var friendship in response) {
        final userId1 = friendship['user_id_1'] as String;
        final userId2 = friendship['user_id_2'] as String;
        final otherUserId = userId1 == currentUsername ? userId2 : userId1;

        try {
          final userData = await supabase
              .from('users_data')
              .select('username, user_points')
              .eq('username', otherUserId)
              .single();

          enrichedFriends.add({
            'username': userData['username'],
            'user_points': userData['user_points'],
          });
        } catch (e) {
          print('Error fetching user data for $otherUserId: $e');
        }
      }

      setState(() {
        friends = enrichedFriends;
        isLoading = false;
        status = friends.isEmpty ? 'No friends yet' : '';
      });
    } catch (e) {
      print('Error loading friends: $e');
      setState(() {
        isLoading = false;
        status = 'Error loading friends';
      });
    }
  }

  Future<List<Map<String, dynamic>>> _selectMultiplayerQuestions() async {
    try {
      print('Fetching multiplayer questions...');
      final response = await supabase
          .from('multiplayer_questions')
          .select()
          .order('id', ascending: true)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Query timeout: took longer than 10 seconds');
      });

      print('Response received: ${response.length} questions');
      List<Map<String, dynamic>> allQuestions = List<Map<String, dynamic>>.from(response);

      if (allQuestions.isEmpty) {
        print('No questions found in multiplayer_questions table');
        return [];
      }

      const int blockSize = 60; // each category block length
      const int numCategories = 10; // expected categories

      List<Map<String, dynamic>> selected = [];
      final rand = Random();

      for (int i = 0; i < numCategories; i++) {
        int start = i * blockSize;
        int end = start + blockSize; // exclusive
        if (start >= allQuestions.length) break;
        if (end > allQuestions.length) end = allQuestions.length;

        List<Map<String, dynamic>> chunk = allQuestions.sublist(start, end);
        if (chunk.isEmpty) continue;
        selected.add(chunk[rand.nextInt(chunk.length)]);
      }

      // If we ended up with fewer than 10 (e.g., table shorter), pad by random picks
      while (selected.length < 10 && allQuestions.isNotEmpty) {
        selected.add(allQuestions[rand.nextInt(allQuestions.length)]);
      }

      print('Selected ${selected.length} questions for multiplayer');
      return selected;
    } catch (e) {
      print('Error fetching multiplayer questions: $e');
      return [];
    }
  }

  Future<void> _sendChallenge(String friendUsername) async {
    // First select the questions
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Selecting Questions'),
        content: const Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 12),
            Text('Preparing quiz...'),
          ],
        ),
      ),
    );

    final selected = await _selectMultiplayerQuestions();

    if (!mounted) return;
    Navigator.of(context).pop(); // Close loading dialog

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No multiplayer questions available')));
      return;
    }

    // Create a challenge record
    try {
      print('Creating challenge from $currentUsername to $friendUsername');
      final challengeData = {
        'from_user': currentUsername,
        'to_user': friendUsername,
        'status': 'pending',
        'questions': selected,
        'player_scores': {},
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('multiplayer_challenges')
          .insert(challengeData)
          .select();

      print('Challenge created: ${response}');

      if (!mounted) return;

      // Show waiting screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _ChallengeWaitingScreen(
            friendUsername: friendUsername,
            challengeId: response[0]['id'],
            questions: selected,
          ),
        ),
      );
    } catch (e) {
      print('Error creating challenge: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Challenge a Friend'), backgroundColor: const Color(0xff6200EE)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (friends.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Challenge a Friend'), backgroundColor: const Color(0xff6200EE)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No friends yet', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Add friends to challenge them!', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Challenge a Friend'), backgroundColor: const Color(0xff6200EE)),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(friend['username']),
              subtitle: Text('${friend['user_points']} points'),
              trailing: ElevatedButton(
                onPressed: () => _sendChallenge(friend['username']),
                child: const Text('Challenge'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChallengeWaitingScreen extends StatefulWidget {
  final String friendUsername;
  final int challengeId;
  final List<Map<String, dynamic>> questions;

  const _ChallengeWaitingScreen({
    required this.friendUsername,
    required this.challengeId,
    required this.questions,
  });

  @override
  State<_ChallengeWaitingScreen> createState() => _ChallengeWaitingScreenState();
}

class _ChallengeWaitingScreenState extends State<_ChallengeWaitingScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<void> _listenerFuture;

  @override
  void initState() {
    super.initState();
    _listenerFuture = _setupChallengeListener();
  }

  Future<void> _cancelChallenge() async {
    try {
      await supabase
          .from('multiplayer_challenges')
          .update({'status': 'cancelled'})
          .eq('id', widget.challengeId);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error canceling challenge: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error canceling: $e')),
        );
      }
    }
  }

  Future<void> _setupChallengeListener() async {
    try {
      // Poll for challenge status updates every 2 seconds
      while (mounted) {
        await Future.delayed(const Duration(seconds: 2));

        final response = await supabase
            .from('multiplayer_challenges')
            .select('status')
            .eq('id', widget.challengeId)
            .single();

        final status = response['status'];
        print('Challenge status: $status');

        if (status == 'accepted') {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => QuizPage(
                  tableName: 'multiplayer_questions',
                  difficulty: 'multiplayer',
                  preselectedQuestions: widget.questions,
                  challengeId: widget.challengeId,
                  opponentUsername: widget.friendUsername,
                ),
              ),
            );
          }
          return;
        } else if (status == 'rejected') {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${widget.friendUsername} rejected your challenge')),
            );
          }
          return;
        }
      }
    } catch (e) {
      print('Error setting up listener: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting for Response')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Waiting for ${widget.friendUsername}\nto accept your challenge...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _cancelChallenge,
              child: const Text('Cancel Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
