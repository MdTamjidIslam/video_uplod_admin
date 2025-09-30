// /// ===================== Upload Page =====================
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:html' as html;
// import 'package:flutter/material.dart';
//
// class UploadPage extends StatefulWidget {
//   const UploadPage({super.key});
//   @override
//   State<UploadPage> createState() => _UploadPageState();
// }
//
// class _UploadPageState extends State<UploadPage> {
//   List<dynamic> _videosList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchVideos();
//   }
//
//   Future<void> _fetchVideos() async {
//     try {
//       final url = 'http://192.168.0.202:8080/videos';
//       final request = await html.HttpRequest.request(url, method: 'GET');
//       if (request.status == 200) {
//         final data = jsonDecode(request.responseText!);
//         setState(() {
//           _videosList = data['videos'] ?? [];
//         });
//       } else {
//         setState(() => _videosList = []);
//       }
//     } catch (e) {
//       setState(() => _videosList = []);
//     }
//   }
//
//   void _openUploadPopup() {
//     showDialog(
//       context: context,
//       builder: (ctx) => UploadPopup(onUploaded: () {
//         Navigator.pop(ctx);
//         _fetchVideos();
//       }),
//     );
//   }
//
//   /// viewers Popup
//   void _showViewersPopup(Map item) {
//     final viewers = (item['viewers'] ?? []) as List;
//     List<String> ips = [];
//     for (var v in viewers) {
//       if (v is Map && v.containsKey('ip')) {
//         ips.add(v['ip']);
//       }
//     }
//     final uniqueIps = ips.toSet().toList();
//     final popupWidth = MediaQuery.of(context).size.width * 0.5;
//     final popupHeight = MediaQuery.of(context).size.height * 0.5;
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         return AlertDialog(
//           title: Text('Viewers IPs (${item['title']})'),
//           content: SizedBox(
//             width: popupWidth,
//             height: popupHeight,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Total Clicks: ${ips.length}',
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//                 Text('Unique IPs: ${uniqueIps.length}',
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//                 const Divider(),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: ips.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         dense: true,
//                         leading: const Icon(Icons.public, size: 18),
//                         title: Text('${index + 1} - ${ips[index]}'),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text('Close')),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildVideoTable() {
//     if (_videosList.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Text('No videos found'),
//       );
//     }
//     int totalClicksSum = 0;
//     int uniqueViewsSum = 0;
//     for (var item in _videosList) {
//       totalClicksSum += int.tryParse(item['unique_views']?.toString() ?? '0') ?? 0;
//       uniqueViewsSum += int.tryParse(item['unique_views']?.toString() ?? '0') ?? 0;
//     }
//     return DataTable(
//       headingRowColor: MaterialStateProperty.all(Colors.indigo.shade100),
//       columns: [
//         const DataColumn(label: Text('Title')),
//         const DataColumn(label: Text('Filename')),
//         const DataColumn(label: Text('Video URL')),
//         // এখন হেডারে মোট যোগফল দেখাচ্ছে
//         DataColumn(label: Text('Total Clicks ($totalClicksSum)')),
//         DataColumn(label: Text('Unique Views ($uniqueViewsSum)')),
//       ],
//       rows: List<DataRow>.generate(_videosList.length, (index) {
//         final item = _videosList[index];
//         final title = item['title']?.toString() ?? '';
//         final filename = item['original_filename']?.toString() ?? '';
//         final videoUrl =
//             item['video_url']?.toString() ?? item['video_link']?.toString() ?? '';
//         final totalClicks = item['unique_views']?.toString() ?? '0';
//         //  final totalClicks = item['total_clicks']?.toString() ?? '0';
//         final uniqueViews = item['unique_views']?.toString() ?? '0';
//
//         return DataRow(
//           color: MaterialStateProperty.all(
//               index % 2 == 0 ? Colors.grey.shade50 : Colors.grey.shade200),
//           cells: [
//             DataCell(Text(title)),
//             DataCell(Text(filename)),
//             DataCell(
//               InkWell(
//                 onTap: () {
//                   if (videoUrl.isNotEmpty) {
//                     html.window.open(videoUrl, '_blank');
//                   }
//                 },
//                 child: Text(
//                   videoUrl.isEmpty ? 'No Link' : 'Open',
//                   style: TextStyle(
//                       color: videoUrl.isEmpty ? Colors.grey : Colors.blue,
//                       decoration: videoUrl.isEmpty
//                           ? TextDecoration.none
//                           : TextDecoration.underline),
//                 ),
//               ),
//             ),
//             DataCell(Text(totalClicks)),
//             DataCell(Row(
//               children: [
//                 Text(uniqueViews),
//                 IconButton(
//                   icon: const Icon(Icons.list, size: 20),
//                   tooltip: 'Show IPs',
//                   onPressed: () => _showViewersPopup(item),
//                 ),
//               ],
//             )),
//           ],
//         );
//       }),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Video Upload ',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(width: 20),
//             TextButton.icon(
//               icon: const Icon(Icons.upload, color: Colors.green),
//               label: const Text('Upload',
//                   style: TextStyle(color: Colors.green)),
//               onPressed: _openUploadPopup,
//             ),
//           ],
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       minWidth: constraints.maxWidth,
//                     ),
//                     child: _buildVideoTable(),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// /// ===================== Upload Popup =====================
// class UploadPopup extends StatefulWidget {
//   final VoidCallback onUploaded;
//   const UploadPopup({super.key, required this.onUploaded});
//
//   @override
//   State<UploadPopup> createState() => _UploadPopupState();
// }
//
// class _UploadPopupState extends State<UploadPopup> {
//   html.File? _imageFile;
//   html.File? _videoFile;
//
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _videoLinkController = TextEditingController();
//   final TextEditingController _subtitleController = TextEditingController();
//
//   bool _isUploading = false;
//   String _message = '';
//
//   Future<void> _pickFile({required bool isImage}) async {
//     final input = html.FileUploadInputElement()
//       ..accept = isImage ? 'image/*' : 'video/*';
//     input.click();
//     input.onChange.listen((event) {
//       if (input.files!.isNotEmpty) {
//         setState(() {
//           if (isImage) {
//             _imageFile = input.files!.first;
//           } else {
//             _videoFile = input.files!.first;
//           }
//         });
//       }
//     });
//   }
//
//   Future<void> _uploadData() async {
//     if (_titleController.text.isEmpty ||
//         _videoLinkController.text.isEmpty ||
//         _subtitleController.text.isEmpty ||
//         _imageFile == null ||
//         _videoFile == null) {
//       setState(() => _message = '⚠️ Please fill all fields and choose files.');
//       return;
//     }
//
//     setState(() {
//       _isUploading = true;
//       _message = '';
//     });
//
//     final uri = Uri.parse('http://192.168.0.202:8080/admin/upload');
//     final request = html.HttpRequest();
//     final formData = html.FormData();
//
//     formData.append('title', _titleController.text);
//     formData.appendBlob('file', _videoFile!, _videoFile!.name);
//     formData.append('video_link', _videoLinkController.text);
//     formData.append('subtitle', _subtitleController.text);
//     formData.appendBlob('image', _imageFile!, _imageFile!.name);
//
//     request.open('POST', uri.toString());
//     request.withCredentials = false;
//
//     request.onLoadEnd.listen((event) {
//       setState(() {
//         _isUploading = false;
//       });
//       if (request.status == 200 || request.status == 201) {
//         setState(() => _message = '✅ Upload Success!');
//         Future.delayed(const Duration(seconds: 2), () {
//           widget.onUploaded();
//         });
//       } else if (request.status == 0) {
//         setState(() => _message =
//         '⚠️ No response (CORS issue). Allow CORS on server.');
//       } else {
//         setState(() => _message =
//         '❌ Upload failed! Status: ${request.status} ${request.statusText}');
//       }
//     });
//
//     request.send(formData);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Responsive বড় pop-up
//     final popupWidth = MediaQuery.of(context).size.width * 0.5;
//     final popupHeight = MediaQuery.of(context).size.height * 0.5;
//
//     return AlertDialog(
//       insetPadding: const EdgeInsets.all(10),
//       contentPadding: const EdgeInsets.all(20),
//       title: const Text('Upload Your Video'),
//       content: SizedBox(
//         width: popupWidth,
//         height: popupHeight,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Title',
//                   prefixIcon: Icon(Icons.title),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _videoLinkController,
//                 decoration: const InputDecoration(
//                   labelText: 'Video Link URL',
//                   prefixIcon: Icon(Icons.link),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _subtitleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Subtitle',
//                   prefixIcon: Icon(Icons.subtitles),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.image),
//                 label: Text(_imageFile == null
//                     ? 'Choose Image'
//                     : 'Image: ${_imageFile!.name}'),
//                 onPressed: () => _pickFile(isImage: true),
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.video_library),
//                 label: Text(_videoFile == null
//                     ? 'Choose Video File'
//                     : 'Video: ${_videoFile!.name}'),
//                 onPressed: () => _pickFile(isImage: false),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 45,
//                 child: ElevatedButton.icon(
//                   icon: _isUploading
//                       ? const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                       : const Icon(Icons.cloud_upload),
//                   label: Text(
//                     _isUploading ? 'Uploading...' : 'Submit',
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   onPressed: _isUploading ? null : _uploadData,
//                 ),
//               ),
//               if (_message.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 10),
//                   child: Text(
//                     _message,
//                     style: TextStyle(
//                       color: _message.contains('Success')
//                           ? Colors.green
//                           : Colors.red,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel')),
//       ],
//     );
//   }
// }