import 'package:googleapis/photoslibrary/v1.dart' as photos;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GoogleAuthService {
  static const _scopes = [
    'https://www.googleapis.com/auth/photoslibrary.appendonly',
    'https://www.googleapis.com/auth/photoslibrary'
  ];

  final String _clientId;
  final String _clientSecret;

  GoogleAuthService(this._clientId, this._clientSecret);

  Future<AutoRefreshingAuthClient> _getAuthenticatedClient() async {
    final clientId = ClientId(_clientId, _clientSecret);
    final client = await clientViaUserConsent(
      clientId,
      _scopes,
          (url) async {
        print('Please go to the following URL and grant access:');
        print('  => $url');
        // Ouvrir l'URL dans un navigateur
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
    );
    return client;
  }

  Future<String> uploadImageToGooglePhotos(String imagePath) async {
    final client = await _getAuthenticatedClient();
    final photosApi = photos.PhotosLibraryApi(client);

    final uploadToken = await _uploadImage(imagePath, client);

    final request = photos.NewMediaItem(
      simpleMediaItem: photos.SimpleMediaItem(
        uploadToken: uploadToken,
      ),
    );

    final response = await photosApi.mediaItems.batchCreate(
      photos.BatchCreateMediaItemsRequest(
        newMediaItems: [request],
      ),
    );

    if (response.newMediaItemResults != null && response.newMediaItemResults!.isNotEmpty) {
      final mediaItem = response.newMediaItemResults!.first.mediaItem;
      return mediaItem?.baseUrl ?? '';
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<String> _uploadImage(String imagePath, AutoRefreshingAuthClient client) async {
    const uploadUrl = 'https://photoslibrary.googleapis.com/v1/uploads';

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..headers.addAll({
        'Authorization': 'Bearer ${client.credentials.accessToken.data}',
        'Content-Type': 'application/octet-stream',
      })
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return responseBody;
    } else {
      throw Exception('Failed to upload image');
    }
  }
}
