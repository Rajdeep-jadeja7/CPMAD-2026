import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// -------------------------------------------------------------
// DART MODEL CLASS FOR QUOTE
// -------------------------------------------------------------
class Quote {
  final String content;
  final String author;
  final String category;

  const Quote({
    required this.content,
    required this.author,
    this.category = 'General',
  });

  // Factory to parse JSON response
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['quote'] ?? json['content'] ?? json['text'] ?? 'No quote found',
      author: json['author'] ?? 'Unknown Author',
      category: json['category'] ?? 'General',
    );
  }
}

// Global list for saved favorite quotes
List<Quote> favoriteQuotes = [];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quote App',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const MainTabScreen(),
    );
  }
}

// -------------------------------------------------------------
// MAIN TAB SCREEN (Quote Screen, Favorites Screen, Joke API Screen)
// -------------------------------------------------------------
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    QuoteScreen(),
    FavoriteQuotesScreen(),
    JokeApiScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.format_quote), label: 'Quotes'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Jokes API'),
        ],
      ),
    );
  }
}

// =============================================================
// 1. MAIN TASK: QUOTE APPLICATION
// HTTP GET, REST API, JSON, FutureBuilder, async/await, Error Handling,
// Categories selection, Sharing, and Favorites.
// =============================================================
class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  late Future<Quote> _quoteFuture;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Motivation', 'Success', 'Life', 'Education'];

  // Local fallback quotes for categories/offline assurance
  final Map<String, List<Quote>> _categoryQuotes = {
    'Motivation': [
      const Quote(content: 'Believe you can and you are halfway there.', author: 'Theodore Roosevelt', category: 'Motivation'),
      const Quote(content: 'Start where you are. Use what you have. Do what you can.', author: 'Arthur Ashe', category: 'Motivation'),
    ],
    'Success': [
      const Quote(content: 'Success is not final; failure is not fatal: It is the courage to continue that counts.', author: 'Winston Churchill', category: 'Success'),
      const Quote(content: 'The secret of success is to do the common thing uncommonly well.', author: 'John D. Rockefeller', category: 'Success'),
    ],
    'Life': [
      const Quote(content: 'Life is what happens when you are busy making other plans.', author: 'John Lennon', category: 'Life'),
      const Quote(content: 'In the end, it is not the years in your life that count. It is the life in your years.', author: 'Abraham Lincoln', category: 'Life'),
    ],
    'Education': [
      const Quote(content: 'Education is the most powerful weapon which you can use to change the world.', author: 'Nelson Mandela', category: 'Education'),
      const Quote(content: 'Live as if you were to die tomorrow. Learn as if you were to live forever.', author: 'Mahatma Gandhi', category: 'Education'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _quoteFuture = fetchQuote();
  }

  // HTTP GET Request with async/await and error handling
  Future<Quote> fetchQuote() async {
    // If user filtered by specific category, return category quote
    if (_selectedCategory != 'All' && _categoryQuotes.containsKey(_selectedCategory)) {
      await Future.delayed(const Duration(milliseconds: 400));
      final list = _categoryQuotes[_selectedCategory]!;
      list.shuffle();
      return list.first;
    }

    try {
      final url = Uri.parse('https://dummyjson.com/quotes/random');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Quote.fromJson(data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Graceful fallback on network failure without crashing
      return const Quote(
        content: 'Your time is limited, so do not waste it living someone else life.',
        author: 'Steve Jobs',
        category: 'Motivation',
      );
    }
  }

  // Sharing Feature
  void _shareQuote(Quote quote) {
    final shareText = '"${quote.content}"\n— ${quote.author}';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote copied to clipboard to share!')),
    );
  }

  // Toggle Favorite
  void _toggleFavorite(Quote quote) {
    setState(() {
      final isFav = favoriteQuotes.any((q) => q.content == quote.content);
      if (isFav) {
        favoriteQuotes.removeWhere((q) => q.content == quote.content);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      } else {
        favoriteQuotes.add(quote);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to favorites!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quotes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Category Filter Dropdown
            Row(
              children: [
                const Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                        _quoteFuture = fetchQuote();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // FutureBuilder to manage asynchronous state
            Expanded(
              child: Center(
                child: FutureBuilder<Quote>(
                  future: _quoteFuture,
                  builder: (context, snapshot) {
                    // 1. Loading State
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Fetching inspiring quote...'),
                        ],
                      );
                    }

                    // 2. Error State
                    if (snapshot.hasError) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('Failed to load quote: ${snapshot.error}'),
                        ],
                      );
                    }

                    // 3. Successful Response State
                    if (snapshot.hasData) {
                      final quote = snapshot.data!;
                      final isFav = favoriteQuotes.any((q) => q.content == quote.content);

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.format_quote, size: 50, color: Colors.indigo),
                              const SizedBox(height: 12),
                              Text(
                                '"${quote.content}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '— ${quote.author}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                              const Divider(height: 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Favorite Button
                                  IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () => _toggleFavorite(quote),
                                  ),
                                  const SizedBox(width: 16),
                                  // Share Button
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.indigo),
                                    onPressed: () => _shareQuote(quote),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // 4. Empty Response State
                    return const Text('No quotes available.');
                  },
                ),
              ),
            ),

            // Button to fetch another quote
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('New Quote', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  setState(() {
                    _quoteFuture = fetchQuote();
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// POST-LAB TASK: FAVORITE QUOTES SCREEN
// View and remove saved quotes
// =============================================================
class FavoriteQuotesScreen extends StatefulWidget {
  const FavoriteQuotesScreen({super.key});

  @override
  State<FavoriteQuotesScreen> createState() => _FavoriteQuotesScreenState();
}

class _FavoriteQuotesScreenState extends State<FavoriteQuotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Quotes'),
      ),
      body: favoriteQuotes.isEmpty
          ? const Center(child: Text('No favorite quotes saved yet!'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favoriteQuotes.length,
              itemBuilder: (context, index) {
                final q = favoriteQuotes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.format_quote, color: Colors.indigo),
                    title: Text('"${q.content}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                    subtitle: Text('— ${q.author}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          favoriteQuotes.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// =============================================================
// POST-LAB TASK: RANDOM JOKES REST API APP
// Consumes different REST API using HTTP, JSON, FutureBuilder
// =============================================================
class JokeApiScreen extends StatefulWidget {
  const JokeApiScreen({super.key});

  @override
  State<JokeApiScreen> createState() => _JokeApiScreenState();
}

class _JokeApiScreenState extends State<JokeApiScreen> {
  late Future<Map<String, String>> _jokeFuture;

  @override
  void initState() {
    super.initState();
    _jokeFuture = fetchJoke();
  }

  Future<Map<String, String>> fetchJoke() async {
    try {
      final url = Uri.parse('https://official-joke-api.appspot.com/random_joke');
      final res = await http.get(url).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          'setup': data['setup'] ?? '',
          'punchline': data['punchline'] ?? '',
        };
      } else {
        throw Exception('Failed to load joke');
      }
    } catch (e) {
      return {
        'setup': 'Why do programmers prefer dark mode?',
        'punchline': 'Because light attracts bugs!',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Jokes API'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FutureBuilder<Map<String, String>>(
                  future: _jokeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.hasData) {
                      final joke = snapshot.data!;
                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sentiment_very_satisfied, size: 48, color: Colors.orange),
                              const SizedBox(height: 12),
                              Text(joke['setup']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text(joke['punchline']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.indigo, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      );
                    }
                    return const Text('No joke found.');
                  },
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Another Joke'),
                onPressed: () {
                  setState(() {
                    _jokeFuture = fetchJoke();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
