import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/features/delivery_route/data/models/extracted_order_info_model.dart';
import 'package:smgo/features/delivery_route/domain/entities/extracted_order_info_entity.dart';

class JsonImportBottomSheet extends StatefulWidget {
  const JsonImportBottomSheet({super.key});

  @override
  State<JsonImportBottomSheet> createState() => _JsonImportBottomSheetState();
}

class _JsonImportBottomSheetState extends State<JsonImportBottomSheet> {
  final TextEditingController _jsonController = TextEditingController(text: '');
  bool _isValid = false;
  String _errorMessage = '';
  List<ExtractedOrderInfoModel> _parsedOrders = [];

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  bool _validateItemMap(Map<String, dynamic> map) {
    const requiredKeys = [
      'orderCode',
      'orderName',
      'contactName',
      'contactPhone',
      'address',
    ];

    for (final key in requiredKeys) {
      if (!map.containsKey(key) || map[key] is! String) {
        return false;
      }
    }
    return true;
  }

  void _validateJson(String text) {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      setState(() {
        _isValid = false;
        _errorMessage = '';
        _parsedOrders = [];
      });
      return;
    }

    try {
      final parsed = jsonDecode(trimmedText);
      final List<ExtractedOrderInfoModel> tempList = [];

      if (parsed is List) {
        for (int i = 0; i < parsed.length; i++) {
          final item = parsed[i];
          if (item is Map<String, dynamic> && _validateItemMap(item)) {
            tempList.add(ExtractedOrderInfoModel.fromJson(item));
          } else {
            setState(() {
              _isValid = false;
              _errorMessage =
                  'Phần tử thứ ${i + 1} thiếu trường hoặc sai định dạng chuỗi.';
              _parsedOrders = [];
            });
            return;
          }
        }
      } else if (parsed is Map<String, dynamic>) {
        if (_validateItemMap(parsed)) {
          tempList.add(ExtractedOrderInfoModel.fromJson(parsed));
        } else {
          setState(() {
            _isValid = false;
            _errorMessage =
                'Dữ liệu thiếu các trường bắt buộc (orderCode, orderName, contactName, contactPhone, address)';
            _parsedOrders = [];
          });
          return;
        }
      } else {
        setState(() {
          _isValid = false;
          _errorMessage = 'Dữ liệu phải là danh sách [ ] hoặc đối tượng { }';
          _parsedOrders = [];
        });
        return;
      }

      setState(() {
        _isValid = true;
        _errorMessage = '';
        _parsedOrders = tempList
            .where(
              (order) =>
                  order.orderCode.isNotEmpty &&
                  order.contactName.isNotEmpty &&
                  order.contactPhone.isNotEmpty &&
                  order.address.isNotEmpty,
            )
            .toList();
      });
    } catch (e) {
      setState(() {
        _isValid = false;
        _errorMessage =
            'Cấu trúc JSON không hợp lệ. Vui lòng kiểm tra lại cú pháp.';
        _parsedOrders = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasInput = _jsonController.text.trim().isNotEmpty;
    final Color primaryColor = _isValid
        ? const Color(0xFF4CAF50)
        : (hasInput ? const Color(0xFFE53935) : const Color(0xFF4CAF50));

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nhập dữ liệu JSON',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              OutlinedButton(
                onPressed: () => _onGetPromptPressed(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lấy lệnh',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dán nội dung JSON chứa thông tin đơn hàng vào ô bên dưới.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // Textfield nhập JSON
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Dữ liệu JSON',
              labelStyle: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            child: Stack(
              children: [
                TextField(
                  controller: _jsonController,
                  maxLines: 8,
                  maxLength: 100000,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 8, right: 30),
                    counterStyle: TextStyle(color: Colors.grey),
                  ),
                  onChanged: _validateJson,
                ),
                if (hasInput)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: _isValid
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                      child: Icon(
                        _isValid ? Icons.check : Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Thông báo trạng thái Validation
          if (hasInput) ...[
            if (_isValid)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFF4CAF50),
                      child: Icon(Icons.check, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JSON hợp lệ',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Tìm thấy ${_parsedOrders.length} đơn hàng trong dữ liệu',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFFE53935),
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'JSON không hợp lệ',
                            style: TextStyle(
                              color: Color(0xFFC62828),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 24),

          // Các nút hành động
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isValid
                        ? () {
                            Navigator.pop(
                              context,
                              _parsedOrders
                                  .map(
                                    (
                                      extractedOrderInfoModel,
                                    ) => ExtractedOrderInfoEntity(
                                      orderCode:
                                          extractedOrderInfoModel.orderCode,
                                      orderName:
                                          extractedOrderInfoModel.orderName,
                                      contactName:
                                          extractedOrderInfoModel.contactName,
                                      contactPhone:
                                          extractedOrderInfoModel.contactPhone,
                                      address: extractedOrderInfoModel.address,
                                    ),
                                  )
                                  .toList(),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onGetPromptPressed(BuildContext context) async {
    const String prompt =
        '''Bạn là hệ thống trích xuất thông tin đơn hàng từ hình ảnh.

NHIỆM VỤ:
Đọc và trích xuất thông tin đơn hàng từ TẤT CẢ các ảnh được cung cấp.

Mỗi ảnh đầu vào tương ứng với ĐÚNG 1 item trong kết quả JSON.
KHÔNG được gộp, loại bỏ, bỏ qua hoặc deduplicate bất kỳ ảnh nào, kể cả khi nhiều ảnh có nội dung giống hệt nhau hoặc thông tin đơn hàng trùng lặp.

Với mỗi ảnh, trả về một object gồm chính xác các trường:

{
"orderCode": "mã vận đơn",
"orderName": "tên đơn hàng hoặc tên sản phẩm có trong đơn hàng",
"contactName": "tên người nhận hàng",
"contactPhone": "số điện thoại người nhận hàng",
"address": "địa chỉ người nhận hàng"
}

QUY TẮC TRÍCH XUẤT:

1. Mỗi ảnh = 1 object.

   * Nếu có 1 ảnh → trả về JSON array gồm 1 object.
   * Nếu có 3 ảnh → trả về JSON array gồm 3 object.
   * Nếu có N ảnh → bắt buộc trả về JSON array gồm đúng N object.
   * Số lượng object trong kết quả PHẢI bằng chính xác số lượng ảnh đầu vào.

2. Không được loại bỏ ảnh trùng.

   * Nếu ảnh 1 và ảnh 2 giống nhau → vẫn phải tạo 2 object.
   * Nếu 10 ảnh đều chứa cùng một đơn hàng → vẫn phải trả về 10 object.
   * Không được deduplicate dựa trên orderCode, nội dung, hình ảnh hoặc bất kỳ trường nào khác.

3. Mỗi object chỉ được lấy thông tin từ chính ảnh tương ứng.

   * Không lấy thông tin từ ảnh khác.
   * Không sử dụng thông tin của ảnh trước hoặc sau để bổ sung cho ảnh hiện tại.
   * Không suy đoán thông tin không xuất hiện trong ảnh.

4. Không được bịa thông tin.

   * Chỉ trích xuất những thông tin có thể xác định từ ảnh.
   * Nếu một trường không xuất hiện, không đọc được hoặc không thể xác định chắc chắn → dùng chuỗi rỗng "".
   * Tuyệt đối không tự tạo mã vận đơn, tên, số điện thoại hoặc địa chỉ.

5. orderCode:

   * Trích xuất mã vận đơn/mã đơn hàng/shipping code/order code nếu có.
   * Ưu tiên mã được xác định rõ là mã vận đơn.
   * Không tự suy đoán mã từ các con số không rõ ý nghĩa.

6. orderName:

   * Trích xuất tên đơn hàng hoặc tên sản phẩm có trong đơn hàng.
   * Nếu ảnh có nhiều sản phẩm, giữ đầy đủ tên các sản phẩm có thể đọc được trong một chuỗi.
   * Không tự đặt tên sản phẩm nếu ảnh không có thông tin.

7. contactName:

   * Trích xuất tên người nhận hàng.
   * Chỉ lấy tên người nhận, không nhầm với tên shop/người gửi/đơn vị vận chuyển.

8. contactPhone:

   * Trích xuất số điện thoại của người nhận.
   * Không tự sửa hoặc tạo số điện thoại.
   * Giữ nguyên số điện thoại theo nội dung nhìn thấy trong ảnh, ngoại trừ việc loại bỏ khoảng trắng/ký tự định dạng nếu cần để chuẩn hóa.

9. address:

   * Trích xuất đầy đủ địa chỉ người nhận có thể đọc được.
   * Giữ lại đầy đủ các thành phần như số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố nếu xuất hiện.
   * Không tự bổ sung địa chỉ còn thiếu dựa trên suy đoán.

10. OCR không chắc chắn:

* Nếu một phần thông tin khó đọc nhưng vẫn có thể xác định hợp lý từ hình ảnh → trích xuất phần đọc được.
* Nếu không thể xác định → để "".
* Không được thay thế bằng dữ liệu tưởng tượng.

11. Không được bỏ sót thông tin chỉ vì thông tin đó trùng lặp.

* Mỗi ảnh luôn phải có một object riêng.
* Hai object có thể hoàn toàn giống nhau và điều đó là hợp lệ.

12. Định dạng output:

* Chỉ trả về một JSON array hợp lệ.
* Không markdown.
* Không ```json.
* Không giải thích.
* Không thêm text trước hoặc sau JSON.
* Không thêm field ngoài 5 field: orderCode, orderName, contactName, contactPhone, address.
* Thứ tự field phải là: orderCode, orderName, contactName, contactPhone, address.

ĐỊNH DẠNG KẾT QUẢ BẮT BUỘC:

[
{
"orderCode": "",
"orderName": "",
"contactName": "",
"contactPhone": "",
"address": ""
}
]

KIỂM TRA TRƯỚC KHI TRẢ KẾT QUẢ:

* Đếm số lượng ảnh đầu vào.
* Tạo đúng một object cho từng ảnh.
* Kiểm tra số lượng object trong JSON phải bằng chính xác số lượng ảnh.
* Không deduplicate các object.
* Không bỏ qua ảnh bị trùng.
* Không thêm hoặc bớt object.
* Không bịa bất kỳ thông tin nào.
* Chỉ sau khi kiểm tra xong mới trả về JSON.

''';
    if (prompt.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: prompt));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã sao chép lệnh'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
