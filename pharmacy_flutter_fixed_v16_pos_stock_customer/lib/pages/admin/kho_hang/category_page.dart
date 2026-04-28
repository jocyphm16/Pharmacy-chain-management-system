// lib/pages/admin/kho_hang/category_page.dart

import 'package:flutter/material.dart';
import 'category_detail_page.dart'; // Import trang chi tiết
import '../../../data/medicine_data.dart'; // THÊM IMPORT NÀY ĐỂ LẤY globalCategories

class CategoryTab extends StatefulWidget {
  const CategoryTab({Key? key}) : super(key: key);

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  // ĐÃ XÓA BIẾN _categories CỤC BỘ Ở ĐÂY VÀ SỬ DỤNG globalCategories TỪ DATA

  // Các biến quản lý trạng thái chọn để xóa nhiều
  bool _isSelectionMode = false;
  final Set<int> _selectedIndexes = {};

  // Hàm chuyển đổi trạng thái chọn của một item
  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
        if (_selectedIndexes.isEmpty) {
          _isSelectionMode = false; // Tắt chế độ chọn nếu bỏ chọn hết
        }
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  // Hộp thoại xác nhận xóa hàng loạt
  void _confirmDeleteSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa ${_selectedIndexes.length} danh mục đã chọn không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Sắp xếp index giảm dần để xóa không bị trượt index
                final sortedIndexes = _selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
                for (var i in sortedIndexes) {
                  globalCategories.removeAt(i); // Đổi thành globalCategories
                }
                _isSelectionMode = false;
                _selectedIndexes.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa các danh mục được chọn!'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('XÓA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Đổi giao diện AppBar nếu đang ở chế độ Chọn nhiều
        title: _isSelectionMode
            ? Text('${_selectedIndexes.length} mục đã chọn', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))
            : const Text('Danh mục sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: _isSelectionMode
            ? IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            setState(() {
              _isSelectionMode = false;
              _selectedIndexes.clear();
            });
          },
        )
            : null,
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
              onPressed: _confirmDeleteSelected,
            )
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? null // Ẩn nút Thêm khi đang ở chế độ xóa
          : FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        label: const Text('Thêm nhóm'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: globalCategories.length, // Đổi thành globalCategories
          itemBuilder: (context, index) {
            final cat = globalCategories[index]; // Đổi thành globalCategories
            final isSelected = _selectedIndexes.contains(index);

            return Card(
              elevation: isSelected ? 4 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                // Viền đỏ nếu đang được chọn
                side: BorderSide(color: isSelected ? Colors.redAccent : Colors.transparent, width: 2),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onLongPress: () {
                  // Bật chế độ chọn nhiều khi nhấn giữ
                  setState(() {
                    _isSelectionMode = true;
                    _selectedIndexes.add(index);
                  });
                },
                onTap: () async {
                  if (_isSelectionMode) {
                    _toggleSelection(index);
                  } else {
                    // CHUYỂN SANG TRANG CHI TIẾT
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailPage(categoryName: cat['name']),
                      ),
                    );

                    // Nếu bên trang chi tiết bấm Xóa thì hàm pop sẽ trả về true
                    if (result == true) {
                      setState(() {
                        globalCategories.removeAt(index); // Đổi thành globalCategories
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã xóa danh mục "${cat['name']}"'), backgroundColor: Colors.green),
                        );
                      }
                    }
                  }
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat['icon'], size: 40, color: isSelected ? Colors.redAccent : Colors.blueAccent),
                            const SizedBox(height: 12),
                            Text(
                              cat['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text('${cat['count']} loại', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    // Hiển thị Checkbox góc trên cùng khi ở chế độ chọn
                    if (_isSelectionMode)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? Colors.redAccent : Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController _categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo nhóm thuốc mới'),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'Tên danh mục',
            hintText: 'VD: Thuốc giảm đau...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (_categoryController.text.isNotEmpty) {
                setState(() {
                  globalCategories.add({ // Đổi thành globalCategories
                    'name': _categoryController.text,
                    'count': 0,
                    'icon': Icons.category_outlined,
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text('Thêm mới', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}