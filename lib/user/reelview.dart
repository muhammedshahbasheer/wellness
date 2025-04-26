import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class ReelViewer extends StatefulWidget {
  const ReelViewer({Key? key}) : super(key: key);

  @override
  State<ReelViewer> createState() => _ReelViewerState();
}

class _ReelViewerState extends State<ReelViewer> {
  final PageController _pageController = PageController();
  List<String> _reelLinks = [];
  List<VideoPlayerController> _controllers = [];
  bool isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchReels();
  }

  Future<void> _fetchReels() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('reels')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _reelLinks = snapshot.docs.map((doc) => doc['reel_link'] as String).toList();
        await _initializeControllers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No reels found')),
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reels: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _initializeControllers() async {
    for (String link in _reelLinks) {
      final controller = VideoPlayerController.network(link);
      await controller.initialize();
      controller.setLooping(true);
      _controllers.add(controller);
    }

    setState(() {
      isLoading = false;
    });

    _controllers.first.play(); // Play the first video initially
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });

    for (int i = 0; i < _controllers.length; i++) {
      if (i == index) {
        _controllers[i].play();
      } else {
        _controllers[i].pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _controllers.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final controller = _controllers[index];
                return controller.value.isInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                          if (controller.value.isBuffering)
                            const CircularProgressIndicator(color: Colors.white),
                        ],
                      )
                    : const Center(
                        child: Text(
                          'Loading video...',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
              },
            ),
    );
  }
}
