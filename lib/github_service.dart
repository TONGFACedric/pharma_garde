import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GitHubRelease {
  final String tagName;
  final String name;
  final String body;
  final List<GitHubAsset> assets;
  final DateTime publishedAt;

  GitHubRelease({
    required this.tagName,
    required this.name,
    required this.body,
    required this.assets,
    required this.publishedAt,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    return GitHubRelease(
      tagName: json['tag_name'] ?? '',
      name: json['name'] ?? '',
      body: json['body'] ?? '',
      assets: (json['assets'] as List<dynamic>?)
              ?.map((asset) => GitHubAsset.fromJson(asset))
              .toList() ??
          [],
      publishedAt: DateTime.parse(json['published_at'] ?? ''),
    );
  }
}

class GitHubAsset {
  final String name;
  final String browserDownloadUrl;
  final int size;

  GitHubAsset({
    required this.name,
    required this.browserDownloadUrl,
    required this.size,
  });

  factory GitHubAsset.fromJson(Map<String, dynamic> json) {
    return GitHubAsset(
      name: json['name'] ?? '',
      browserDownloadUrl: json['browser_download_url'] ?? '',
      size: json['size'] ?? 0,
    );
  }
}

class GitHubService {
  static const String _repoOwner = 'TONGFACedric';
  static const String _repoName = 'pharma_garde';
  static const String _baseUrl = 'https://api.github.com';

  final Dio _dio = Dio();

  Future<GitHubRelease?> getLatestRelease() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/repos/$_repoOwner/$_repoName/releases/latest',
      );

      if (response.statusCode == 200) {
        return GitHubRelease.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching latest release: $e');
    }
    return null;
  }

  Future<bool> isUpdateAvailable() async {
    try {
      final latestRelease = await getLatestRelease();
      if (latestRelease == null) return false;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      return _isVersionNewer(latestRelease.tagName, currentVersion);
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return false;
    }
  }

  bool _isVersionNewer(String latestVersion, String currentVersion) {
    // Remove 'v' prefix if present
    latestVersion = latestVersion.replaceAll('v', '');
    currentVersion = currentVersion.replaceAll('v', '');

    final latestParts = latestVersion.split('.').map(int.parse).toList();
    final currentParts = currentVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length && i < currentParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }

    return latestParts.length > currentParts.length;
  }

  Future<String?> downloadUpdate(GitHubRelease release) async {
    try {
      // Find the appropriate asset for the current platform
      GitHubAsset? asset;
      if (Platform.isAndroid) {
        asset = release.assets.firstWhere(
          (a) => a.name.endsWith('.apk'),
          orElse: () => release.assets.firstWhere(
            (a) => a.name.contains('.apk'),
            orElse: () => release.assets.first,
          ),
        );
      } else if (Platform.isIOS) {
        asset = release.assets.firstWhere(
          (a) => a.name.endsWith('.ipa'),
          orElse: () => release.assets.firstWhere(
            (a) => a.name.contains('.ipa'),
            orElse: () => release.assets.first,
          ),
        );
      }

      if (asset == null) {
        debugPrint('No suitable asset found for current platform');
        return null;
      }

      // Get downloads directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        debugPrint('Could not get external storage directory');
        return null;
      }

      final filePath = '${directory.path}/${asset.name}';

      // Download the file
      await _dio.download(
        asset.browserDownloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
                'Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      return filePath;
    } catch (e) {
      debugPrint('Error downloading update: $e');
      return null;
    }
  }

  Future<void> installUpdate(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        debugPrint('Failed to open file: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error installing update: $e');
    }
  }

  Future<void> checkForUpdatesAndNotify(BuildContext context) async {
    if (await isUpdateAvailable()) {
      final latestRelease = await getLatestRelease();
      if (latestRelease != null && context.mounted) {
        _showUpdateDialog(context, latestRelease);
      }
    }
  }

  void _showUpdateDialog(BuildContext context, GitHubRelease release) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version ${release.tagName}'),
              const SizedBox(height: 8),
              Text(release.body),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _downloadAndInstallUpdate(context, release);
              },
              child: const Text('Update Now'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadAndInstallUpdate(
      BuildContext context, GitHubRelease release) async {
    // Show download progress
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Downloading update...'),
            ],
          ),
        );
      },
    );

    try {
      final filePath = await downloadUpdate(release);
      Navigator.of(context).pop(); // Close download dialog

      if (filePath != null) {
        await installUpdate(filePath);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download update')),
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close download dialog
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
