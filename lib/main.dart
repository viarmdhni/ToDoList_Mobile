import 'package:flutter/material.dart';

// Model class untuk Task = blueprint/template untuk objek Task
class Task {
  // Property untuk menyimpan judul task
  String title;
  // Property untuk menyimpan status selesai/belum
  bool isCompleted;

  // Constructor = function untuk membuat Task baru
  Task({
    // title wajib diisi (required)
    required this.title,
    // isCompleted opsional, default false (belum selesai)
    this.isCompleted = false,
  });

  // Method untuk toggle status completed (true ↔ false)
  void toggle() {
    // Flip boolean: true jadi false, false jadi true
    isCompleted = !isCompleted;
  }

  // Override toString untuk debug print yang readable
  @override
  String toString() {
    return 'Task{title: $title, isCompleted: $isCompleted}';
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App Pemula',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // State variables = data yang bisa berubah
  // List untuk menyimpan objek Task (bukan String lagi)
  List<Task> tasks = [];
  // Controller untuk mengontrol TextField (ambil text, clear, dll)
  TextEditingController taskController = TextEditingController();

  // Function addTask dengan validasi comprehensive dan feedback
  void addTask() {
    // Ambil dan bersihkan input text
    String newTaskTitle = taskController.text.trim();

    // Validasi 1: Cek apakah input kosong
    if (newTaskTitle.isEmpty) {
      // Tampilkan SnackBar warning untuk input kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Content dengan icon dan text
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Task tidak boleh kosong!'),
            ],
          ),
          // Styling SnackBar
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Stop execution jika gagal validasi
      return;
    }

    // Validasi 2: Cek task duplikat (case insensitive)
    bool isDuplicate = tasks.any((task) =>
        task.title.toLowerCase() == newTaskTitle.toLowerCase());

