import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  Stream<List<Map<String, dynamic>>>? _friendshipsStream;
  String? _currentUsername;
  
  // Real-time subscription
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _initializeStream();
    _setupRealtimeSubscription();
  }
  
  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
    super.dispose();
  }

  Future<void> _initializeStream() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');

    if (mounted) {
      setState(() {
        _currentUsername = username;
        if (username != null) {
          _friendshipsStream = supabase
              .from('friendships')
              .stream(primaryKey: ['id'])
              .asyncMap((data) => _processFriendships(data, username));
        }
      });
    }
  }
  
  // Force a manual refresh by re-initializing the stream
  void _forceRefresh() {
    if (_currentUsername != null) {
      setState(() {
        _friendshipsStream = supabase
            .from('friendships')
            .stream(primaryKey: ['id'])
            .asyncMap((data) => _processFriendships(data, _currentUsername!));
      });
    }
  }

  void _setupRealtimeSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    
    if (username == null) return;

    try {
      // Subscribe to real-time changes in the friendships table
      _realtimeChannel = supabase
          .channel('friendships_changes_${DateTime.now().millisecondsSinceEpoch}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'friendships',
            callback: (payload) {
              print('Real-time update received: ${payload.eventType}');
              print('Payload: ${payload.newRecord}');
              print('Old Record: ${payload.oldRecord}');
              
              // Force refresh the stream whenever ANY change happens
              if (mounted) {
                _forceRefresh();
              }
            },
          )
          .subscribe((status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              print('✅ Successfully subscribed to real-time updates');
            } else if (status == RealtimeSubscribeStatus.channelError) {
              print('❌ Real-time subscription error: $error');
              print('💡 Enable Realtime in Supabase Dashboard or use manual refresh button');
            } else if (status == RealtimeSubscribeStatus.timedOut) {
              print('⏱️ Real-time subscription timed out');
            } else if (status == RealtimeSubscribeStatus.closed) {
              print('🔒 Real-time subscription closed');
            }
          });
    } catch (e) {
      print('Error setting up real-time subscription: $e');
    }
  }

  // Manual refresh method
  void _triggerRefresh() {
    _forceRefresh();
  }

  Future<List<Map<String, dynamic>>> _processFriendships(
      List<Map<String, dynamic>> data, String username) async {
    // Filter for current user
    final relevant = data
        .where((item) =>
            item['user_id_1'] == username || item['user_id_2'] == username)
        .toList();

    if (relevant.isEmpty) return [];

    // Collect other user IDs
    final otherUsernames = <String>{};
    for (var item in relevant) {
      if (item['user_id_1'] != username) otherUsernames.add(item['user_id_1']);
      if (item['user_id_2'] != username) otherUsernames.add(item['user_id_2']);
    }

    if (otherUsernames.isEmpty) return relevant;

    // Fetch user details
    try {
      final users = await supabase
          .from('users_data')
          .select('username, user_points')
          .filter('username', 'in', otherUsernames.toList());

      final userMap = {for (var u in users) u['username']: u};

      return relevant.map((item) {
        final newItem = Map<String, dynamic>.from(item);
        final otherId = item['user_id_1'] == username
            ? item['user_id_2']
            : item['user_id_1'];

        final userData = userMap[otherId];
        if (userData != null) {
          newItem['other_user'] = userData;
          // For requests logic
          if (item['user_id_1'] == otherId) {
            newItem['requester'] = userData;
          } else {
            newItem['recipient'] = userData;
          }
        }
        return newItem;
      }).toList();
    } catch (e) {
      print('Error enriching stream data: $e');
      return relevant;
    }
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddFriendDialog(
          currentUsername: _currentUsername,
          onFriendAdded: _triggerRefresh,
        );
      },
    );
  }

  Future<void> _acceptFriendRequest(String friendshipId) async {
    try {
      await supabase
          .from('friendships')
          .update({'status': 'accepted'})
          .eq('id', friendshipId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request accepted!')),
        );
        _triggerRefresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting request: $e')),
        );
      }
    }
  }

  Future<void> _rejectFriendRequest(String friendshipId) async {
    try {
      await supabase.from('friendships').delete().eq('id', friendshipId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request rejected')),
        );
        _triggerRefresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request: $e')),
        );
      }
    }
  }

  Future<void> _removeFriend(String friendshipId) async {
    try {
      await supabase.from('friendships').delete().eq('id', friendshipId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend removed successfully')),
        );
        _triggerRefresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing friend: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.black),
              const SizedBox(height: 20),
              const Text(
                "You are currently a guest.",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Please sign in to view friends.",
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: const Color(0xff6200EE),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _triggerRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        color: context.watch<ThemeProvider>().availableColors[
            context.watch<ThemeProvider>().selectedColorName],
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _friendshipsStream,
                builder: (context, snapshot) {
                  if (_friendshipsStream == null ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allData = snapshot.data ?? [];

                  final friends = allData
                      .where((f) => f['status'] == 'accepted')
                      .toList();
                  final receivedRequests = allData
                      .where((f) =>
                          f['status'] == 'pending' &&
                          f['user_id_2'] == _currentUsername)
                      .toList();
                  final sentRequests = allData
                      .where((f) =>
                          f['status'] == 'pending' &&
                          f['user_id_1'] == _currentUsername)
                      .toList();

                  return DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: const Color(0xff6200EE),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color(0xff6200EE),
                          tabs: [
                            Tab(text: 'My Friends (${friends.length})'),
                            Tab(text: 'Requests (${receivedRequests.length})'),
                            Tab(text: 'Sent (${sentRequests.length})'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // My Friends Tab
                              friends.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.people_outline,
                                              size: 80,
                                              color: Colors.grey[400]),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No friends yet',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Add friends to get started!',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: friends.length,
                                      itemBuilder: (context, index) {
                                        final friendship = friends[index];
                                        final userData = friendship['other_user']
                                                as Map<String, dynamic>? ??
                                            {'username': 'Unknown', 'user_points': 0};

                                        final friendUsername =
                                            userData['username'] as String;
                                        final friendPoints =
                                            userData['user_points'] as int;

                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  const Color(0xff6200EE),
                                              child: Text(
                                                friendUsername.isNotEmpty
                                                    ? friendUsername[0]
                                                        .toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              friendUsername,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            subtitle: Text(
                                              'Points: $friendPoints',
                                              style: const TextStyle(
                                                  fontSize: 14),
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                  Icons.person_remove,
                                                  color: Colors.red),
                                              onPressed: () {
                                                _showRemoveConfirmation(
                                                  context,
                                                  friendship['id'] as String,
                                                  friendUsername,
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                              // Pending Requests Tab
                              receivedRequests.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.inbox,
                                              size: 80,
                                              color: Colors.grey[400]),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No pending requests',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: receivedRequests.length,
                                      itemBuilder: (context, index) {
                                        final request = receivedRequests[index];
                                        final userData = request['requester']
                                                as Map<String, dynamic>? ??
                                            {'username': 'Unknown', 'user_points': 0};
                                        final requesterUsername =
                                            userData['username'] as String;
                                        final requesterPoints =
                                            userData['user_points'] as int;

                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.orange,
                                              child: Text(
                                                requesterUsername.isNotEmpty
                                                    ? requesterUsername[0]
                                                        .toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(requesterUsername),
                                            subtitle: Text(
                                              'Points: $requesterPoints',
                                              style: const TextStyle(
                                                  fontSize: 14),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green),
                                                  onPressed: () {
                                                    _acceptFriendRequest(
                                                        request['id']
                                                            as String);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.cancel,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    _showRejectConfirmation(
                                                        context,
                                                        request['id'] as String,
                                                        requesterUsername);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                              // Sent Requests Tab
                              sentRequests.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.send_outlined,
                                              size: 80,
                                              color: Colors.grey[400]),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No pending requests',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: sentRequests.length,
                                      itemBuilder: (context, index) {
                                        final request = sentRequests[index];
                                        final userData = request['recipient']
                                                as Map<String, dynamic>? ??
                                            {'username': 'Unknown', 'user_points': 0};
                                        final recipientUsername =
                                            userData['username'] as String;
                                        final recipientPoints =
                                            userData['user_points'] as int;

                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.blue,
                                              child: Text(
                                                recipientUsername.isNotEmpty
                                                    ? recipientUsername[0]
                                                        .toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(recipientUsername),
                                            subtitle: Text(
                                              'Points: $recipientPoints (pending)',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                  Icons.cancel,
                                                  color: Colors.red),
                                              onPressed: () {
                                                _showCancelConfirmation(
                                                    context,
                                                    request['id'] as String,
                                                    recipientUsername);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor: const Color(0xff6200EE),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _showRejectConfirmation(
      BuildContext context, String friendshipId, String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Request'),
          content: Text(
              'Are you sure you want to reject the friend request from $username?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _rejectFriendRequest(friendshipId);
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showCancelConfirmation(
      BuildContext context, String friendshipId, String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Request'),
          content: Text(
              'Are you sure you want to cancel the friend request to $username?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeFriend(friendshipId);
              },
              child: const Text('Cancel Request',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveConfirmation(
      BuildContext context, String friendshipId, String friendUsername) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Friend'),
          content:
              Text('Are you sure you want to remove $friendUsername as a friend?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeFriend(friendshipId);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class _AddFriendDialog extends StatefulWidget {
  final String? currentUsername;
  final VoidCallback onFriendAdded;

  const _AddFriendDialog({
    required this.currentUsername,
    required this.onFriendAdded,
  });

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Set<String> _currentFriends = {};
  String? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('username');
    await _loadCurrentFriends();
  }

  Future<void> _loadCurrentFriends() async {
    if (_currentUser == null) return;

    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('friendships')
          .select('user_id_1, user_id_2')
          .or('user_id_1.eq.$_currentUser,user_id_2.eq.$_currentUser');

      final friends = <String>{};
      for (var friendship in response) {
        final userId1 = friendship['user_id_1'] as String;
        final userId2 = friendship['user_id_2'] as String;
        
        if (userId1 == _currentUser) {
          friends.add(userId2);
        } else {
          friends.add(userId1);
        }
      }

      if (mounted) {
        setState(() {
          _currentFriends = friends;
        });
      }
    } catch (e) {
      print('Error loading current friends: $e');
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('users_data')
          .select('username, user_points')
          .ilike('username', '%$query%')
          .limit(10);

      if (mounted) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(response)
              .where((user) =>
                  user['username'] != _currentUser &&
                  !_currentFriends.contains(user['username']))
              .toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Error searching users: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _addFriend(String friendUsername) async {
    if (_currentUser == null) return;

    final supabase = Supabase.instance.client;
    try {
      await supabase.from('friendships').insert({
        'user_id_1': _currentUser,
        'user_id_2': friendUsername,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        setState(() {
          _searchResults.removeWhere((user) => user['username'] == friendUsername);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request sent to $friendUsername!')),
        );

        // Notify parent to refresh
        widget.onFriendAdded();
        
        // Close the dialog after sending request
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending friend request: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 500,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xff6200EE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Text(
                'Add Friend',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _searchUsers,
                decoration: InputDecoration(
                  hintText: 'Search by username',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Start typing to search users'
                                : 'No users found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            final username = user['username'] as String;
                            final points = user['user_points'] as int;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xff6200EE),
                                child: Text(
                                  username[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(username),
                              subtitle: Text('Points: $points'),
                              trailing: ElevatedButton(
                                onPressed: () => _addFriend(username),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff6200EE),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Add'),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(45),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
