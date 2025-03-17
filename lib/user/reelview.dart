import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class ReelViewer extends StatefulWidget {
  const ReelViewer({Key? key}) : super(key: key);

  @override
  State<ReelViewer> createState() => _ReelViewerState();
}

class _ReelViewerState extends State<ReelViewer> {
  VideoPlayerController? _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReel();
  }

  Future<void> _fetchReel() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('reels')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String reelLink = snapshot.docs.first['reel_link'];
        print('Reel link: $reelLink');
        _initializeVideo(reelLink);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No reel found')),
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reel: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  void _initializeVideo(String url) {
    try {
      _controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {
            isLoading = false;
          });
          _controller!.play();
          _controller!.setLooping(true);
        }).catchError((e) {
          print('Error initializing video: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load video')),
          );
          setState(() => isLoading = false);
        });

      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          print('Video player error: ${_controller!.value.errorDescription}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playback error: ${_controller!.value.errorDescription}')),
          );
        }
      });
    } catch (e) {
      print('Exception during video initialization: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while playing the video')),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reel Viewer')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_controller!),
                        if (_controller!.value.isBuffering)
                          const CircularProgressIndicator(),
                      ],
                    ),
                  )
                : const Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white),
                  ),
      ),
    );
  }
}
