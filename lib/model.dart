// class ApiResponse {
//   final bool success;
//   final int statusCode;
//   final String message;
//   final List<UrlData> data;
//
//   ApiResponse({
//     required this.success,
//     required this.statusCode,
//     required this.message,
//     required this.data,
//   });
//
//   factory ApiResponse.fromJson(Map<String, dynamic> json) {
//     return ApiResponse(
//       success: json['success'],
//       statusCode: json['statusCode'],
//       message: json['message'],
//       data: (json['data'] as List)
//           .map((item) => UrlData.fromJson(item))
//           .toList(),
//     );
//   }
// }
//
// class UrlData {
//   final String id;
//   final String url;
//   final String userName;
//   final DateTime createdAt;
//   final int hitCount;
//   final List<AccessLog> accessLogs;
//   final List<IpClick> ipClicks;
//   final String imageUrl;
//   final bool hasImage;
//   final DateTime? updatedAt;
//
//   UrlData({
//     required this.id,
//     required this.url,
//     required this.userName,
//     required this.createdAt,
//     required this.hitCount,
//     required this.accessLogs,
//     required this.ipClicks,
//     required this.imageUrl,
//     required this.hasImage,
//     this.updatedAt,
//   });
//
//   factory UrlData.fromJson(Map<String, dynamic> json) {
//     return UrlData(
//       id: json['_id'],
//       url: json['url'],
//       userName: json['user_name'],
//       createdAt: DateTime.parse(json['created_at']),
//       hitCount: json['hit_count'],
//       accessLogs: json['access_logs'] != null
//           ? (json['access_logs'] as List)
//           .map((log) => AccessLog.fromJson(log))
//           .toList()
//           : [],
//       ipClicks: json['ip_clicks'] != null
//           ? (json['ip_clicks'] as List)
//           .map((click) => IpClick.fromJson(click))
//           .toList()
//           : [],
//       imageUrl: json['image_url'],
//       hasImage: json['has_image'],
//       updatedAt: json['updated_at'] != null
//           ? DateTime.parse(json['updated_at']['\$date'])
//           : null,
//     );
//   }
// }
//
// class AccessLog {
//   final String ip;
//   final DateTime timestamp;
//
//   AccessLog({
//     required this.ip,
//     required this.timestamp,
//   });
//
//   factory AccessLog.fromJson(Map<String, dynamic> json) {
//     return AccessLog(
//       ip: json['ip'],
//       timestamp: DateTime.parse(json['timestamp']['\$date']),
//     );
//   }
// }
//
// class IpClick {
//   final String ip;
//   final String date;
//   final int count;
//
//   IpClick({
//     required this.ip,
//     required this.date,
//     required this.count,
//   });
//
//   factory IpClick.fromJson(Map<String, dynamic> json) {
//     return IpClick(
//       ip: json['ip'],
//       date: json['date'],
//       count: json['count'],
//     );
//   }
// }
//
//
//


class ApiResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<UrlData> data;

  ApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
          ?.map((item) => UrlData.fromJson(item))
          .toList() ?? [],
    );
  }
}

class UrlData {
  final String id;
  final String url;
  final String userName;
  final DateTime createdAt;
  final int hitCount;
  final List<AccessLog> accessLogs;
  final List<IpClick> ipClicks;
  final String imageUrl;
  final bool hasImage;

  UrlData({
    required this.id,
    required this.url,
    required this.userName,
    required this.createdAt,
    required this.hitCount,
    required this.accessLogs,
    required this.ipClicks,
    required this.imageUrl,
    required this.hasImage,
  });

  factory UrlData.fromJson(Map<String, dynamic> json) {
    return UrlData(
      id: json['_id'] ?? '',
      url: json['url'] ?? '',
      userName: json['user_name'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      hitCount: json['hit_count'] ?? 0,
      accessLogs: (json['access_logs'] as List?)
          ?.map((log) => AccessLog.fromJson(log))
          .toList() ?? [],
      ipClicks: (json['ip_clicks'] as List?)
          ?.map((click) => IpClick.fromJson(click))
          .toList() ?? [],
      imageUrl: json['image_url'] ?? '',
      hasImage: json['has_image'] ?? false,
    );
  }
}

class AccessLog {
  final String ip;
  final DateTime timestamp;

  AccessLog({
    required this.ip,
    required this.timestamp,
  });

  factory AccessLog.fromJson(Map<String, dynamic> json) {
    return AccessLog(
      ip: json['ip'] ?? '',
      timestamp: DateTime.parse(json['timestamp']['\$date']),
    );
  }
}

class IpClick {
  final String ip;
  final String date;
  final int count;
  final DateTime latestClickTime;

  IpClick({
    required this.ip,
    required this.date,
    required this.count,
    required this.latestClickTime,
  });

  factory IpClick.fromJson(Map<String, dynamic> json) {
    return IpClick(
      ip: json['ip'] ?? '',
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
      latestClickTime: DateTime.parse(json['latest_click_time']),
    );
  }
}