    if (isDuplicate) {
      // SnackBar untuk task duplikat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              // Expanded agar text tidak overflow
              Expanded(child: Text('Task "$newTaskTitle" sudah ada!')),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validasi 3: Cek panjang task maksimal 100 karakter
    if (newTaskTitle.length > 100) {
      // SnackBar untuk task terlalu panjang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Task terlalu panjang! Maksimal 100 karakter.')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Semua validasi passed - add task
    setState(() {
      Task newTask = Task(title: newTaskTitle);
      tasks.add(newTask);
    });

    // Clear input
    taskController.clear();

    // Success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Task "$newTaskTitle" berhasil ditambahkan!')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    debugPrint('Task ditambahkan: $newTaskTitle');
  }

  // Function async untuk menghapus task dengan konfirmasi dialog
  void removeTask(int index) async {
    // Simpan task yang akan dihapus untuk ditampilkan di dialog
    Task taskToDelete = tasks[index];

    // Tampilkan dialog konfirmasi dan tunggu response user
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      // Builder function untuk membuat content dialog
      builder: (BuildContext context) {
        // AlertDialog = popup konfirmasi
        return AlertDialog(
          // Title dialog dengan icon warning
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Konfirmasi Hapus'),
            ],
          ),
          // Content dialog
          content: Column(
            // Column sekecil mungkin
            mainAxisSize: MainAxisSize.min,
            // Align kiri
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text pertanyaan
              const Text('Apakah kamu yakin ingin menghapus task ini?'),
              const SizedBox(height: 12),
              // Container untuk preview task yang akan dihapus
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                // Preview task dalam tanda kutip
                child: Text(
                  '"${taskToDelete.title}"', // Akses .title property
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // Actions = tombol-tombol di bawah dialog
          actions: [
            // Tombol Batal
            TextButton(
              // Tutup dialog dan return false
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            // Tombol Hapus
            ElevatedButton(
              // Tutup dialog dan return true
              onPressed: () => Navigator.of(context).pop(true),
              // Styling button merah
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    // Cek apakah user pilih hapus (shouldDelete == true)
    if (shouldDelete == true) {
      setState(() {
        tasks.removeAt(index); // Hapus dari list
      });

      // Success feedback for delete - check if still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Task "${taskToDelete.title}" dihapus')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Debug print
      debugPrint('Task dihapus: ${taskToDelete.title}');
      debugPrint('Sisa tasks: ${tasks.length}');
    } else {
      debugPrint('Delete dibatalkan');
    }
  }

  // Function untuk toggle status completed
  void toggleTask(int index) {
    setState(() {
      tasks[index].toggle(); // Pakai method toggle dari Task class
    });

    Task task = tasks[index];
    String message = task.isCompleted
        ? 'Selamat! Task "${task.title}" selesai! 🎉'
        : 'Task "${task.title}" ditandai belum selesai';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.celebration : Icons.undo,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: task.isCompleted ? Colors.green : Colors.blue,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    debugPrint('Task ${task.isCompleted ? "completed" : "uncompleted"}: ${task.title}');
  }

  @override
  void dispose() {
    // Dispose controller untuk menghindari memory leak
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: const Color.fromARGB(255, 201, 156, 173),
      ),
      // Body halaman dengan padding di semua sisi
      body: Padding(
        // Jarak 16 pixel dari semua tepi layar
        padding: const EdgeInsets.all(16.0),
        // Column = susun widget anak secara vertikal
        child: Column(
          // Daftar widget yang disusun vertikal
          children: [
            // Container = kotak untuk styling dan layout
            Container(
              // Padding di dalam container
              padding: const EdgeInsets.all(16.0),
              // Dekorasi container (warna, bentuk, dll)
              decoration: BoxDecoration(
                // Warna background abu-abu terang
                color: Colors.grey[100],
                // Sudut melengkung dengan radius 12 pixel
                borderRadius: BorderRadius.circular(12.0),
              ),
              // Isi container
              child: Column(
                // Daftar widget di dalam container
                children: [
                  // TextField = input field yang bisa diketik user
                  TextField(
                    // Controller untuk mengontrol TextField
                    controller: taskController,
                    textCapitalization: TextCapitalization.sentences, // Auto capitalize
                    maxLength: 100, // Limit input length
                    // Styling dan decorasi input field
                    decoration: InputDecoration(
                      // Text yang muncul saat input kosong
                      hintText: 'Ketik task baru di sini...',
                      // Border outline di sekitar input
                      border: OutlineInputBorder(
                        // Sudut border melengkung
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      // Icon di sebelah kiri input
                      prefixIcon: const Icon(Icons.edit),
                      counterText: '', // Hide character counter
                      helperText: 'Maksimal 100 karakter', // Helper text
                    ),
                    onSubmitted: (value) => addTask(), // Enter key also adds task
                  ),
                  // Jarak kosong vertikal 12 pixel
                  const SizedBox(height: 12),
                  // SizedBox untuk mengatur lebar button
                  SizedBox(
                    // Button ambil lebar penuh container
                    width: double.infinity,
                    // Button dengan efek elevasi
                    child: ElevatedButton(
                      // Function yang dijalankan saat button ditekan
                      onPressed: addTask,
                      // Styling button
                      style: ElevatedButton.styleFrom(
                        // Warna background button
                        backgroundColor: const Color.fromARGB(255, 201, 156, 173),
                        // Warna text/icon button
                        foregroundColor: Colors.white,
                        // Padding atas-bawah 15 pixel
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        // Bentuk button dengan sudut bulat
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      // Isi button
                      child: const Text(
                        'Add Task',
                        // Styling text: ukuran 16, tebal
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Jarak vertikal setelah form
            const SizedBox(height: 20),

            // Text counter untuk menampilkan jumlah tasks
            Text(
              'Total Tasks: ${tasks.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            // Jarak vertikal sebelum area list
            const SizedBox(height: 20),
            // Expanded mengambil sisa ruang yang tersedia di Column
            Expanded(
              // Container untuk styling area list
              child: Container(
                // Lebar penuh
                width: double.infinity,
                // Padding di dalam container
                padding: const EdgeInsets.all(16),
                // Dekorasi container: border dan border radius
                decoration: BoxDecoration(
                  // Border abu-abu di sekeliling
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  // Sudut melengkung
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // Conditional rendering: tampil berbeda jika kosong vs ada isi
                child: tasks.isEmpty
                    ? // Tampilan jika list kosong
                      Center(
                        // Column untuk susun icon dan text vertikal
                        child: Column(
                          // Center semua content di tengah
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon inbox kosong
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            // Jarak vertikal
                            const SizedBox(height: 16),
                            // Text utama
                            Text(
                              'Belum ada task',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            // Jarak kecil
                            const SizedBox(height: 8),
                            // Text penjelasan
                            Text(
                              'Tambahkan task pertamamu di atas!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : // Tampilan jika ada tasks: ListView untuk scroll
                      ListView.builder(
                        // Jumlah item yang akan dibuat
                        itemCount: tasks.length,
                        // Function yang dipanggil untuk membuat setiap item
                        itemBuilder: (context, index) {
                          Task task = tasks[index]; // Ambil Task object

                          return Padding(
                            // Jarak bawah antar item
                            padding: const EdgeInsets.only(bottom: 8.0),
                            // Container untuk styling setiap item
                            child: Container(
                              // Dekorasi container berubah berdasarkan status
                              decoration: BoxDecoration(
                                // Background berubah berdasarkan status
                                color: task.isCompleted ? Colors.green[50] : Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: task.isCompleted
                                    ? Border.all(color: Colors.green[200]!, width: 2) // Border hijau jika selesai
                                    : null,
                                // Shadow untuk efek elevated
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Opacity(
                                opacity: task.isCompleted ? 0.7 : 1.0, // Completed task lebih transparan
                                // ListTile dengan design yang lebih baik
                                child: ListTile(
                                  // Leading: container custom untuk nomor urut atau check icon
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    // Dekorasi berubah berdasarkan status
                                    decoration: BoxDecoration(
                                      color: task.isCompleted ? Colors.green[100] : Colors.blue[100],
                                      shape: BoxShape.circle,
                                    ),
                                    // Center nomor urut atau check icon di tengah container
                                    child: Center(
                                      child: task.isCompleted
                                          ? Icon(Icons.check, color: Colors.green[700]) // Icon check jika selesai
                                          : Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                  ),
                                  // Title dengan styling conditional
                                  title: Text(
                                    task.title, // Akses .title dari Task object
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: task.isCompleted ? Colors.grey[600] : Colors.black87,
                                      // STRIKETHROUGH untuk completed task
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  // Subtitle dengan status yang jelas
                                  subtitle: Text(
                                    task.isCompleted ? 'Selesai ✅' : 'Belum selesai',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: task.isCompleted ? Colors.green[600] : Colors.grey[600],
                                    ),
                                  ),
                                  // Trailing: area di kanan ListTile untuk icons
                                  trailing: Row(
                                    // Row sekecil mungkin, tidak ambil space berlebihan
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // CHECKBOX untuk toggle complete
                                      IconButton(
                                        icon: Icon(
                                          task.isCompleted
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: task.isCompleted ? Colors.green[600] : Colors.grey[400],
                                        ),
                                        onPressed: () => toggleTask(index),
                                        tooltip: task.isCompleted
                                            ? 'Mark as incomplete'
                                            : 'Mark as complete',
                                      ),
                                      // Jarak antara toggle dan delete button
                                      const SizedBox(width: 8),
                                      // Button untuk delete task
                                      IconButton(
                                        // Icon tempat sampah
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red[400],
                                        ),
                                        // Action saat button ditekan
                                        onPressed: () => removeTask(index),
                                        // Tooltip yang muncul saat long press
                                        tooltip: 'Hapus task',
                                      ),
                                    ],
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}