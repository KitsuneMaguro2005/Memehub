import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
// ใช้ youtube_player_iframe สำหรับ Web/Mobile
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() {
  runApp(const MemeApp());
}

// MODEL: สำหรับจัดการข้อมูลมีม

class Meme {
  final String title;
  final String url;
  final String author;
  final String? youtubeId; // มีค่าเฉพาะเมื่อเป็นวิดีโอ

  Meme({
    required this.title,
    required this.url,
    required this.author,
    this.youtubeId,
  });
}
// MAIN APP & THEME
class MemeApp extends StatelessWidget {
  const MemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meme Hub',
      debugShowCheckedModeBanner: false,
     theme: ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // แนะนำใน Flutter ปัจจุบัน
  colorSchemeSeed: Colors.deepPurple,

  scaffoldBackgroundColor: const Color(0xFF121212),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    elevation: 0,
    centerTitle: true,
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 6,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(fontSize: 16),
  ),
),
      home: const HomeScreen(),
    );
  }
}

// HOME SCREEN: หน้าหลักแสดงรายการมีม
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Meme>> _memesFuture;

  @override
  void initState() {
    super.initState();
    _memesFuture = fetchMemes();
  }

  // Logic การดึงข้อมูล API
  Future<List<Meme>> fetchMemes() async {
    List<Meme> memeList = [];

    memeList.add(
      Meme(
        title: "The Ultimate Trap (Rickroll) 🕺",
        url: "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
        author: "Rick Astley",
        youtubeId: "dQw4w9WgXcQ",
      ),
    );

    try {
      final response = await http.get(
        Uri.parse('https://meme-api.com/gimme/15'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (var item in data['memes']) {
          memeList.add(
            Meme(
              title: item['title'],
              url: item['url'],
              author: "r/${item['subreddit']} • ${item['author']}",
            ),
          );
        }
      } else {
        throw Exception('Failed to load memes');
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }

    return memeList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rand🔥m Meme Hub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Meme>>(
        future: _memesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่พบข้อมูลมีม'));
          }

          final memes = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _memesFuture = fetchMemes();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: memes.length,
              itemBuilder: (context, index) {
                final meme = memes[index];
                final isVideo = meme.youtubeId != null;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(meme: meme),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Hero(
                                tag: meme.url,
                                child: CachedNetworkImage(
                                  imageUrl: meme.url,
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 250,
                                    color: Colors.black12,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const SizedBox(
                                        height: 250,
                                        child: Icon(Icons.error, size: 50),
                                      ),
                                ),
                              ),
                            ),
                            if (isVideo)
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(12),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meme.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "By: ${meme.author}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// DETAIL SCREEN: หน้าแสดงรายละเอียดและเล่นวิดีโอ
class DetailScreen extends StatefulWidget {
  final Meme meme;

  const DetailScreen({super.key, required this.meme});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    if (widget.meme.youtubeId != null) {
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: widget.meme.youtubeId!,
        autoPlay: true, // ตั้งค่าให้เล่นอัตโนมัติ
        params: const YoutubePlayerParams(
          showControls: true,
          mute:
              true, 
          showFullscreenButton: true,
          loop: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.meme.youtubeId != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isVideo && _youtubeController != null)
              // แก้ไข: ใช้ AspectRatio ครอบทับแทนการใส่ aspectRatio ใน YoutubePlayer โดยตรง
              AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(controller: _youtubeController!),
              )
            else
              Hero(
                tag: widget.meme.url,
                child: CachedNetworkImage(
                  imageUrl: widget.meme.url,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.meme.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        widget.meme.author,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    isVideo
                        ? "เตรียมตัวรับชมความคลาสสิก! เรียบร้อยโดย Rickrolled ซะ "
                        : "มีมนี้ถูกดึงมาจาก Public API (meme-api.com)",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
