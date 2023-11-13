import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class TopLike {
  final String title;
  final bool isLiked;

  TopLike({required this.title, required this.isLiked});
}

class Audio {
  final String title;
  final String audioUrl;

  Audio({required this.title, required this.audioUrl});
}

class TopLikeRepository {
  Future<List<TopLike>> getTopLikes() async {
    return [
      TopLike(title: 'Item 1', isLiked: false),
      TopLike(title: 'Item 2', isLiked: false),
      TopLike(title: 'Item 3', isLiked: false),
    ];
  }
}

class AudioRepository {
  Future<Audio> getAudio() async {
    final dio = Dio();
    final response = await dio.get('https://api.quran.com/api/v4/chapter_recitations/1/1');
    final audioUrl = response.data['data']['attributes']['audio_url'] as String;
    return Audio(title: 'Audio Title', audioUrl: audioUrl);
  }
}

class GetTopLikes {
  final TopLikeRepository repository;

  GetTopLikes(this.repository);

  Future<List<TopLike>> execute() async {
    return await repository.getTopLikes();
  }
}

class GetAudio {
  final AudioRepository repository;

  GetAudio(this.repository);

  Future<Audio> execute() async {
    return await repository.getAudio();
  }
}

class AudioPlayerWidget extends StatelessWidget {
  final String audioUrl;

  AudioPlayerWidget({required this.audioUrl});

  @override
  Widget build(BuildContext context) {
    final audioPlayer = AudioPlayer();

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            audioPlayer.play(audioUrl);
          },
          child: Text('Play Audio'),
        ),
        ElevatedButton(
          onPressed: () {
            audioPlayer.stop();
          },
          child: Text('Stop Audio'),
        ),
      ],
    );
  }
}

class TopLikesAndAudiosTab extends StatelessWidget {
  final GetTopLikes getTopLikes;
  final GetAudio getAudio;

  TopLikesAndAudiosTab({required this.getTopLikes, required this.getAudio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Likes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        FutureBuilder<List<TopLike>>(
          future: getTopLikes.execute(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('An error occurred: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No data available');
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final topLike = snapshot.data![index];
                    return ListTile(
                      title: Text(topLike.title),
                      trailing: IconButton(
                        icon: Icon(topLike.isLiked ? Icons.favorite : Icons.favorite_border, color: topLike.isLiked ? Colors.red : null),
                        onPressed: () {
                          // Toggle like button functionality
                          // Note: Since TopLike is not mutable, you may need to use a mutable data structure or update the state differently.
                        },
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
        SizedBox(height: 20),
        Text(
          'Listen Audios',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        FutureBuilder<Audio>(
          future: getAudio.execute(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('An error occurred: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData) {
              return Text('No audio data available');
            } else {
              return AudioPlayerWidget(audioUrl: snapshot.data!.audioUrl);
            }
          },
        ),
      ],
    );
  }
}

class MoreTab extends StatefulWidget {
  @override
  _MoreTabState createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  bool isDarkMode = false;
  bool isArabicLanguage = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dark Mode',
                style: TextStyle(fontSize: 18),
              ),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                    // Implement dark mode toggle functionality here
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Arabic Language',
                style: TextStyle(fontSize: 18),
              ),
              Switch(
                value: isArabicLanguage,
                onChanged: (value) {
                  setState(() {
                    isArabicLanguage = value;
                    // Implement Arabic language toggle functionality here
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GetTopLikes getTopLikes;
  late GetAudio getAudio;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final topLikeRepository = TopLikeRepository();
    final audioRepository = AudioRepository();
    getTopLikes = GetTopLikes(topLikeRepository);
    getAudio = GetAudio(audioRepository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'This is App',
          style: TextStyle(color: Colors.purple),
        ),
        backgroundColor:        Colors.white,
      ),
      body: _getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.purple),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz, color: Colors.purple),
            label: 'More',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return TopLikesAndAudiosTab(getTopLikes: getTopLikes, getAudio: getAudio);
      case 1:
        return MoreTab();
      default:
        return Container();
    }
  }
}

