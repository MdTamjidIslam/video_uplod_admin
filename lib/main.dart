//
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:html' as html;
// import 'package:flutter/material.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Upload + List Demo',
//       theme: ThemeData(primarySwatch: Colors.indigo),
//       debugShowCheckedModeBanner: false,
//       home: const UploadPage(),
//     );
//   }
// }
//
// /// ===================== Upload Page =====================
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
//   /// === Edit Popup ===
//   void _openEditPopup(Map item) {
//     final TextEditingController titleCtrl =
//     TextEditingController(text: item['title']?.toString() ?? '');
//     final TextEditingController subtitleCtrl =
//     TextEditingController(text: item['subtitle']?.toString() ?? '');
//     final TextEditingController videoLinkCtrl =
//     TextEditingController(text: item['video_link']?.toString() ?? '');
//
//     html.File? newImage;
//     html.File? newVideo;
//
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         bool isSaving = false;
//         String message = '';
//
//         // pick file helper
//         Future<void> pickFile(bool isImage) async {
//           final input = html.FileUploadInputElement()
//             ..accept = isImage ? 'image/*' : 'video/*';
//           input.click();
//           input.onChange.listen((event) {
//             if (input.files!.isNotEmpty) {
//               if (isImage) {
//                 newImage = input.files!.first;
//               } else {
//                 newVideo = input.files!.first;
//               }
//             }
//           });
//         }
//
//         return StatefulBuilder(
//           builder: (ctx, setStateSB) => AlertDialog(
//             title: Text('Edit Video (${item['id']})'),
//             content: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.5,
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: titleCtrl,
//                       decoration: const InputDecoration(
//                         labelText: 'Title',
//                         prefixIcon: Icon(Icons.title),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: subtitleCtrl,
//                       decoration: const InputDecoration(
//                         labelText: 'Subtitle',
//                         prefixIcon: Icon(Icons.subtitles),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: videoLinkCtrl,
//                       decoration: const InputDecoration(
//                         labelText: 'Video Link',
//                         prefixIcon: Icon(Icons.link),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.image),
//                       label: Text(newImage == null
//                           ? 'Change Image'
//                           : 'Image: ${newImage!.name}'),
//                       onPressed: () => pickFile(true),
//                     ),
//                     const SizedBox(height: 12),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.video_library),
//                       label: Text(newVideo == null
//                           ? 'Change Video File'
//                           : 'Video: ${newVideo!.name}'),
//                       onPressed: () => pickFile(false),
//                     ),
//                     if (message.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 10),
//                         child: Text(
//                           message,
//                           style: TextStyle(
//                             color: message.contains('Success')
//                                 ? Colors.green
//                                 : Colors.red,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton.icon(
//                 icon: isSaving
//                     ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//                     : const Icon(Icons.save),
//                 label: Text(isSaving ? 'Saving...' : 'Save'),
//                 onPressed: isSaving
//                     ? null
//                     : () async {
//                   setStateSB(() => isSaving = true);
//
//                   final uri = Uri.parse(
//                       'http://192.168.0.202:8080/admin/video/${item['id']}');
//                   final request = html.HttpRequest();
//                   final formData = html.FormData();
//                   formData.append('title', titleCtrl.text);
//                   formData.append('subtitle', subtitleCtrl.text);
//                   formData.append('video_link', videoLinkCtrl.text);
//
//                   // If user selected new files
//                   if (newVideo != null) {
//                     formData.appendBlob('file', newVideo!, newVideo!.name);
//                   }
//                   if (newImage != null) {
//                     formData.appendBlob('image', newImage!, newImage!.name);
//                   }
//
//                   request.open('PATCH', uri.toString());
//                   request.onLoadEnd.listen((event) {
//                     setStateSB(() => isSaving = false);
//                     if (request.status == 200 || request.status == 201) {
//                       setStateSB(() => message = '✅ Success!');
//                       Future.delayed(const Duration(seconds: 2), () {
//                         Navigator.pop(ctx);
//                         _fetchVideos();
//                       });
//                     } else {
//                       setStateSB(() => message =
//                       '❌ Failed! ${request.status} ${request.statusText}');
//                     }
//                   });
//                   request.send(formData);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//
//   ///// delete Video
//   /// === Delete Function ===
//   void _deleteVideo(Map item) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Confirm Delete'),
//         content: Text('Are you sure you want to delete "${item['title']}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm != true) return;
//
//     try {
//       final uri =
//       Uri.parse('http://192.168.0.202:8080/admin/video/${item['id']}');
//       final request = html.HttpRequest();
//       request.open('DELETE', uri.toString());
//
//       request.onLoadEnd.listen((event) {
//         if (request.status == 200 || request.status == 204) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('✅ Video deleted successfully')),
//           );
//           _fetchVideos();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('❌ Delete failed: ${request.status}')),
//           );
//         }
//       });
//
//       request.send();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Error: $e')),
//       );
//     }
//   }
//
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
//       headingRowColor: MaterialStateProperty.all(Colors.green.shade100),
//       columns: [
//         const DataColumn(label: Text('Title')),
//         const DataColumn(label: Text('Filename')),
//         const DataColumn(label: Text('Video URL')),
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
//                 IconButton(
//                   icon: const Icon(Icons.edit, size: 20),
//                   tooltip: 'Edit Video',
//                   onPressed: () => _openEditPopup(item),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, size: 20, color: Colors.red),
//                   tooltip: 'Delete Video',
//                   onPressed: () => _deleteVideo(item),
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
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF00C853), Color(0xFF64DD17)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: const Text(
//                     'Welcome to your Admin Dashboard',
//                     style: TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
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

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Upload + List Demo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: const UploadPage(),
    );
  }
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});
  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<dynamic> _videosList = [];
 int _totalUniqueIps =0 ;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedRange = DateTimeRange(start: today, end: today);
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    try {
      final startDate =
          "${_selectedRange!.start.year}-${_selectedRange!.start.month.toString().padLeft(2, '0')}-${_selectedRange!.start.day.toString().padLeft(2, '0')}";
      final endDate =
          "${_selectedRange!.end.year}-${_selectedRange!.end.month.toString().padLeft(2, '0')}-${_selectedRange!.end.day.toString().padLeft(2, '0')}";
      final url =
          'http://192.168.0.202:8080/videos?start_date=$startDate&end_date=$endDate';

      final request = await html.HttpRequest.request(url, method: 'GET');
      if (request.status == 200) {
        final data = jsonDecode(request.responseText!);
        setState(() {
          _videosList = data['videos'] ?? [];
          _totalUniqueIps = data['total_unique_ips'] ?? 0;
        });
      } else {
        setState(() => _videosList = []);
      }
    } catch (e) {
      setState(() => _videosList = []);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2030, 12),
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
      _fetchVideos();
    }
  }

  void _openUploadPopup() {
    showDialog(
      context: context,
      builder: (ctx) => UploadPopup(onUploaded: () {
        Navigator.pop(ctx);
        _fetchVideos();
      }),
    );
  }

  /// === Edit Popup ===
  void _openEditPopup(Map item) {
    final TextEditingController titleCtrl =
    TextEditingController(text: item['title']?.toString() ?? '');
    final TextEditingController subtitleCtrl =
    TextEditingController(text: item['subtitle']?.toString() ?? '');
    final TextEditingController videoLinkCtrl =
    TextEditingController(text: item['video_link']?.toString() ?? '');

    html.File? newImage;
    html.File? newVideo;

    showDialog(
      context: context,
      builder: (ctx) {
        bool isSaving = false;
        String message = '';

        Future<void> pickFile(bool isImage) async {
          final input = html.FileUploadInputElement()
            ..accept = isImage ? 'image/*' : 'video/*';
          input.click();
          input.onChange.listen((event) {
            if (input.files!.isNotEmpty) {
              if (isImage) {
                newImage = input.files!.first;
              } else {
                newVideo = input.files!.first;
              }
            }
          });
        }

        return StatefulBuilder(
          builder: (ctx, setStateSB) => AlertDialog(
            title: Text('Edit Video (${item['id']})'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subtitleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle',
                        prefixIcon: Icon(Icons.subtitles),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: videoLinkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Video Link',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: Text(newImage == null
                          ? 'Change Image'
                          : 'Image: ${newImage!.name}'),
                      onPressed: () => pickFile(true),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.video_library),
                      label: Text(newVideo == null
                          ? 'Change Video File'
                          : 'Video: ${newVideo!.name}'),
                      onPressed: () => pickFile(false),
                    ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: message.contains('Success')
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: isSaving
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save),
                label: Text(isSaving ? 'Saving...' : 'Save'),
                onPressed: isSaving
                    ? null
                    : () async {
                  setStateSB(() => isSaving = true);

                  final uri = Uri.parse(
                      'http://192.168.0.202:8080/admin/video/${item['id']}');
                  final request = html.HttpRequest();
                  final formData = html.FormData();
                  formData.append('title', titleCtrl.text);
                  formData.append('subtitle', subtitleCtrl.text);
                  formData.append('video_link', videoLinkCtrl.text);

                  if (newVideo != null) {
                    formData.appendBlob(
                        'file', newVideo!, newVideo!.name);
                  }
                  if (newImage != null) {
                    formData.appendBlob(
                        'image', newImage!, newImage!.name);
                  }

                  request.open('PATCH', uri.toString());
                  request.onLoadEnd.listen((event) {
                    setStateSB(() => isSaving = false);
                    if (request.status == 200 ||
                        request.status == 201) {
                      setStateSB(() => message = '✅ Success!');
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(ctx);
                        _fetchVideos();
                      });
                    } else {
                      setStateSB(() => message =
                      '❌ Failed! ${request.status} ${request.statusText}');
                    }
                  });
                  request.send(formData);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteVideo(Map item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${item['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final uri =
      Uri.parse('http://192.168.0.202:8080/admin/video/${item['id']}');
      final request = html.HttpRequest();
      request.open('DELETE', uri.toString());

      request.onLoadEnd.listen((event) {
        if (request.status == 200 || request.status == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Video deleted successfully')),
          );
          _fetchVideos();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Delete failed: ${request.status}')),
          );
        }
      });

      request.send();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  void _showViewersPopup(Map item) {
    final viewers = (item['viewers'] ?? []) as List;
    List<String> ips = [];
    for (var v in viewers) {
      if (v is Map && v.containsKey('ip')) {
        ips.add(v['ip']);
      }
    }
    final uniqueIps = ips.toSet().toList();
    final popupWidth = MediaQuery.of(context).size.width * 0.5;
    final popupHeight = MediaQuery.of(context).size.height * 0.5;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Viewers IPs (${item['title']})'),
          content: SizedBox(
            width: popupWidth,
            height: popupHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Clicks: ${ips.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Unique IPs: ${uniqueIps.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: ips.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.public, size: 18),
                        title: Text('${index + 1} - ${ips[index]}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close')),
          ],
        );
      },
    );
  }

  Widget _buildVideoTable() {
    if (_videosList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No videos found'),
      );
    }
    // int totalClicksSum = 0;
    // int uniqueViewsSum = 0;
    // for (var item in _videosList) {
    //   totalClicksSum +=
    //       int.tryParse(item['unique_views']?.toString() ?? '0') ?? 0;
    //   uniqueViewsSum +=
    //       int.tryParse(item['unique_views']?.toString() ?? '0') ?? 0;
    // }
    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.green.shade100),
      columns: [
        const DataColumn(label: Text('Title')),
        const DataColumn(label: Text('Filename')),
        const DataColumn(label: Text('Video URL')),
        DataColumn(label: Text('Total Clicks ($_totalUniqueIps)')),
        DataColumn(label: Text('Total Ip ($_totalUniqueIps)')),
      ],
      rows: List<DataRow>.generate(_videosList.length, (index) {
        final item = _videosList[index];
        final title = item['title']?.toString() ?? '';
        final filename = item['original_filename']?.toString() ?? '';
        final videoUrl = item['video_url']?.toString() ??
            item['video_link']?.toString() ??
            '';
        final totalClicks = item['unique_views']?.toString() ?? '0';
        final uniqueViews = item['unique_views']?.toString() ?? '0';
        // === timestamps length হিসাব করা ===
        int ipCount = 0;
        if (item['viewers'] is List) {
          ipCount = (item['viewers'] as List).length;
        }
        int timestampsLength = 0;
        if (item['viewers'] is List) {
          for (var v in item['viewers']) {
            if (v is Map && v['timestamps'] is List) {
              timestampsLength += (v['timestamps'] as List).length;
            }
          }
        }

        return DataRow(
          color: MaterialStateProperty.all(
              index % 2 == 0 ? Colors.grey.shade50 : Colors.grey.shade200),
          cells: [
            DataCell(Text(title)),
            DataCell(Text(filename)),
            DataCell(
              InkWell(
                onTap: () {
                  if (videoUrl.isNotEmpty) {
                    html.window.open(videoUrl, '_blank');
                  }
                },
                child: Text(
                  videoUrl.isEmpty ? 'No Link' : 'Open',
                  style: TextStyle(
                      color: videoUrl.isEmpty ? Colors.grey : Colors.blue,
                      decoration: videoUrl.isEmpty
                          ? TextDecoration.none
                          : TextDecoration.underline),
                ),
              ),
            ),
            DataCell(Text(timestampsLength.toString())),
            DataCell(Row(
              children: [
                Text(ipCount.toString()),
                IconButton(
                  icon: const Icon(Icons.list, size: 20),
                  tooltip: 'Show IPs',
                  onPressed: () => _showViewersPopup(item),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit Video',
                  onPressed: () => _openEditPopup(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  tooltip: 'Delete Video',
                  onPressed: () => _deleteVideo(item),
                ),
              ],
            )),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startLabel =
        "${_selectedRange!.start.day}-${_selectedRange!.start.month}-${_selectedRange!.start.year}";
    final endLabel =
        "${_selectedRange!.end.day}-${_selectedRange!.end.month}-${_selectedRange!.end.year}";

    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       const Text('Video Upload ',
      //           style: TextStyle(fontWeight: FontWeight.bold)),
      //       const SizedBox(width: 20),
      //       TextButton.icon(
      //         icon: const Icon(Icons.upload, color: Colors.green),
      //         label: const Text('Upload',
      //             style: TextStyle(color: Colors.green)),
      //         onPressed: _openUploadPopup,
      //       ),
      //       const SizedBox(width: 20),
      //       ElevatedButton.icon(
      //         icon: const Icon(Icons.date_range),
      //         label: Text('Filter: $startLabel → $endLabel'),
      //         onPressed: _pickDateRange,
      //       ),
      //     ],
      //   ),
      // ),
      appBar: AppBar(
        centerTitle: true,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Video Upload ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                icon: const Icon(Icons.upload, color: Colors.green),
                label: const Text(
                  'Upload',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: _openUploadPopup,
              ),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                // icon: const Icon(Icons.date_range),
                label: Text('$startLabel → $endLabel'),
                onPressed: _pickDateRange,
              ),
            ],
          ),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF64DD17)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Welcome to your Admin Dashboard',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: _buildVideoTable(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ===================== Upload Popup =====================
class UploadPopup extends StatefulWidget {
  final VoidCallback onUploaded;
  const UploadPopup({super.key, required this.onUploaded});

  @override
  State<UploadPopup> createState() => _UploadPopupState();
}

class _UploadPopupState extends State<UploadPopup> {
  html.File? _imageFile;
  html.File? _videoFile;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  bool _isUploading = false;
  String _message = '';

  Future<void> _pickFile({required bool isImage}) async {
    final input = html.FileUploadInputElement()
      ..accept = isImage ? 'image/*' : 'video/*';
    input.click();
    input.onChange.listen((event) {
      if (input.files!.isNotEmpty) {
        setState(() {
          if (isImage) {
            _imageFile = input.files!.first;
          } else {
            _videoFile = input.files!.first;
          }
        });
      }
    });
  }

  Future<void> _uploadData() async {
    if (_titleController.text.isEmpty ||
        _videoLinkController.text.isEmpty ||
        _subtitleController.text.isEmpty ||
        _imageFile == null ||
        _videoFile == null) {
      setState(() => _message = '⚠️ Please fill all fields and choose files.');
      return;
    }

    setState(() {
      _isUploading = true;
      _message = '';
    });

    final uri = Uri.parse('http://192.168.0.202:8080/admin/upload');
    final request = html.HttpRequest();
    final formData = html.FormData();

    formData.append('title', _titleController.text);
    formData.appendBlob('file', _videoFile!, _videoFile!.name);
    formData.append('video_link', _videoLinkController.text);
    formData.append('subtitle', _subtitleController.text);
    formData.appendBlob('image', _imageFile!, _imageFile!.name);

    request.open('POST', uri.toString());
    request.withCredentials = false;

    request.onLoadEnd.listen((event) {
      setState(() {
        _isUploading = false;
      });
      if (request.status == 200 || request.status == 201) {
        setState(() => _message = '✅ Upload Success!');
        Future.delayed(const Duration(seconds: 2), () {
          widget.onUploaded();
        });
      } else if (request.status == 0) {
        setState(() =>
        _message =
        '⚠️ No response (CORS issue). Allow CORS on server.');
      } else {
        setState(() => _message =
        '❌ Upload failed! Status: ${request.status} ${request.statusText}');
      }
    });

      request.send(formData);
    }

        @override
        Widget build(BuildContext context) {
      final popupWidth = MediaQuery.of(context).size.width * 0.5;
      final popupHeight = MediaQuery.of(context).size.height * 0.5;

      return AlertDialog(
        insetPadding: const EdgeInsets.all(10),
        contentPadding: const EdgeInsets.all(20),
        title: const Text('Upload Your Video'),
        content: SizedBox(
          width: popupWidth,
          height: popupHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _videoLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Video Link URL',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle',
                    prefixIcon: Icon(Icons.subtitles),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: Text(_imageFile == null
                      ? 'Choose Image'
                      : 'Image: ${_imageFile!.name}'),
                  onPressed: () => _pickFile(isImage: true),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.video_library),
                  label: Text(_videoFile == null
                      ? 'Choose Video File'
                      : 'Video: ${_videoFile!.name}'),
                  onPressed: () => _pickFile(isImage: false),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    icon: _isUploading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      _isUploading ? 'Uploading...' : 'Submit',
                      style: const TextStyle(fontSize: 16),
                    ),
                    onPressed: _isUploading ? null : _uploadData,
                  ),
                ),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _message.contains('Success')
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      );
    }
  }

