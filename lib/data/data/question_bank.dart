import '../models/question.dart';
import '../models/quiz_settings.dart';

/// The app's local question bank. No database or network request is used.
abstract final class QuestionBank {
  static const List<Question> all = <Question>[
    // ---------------------------------------------------------------------
    // Flutter
    // ---------------------------------------------------------------------
    Question(
      id: 'flutter-01',
      category: QuizCategory.flutter,
      prompt:
          'Widget apa yang menyusun anak-anaknya secara vertikal dari atas ke bawah?',
      options: <String>['Row', 'Column', 'Stack', 'Wrap'],
      correctIndex: 1,
      explanation:
          'Column adalah widget Flex dengan arah vertikal. Row menyusun anak secara horizontal, sedangkan Stack menumpuk anak di atas anak lain.',
    ),
    Question(
      id: 'flutter-02',
      category: QuizCategory.flutter,
      prompt: 'Manakah pernyataan yang paling tepat tentang StatelessWidget?',
      options: <String>[
        'Widget yang menyimpan data yang berubah selama aplikasi berjalan',
        'Widget immutable yang tidak memiliki state internal yang berubah',
        'Widget yang hanya boleh digunakan di halaman pertama',
        'Widget yang selalu membangun ulang dirinya setiap detik',
      ],
      correctIndex: 1,
      explanation:
          'StatelessWidget tidak memiliki state yang bisa berubah. Jika data yang ditampilkan berubah, widget baru akan dibuat dengan konfigurasi baru.',
    ),
    Question(
      id: 'flutter-03',
      category: QuizCategory.flutter,
      prompt:
          'Method apa yang dipanggil di dalam State untuk memberi tahu Flutter bahwa data berubah dan UI perlu dibangun ulang?',
      options: <String>['initState()', 'build()', 'setState()', 'dispose()'],
      correctIndex: 2,
      explanation:
          'setState() menjadwalkan rebuild pada State terkait. initState() dipanggil sekali saat State dibuat dan dispose() saat State dibuang.',
    ),
    Question(
      id: 'flutter-04',
      category: QuizCategory.flutter,
      prompt:
          'Apa keuntungan utama menggunakan constructor const pada widget?',
      options: <String>[
        'Widget otomatis menjadi StatefulWidget',
        'Instance dapat dibuat saat compile-time dan dipakai ulang secara efisien',
        'Widget tidak perlu memiliki build method',
        'Semua state di dalam widget menjadi permanen',
      ],
      correctIndex: 1,
      explanation:
          'Widget const dibuat sekali secara canonical saat compile-time. Flutter dapat melewati rebuild jika instance serta konfigurasinya sama.',
    ),
    Question(
      id: 'flutter-05',
      category: QuizCategory.flutter,
      prompt: 'Widget Expanded hanya boleh digunakan di dalam ...',
      options: <String>[
        'Container atau Padding',
        'Row, Column, atau Flex',
        'Stack atau Positioned',
        'ListView atau GridView',
      ],
      correctIndex: 1,
      explanation:
          'Expanded menggunakan ruang yang tersisa pada Flex. Karena itu ia harus menjadi descendant langsung dari Row, Column, atau Flex.',
    ),
    Question(
      id: 'flutter-06',
      category: QuizCategory.flutter,
      prompt: 'Apa kegunaan utama LayoutBuilder?',
      options: <String>[
        'Menyimpan data ke penyimpanan lokal',
        'Memberi akses ke constraints induk saat widget dibangun',
        'Mengubah warna tema secara otomatis',
        'Menambahkan animasi pada semua widget anak',
      ],
      correctIndex: 1,
      explanation:
          'LayoutBuilder membangun ulang widget berdasarkan BoxConstraints dari induknya. Ini berguna untuk layout responsif dan adaptif.',
    ),
    Question(
      id: 'flutter-07',
      category: QuizCategory.flutter,
      prompt:
          'Widget mana yang paling efisien untuk menampilkan daftar panjang karena hanya membangun item yang terlihat?',
      options: <String>[
        'Column',
        'SingleChildScrollView',
        'ListView.builder',
        'Stack',
      ],
      correctIndex: 2,
      explanation:
          'ListView.builder membuat item secara lazy sesuai viewport. Column dengan banyak anak membangun semuanya sekaligus.',
    ),
    Question(
      id: 'flutter-08',
      category: QuizCategory.flutter,
      prompt: 'Di file mana aset gambar dan font kustom didaftarkan?',
      options: <String>[
        'main.dart',
        'pubspec.yaml',
        'analysis_options.yaml',
        'android/app/build.gradle',
      ],
      correctIndex: 1,
      explanation:
          'Bagian flutter pada pubspec.yaml mendeklarasikan folder assets serta daftar font beserta file dan beratnya.',
    ),
    Question(
      id: 'flutter-09',
      category: QuizCategory.flutter,
      prompt: 'Apa fungsi MediaQuery.sizeOf(context)?',
      options: <String>[
        'Mengambil ukuran layar dan ikut membangun ulang saat ukurannya berubah',
        'Menghitung jumlah widget di dalam tree',
        'Menyimpan ukuran layar secara permanen',
        'Mengubah orientasi perangkat secara otomatis',
      ],
      correctIndex: 0,
      explanation:
          'sizeOf hanya mendengarkan perubahan ukuran sehingga lebih efisien daripada MediaQuery.of(context) yang bergantung pada seluruh MediaQueryData.',
    ),
    Question(
      id: 'flutter-10',
      category: QuizCategory.flutter,
      prompt:
          'Apa yang umumnya terjadi pada State ketika perangkat dirotasi dari portrait ke landscape?',
      options: <String>[
        'State langsung dihapus dan dibuat ulang dari nol',
        'State dipertahankan, lalu build dijalankan ulang dengan constraints baru',
        'Aplikasi wajib ditutup dan dibuka kembali',
        'Semua variabel di dalam State otomatis menjadi null',
      ],
      correctIndex: 1,
      explanation:
          'Perubahan orientasi memicu rebuild dengan ukuran baru. Object State tetap dipertahankan, sehingga nilai seperti jawaban dan indeks soal tidak hilang.',
    ),

    // ---------------------------------------------------------------------
    // Dart
    // ---------------------------------------------------------------------
    Question(
      id: 'dart-01',
      category: QuizCategory.dart,
      prompt:
          'Kata kunci apa yang digunakan untuk variabel yang nilainya tidak dapat diubah setelah diinisialisasi?',
      options: <String>['var', 'final', 'dynamic', 'static'],
      correctIndex: 1,
      explanation:
          'final menetapkan nilai satu kali saat runtime. Untuk nilai yang sudah diketahui saat compile-time, gunakan const.',
    ),
    Question(
      id: 'dart-02',
      category: QuizCategory.dart,
      prompt: 'Future<void> dalam Dart merepresentasikan ...',
      options: <String>[
        'Nilai yang selalu selesai secara sinkron',
        'Hasil operasi asynchronous yang tidak mengembalikan nilai',
        'Daftar angka yang tidak dapat diubah',
        'Class untuk membuat tampilan Flutter',
      ],
      correctIndex: 1,
      explanation:
          'Future<void> adalah Future yang hasil akhirnya tidak memiliki nilai. Contohnya operasi menyimpan data yang hanya perlu diketahui berhasil atau gagal.',
    ),
    Question(
      id: 'dart-03',
      category: QuizCategory.dart,
      prompt: 'Apa fungsi await di dalam fungsi async?',
      options: <String>[
        'Menghentikan seluruh aplikasi sampai Future selesai',
        'Menunggu Future selesai sebelum melanjutkan baris berikutnya',
        'Mengubah Future menjadi List',
        'Membuat fungsi berjalan di isolate baru',
      ],
      correctIndex: 1,
      explanation:
          'await menunda kelanjutan fungsi async hingga Future selesai tanpa memblokir event loop. Fungsi lain tetap dapat berjalan.',
    ),
    Question(
      id: 'dart-04',
      category: QuizCategory.dart,
      prompt: 'Operator cascade (..) digunakan untuk ...',
      options: <String>[
        'Membandingkan dua object',
        'Memanggil beberapa anggota pada object yang sama tanpa mengulang namanya',
        'Menggabungkan dua List',
        'Mengubah object menjadi JSON',
      ],
      correctIndex: 1,
      explanation:
          'Cascade memungkinkan beberapa operasi pada object yang sama, misalnya paint..color = ... ..strokeWidth = ..., dan mengembalikan object aslinya.',
    ),
    Question(
      id: 'dart-05',
      category: QuizCategory.dart,
      prompt: 'Apa arti tanda tanya pada deklarasi String? nama?',
      options: <String>[
        'Variabel wajib memiliki nilai',
        'Variabel boleh bernilai null',
        'Variabel hanya dapat diisi satu karakter',
        'Variabel bersifat konstan',
      ],
      correctIndex: 1,
      explanation:
          'Tanda ? menandakan tipe nullable. Dengan null safety, String? boleh berisi String atau null, sedangkan String harus selalu berisi nilai.',
    ),
    Question(
      id: 'dart-06',
      category: QuizCategory.dart,
      prompt: 'Apa kegunaan kata kunci late pada sebuah field?',
      options: <String>[
        'Menunda inisialisasi sampai field pertama kali diakses',
        'Membuat field dapat diakses dari mana saja',
        'Menjalankan field di background isolate',
        'Menghapus field setelah satu detik',
      ],
      correctIndex: 0,
      explanation:
          'late memungkinkan variabel non-nullable diinisialisasi setelah deklarasi. Jika diakses sebelum diberi nilai, akan terjadi LateInitializationError.',
    ),
    Question(
      id: 'dart-07',
      category: QuizCategory.dart,
      prompt: 'Mixin digunakan untuk ...',
      options: <String>[
        'Membagikan implementasi ke beberapa class tanpa inheritance tunggal',
        'Membuat database lokal',
        'Mendeklarasikan widget Flutter',
        'Mengganti seluruh isi class induk',
      ],
      correctIndex: 0,
      explanation:
          'Mixin memungkinkan kode dipakai ulang pada banyak class tanpa hierarki inheritance. Contohnya mixin SingleTickerProviderStateMixin pada animasi.',
    ),
    Question(
      id: 'dart-08',
      category: QuizCategory.dart,
      prompt: 'Apa hasil dari [1, 2, 3].map((e) => e * 2).toList()?',
      options: <String>['[1, 2, 3]', '[2, 4, 6]', '[1, 4, 9]', '[6, 4, 2]'],
      correctIndex: 1,
      explanation:
          'map menerapkan fungsi pada setiap elemen. Setiap angka dikalikan dua sehingga hasilnya [2, 4, 6].',
    ),
    Question(
      id: 'dart-09',
      category: QuizCategory.dart,
      prompt: 'Apa perbedaan utama List<int> dan Set<int>?',
      options: <String>[
        'List hanya untuk angka, Set untuk semua tipe',
        'List terurut dan boleh duplikat, Set tidak memiliki duplikat',
        'Set selalu lebih cepat untuk semua operasi',
        'List tidak dapat diubah isinya',
      ],
      correctIndex: 1,
      explanation:
          'List mempertahankan urutan dan mengizinkan nilai duplikat. Set menyimpan elemen unik sehingga duplikat otomatis diabaikan.',
    ),
    Question(
      id: 'dart-10',
      category: QuizCategory.dart,
      prompt: 'Constructor User.fromJson(...) disebut sebagai ...',
      options: <String>[
        'Default constructor',
        'Named constructor',
        'Factory mixin',
        'Extension constructor',
      ],
      correctIndex: 1,
      explanation:
          'Named constructor memberi nama alternatif untuk membuat object, misalnya User.fromJson untuk membangun object dari data JSON.',
    ),

    // ---------------------------------------------------------------------
    // General knowledge
    // ---------------------------------------------------------------------
    Question(
      id: 'umum-01',
      category: QuizCategory.general,
      prompt: 'Planet terbesar di tata surya adalah ...',
      options: <String>['Saturnus', 'Jupiter', 'Neptunus', 'Bumi'],
      correctIndex: 1,
      explanation:
          'Jupiter adalah planet terbesar dengan diameter sekitar 11 kali diameter Bumi. Saturnus berada di urutan kedua.',
    ),
    Question(
      id: 'umum-02',
      category: QuizCategory.general,
      prompt: 'Lambang unsur kimia untuk emas adalah ...',
      options: <String>['Ag', 'Au', 'Fe', 'Cu'],
      correctIndex: 1,
      explanation:
          'Au berasal dari kata Latin aurum yang berarti emas. Ag adalah perak, Fe besi, dan Cu tembaga.',
    ),
    Question(
      id: 'umum-03',
      category: QuizCategory.general,
      prompt: 'Benua terluas di dunia adalah ...',
      options: <String>['Afrika', 'Amerika Utara', 'Asia', 'Eropa'],
      correctIndex: 2,
      explanation:
          'Asia merupakan benua terluas dengan sekitar 44 juta kilometer persegi, jauh di atas benua lainnya.',
    ),
    Question(
      id: 'umum-04',
      category: QuizCategory.general,
      prompt: 'Ibu kota Jepang adalah ...',
      options: <String>['Osaka', 'Kyoto', 'Tokyo', 'Nagoya'],
      correctIndex: 2,
      explanation:
          'Tokyo adalah ibu kota Jepang sekaligus wilayah metropolitan terbesar di dunia. Kyoto pernah menjadi ibu kota pada masa lalu.',
    ),
    Question(
      id: 'umum-05',
      category: QuizCategory.general,
      prompt:
          'Alat musik tradisional Sunda yang terbuat dari bambu dan dimainkan dengan cara digoyangkan adalah ...',
      options: <String>['Angklung', 'Gamelan', 'Sasando', 'Kolintang'],
      correctIndex: 0,
      explanation:
          'Angklung tersusun dari tabung bambu yang bergetar saat digoyangkan. Sasando berasal dari Nusa Tenggara Timur dan Kolintang dari Sulawesi Utara.',
    ),
    Question(
      id: 'umum-06',
      category: QuizCategory.general,
      prompt: 'Organ tubuh yang bertugas memompa darah ke seluruh tubuh adalah ...',
      options: <String>['Paru-paru', 'Ginjal', 'Jantung', 'Hati'],
      correctIndex: 2,
      explanation:
          'Jantung memompa darah melalui pembuluh darah. Paru-paru menukar oksigen, ginjal menyaring darah, dan hati mengolah zat gizi.',
    ),
    Question(
      id: 'umum-07',
      category: QuizCategory.general,
      prompt: 'Bahasa pemrograman Python pertama kali dibuat oleh ...',
      options: <String>[
        'James Gosling',
        'Guido van Rossum',
        'Dennis Ritchie',
        'Bjarne Stroustrup',
      ],
      correctIndex: 1,
      explanation:
          'Guido van Rossum merilis Python pada awal 1990-an. James Gosling dikenal lewat Java, Dennis Ritchie lewat C, dan Bjarne Stroustrup lewat C++.',
    ),
    Question(
      id: 'umum-08',
      category: QuizCategory.general,
      prompt: 'Indonesia memproklamasikan kemerdekaannya pada tahun ...',
      options: <String>['1908', '1928', '1945', '1949'],
      correctIndex: 2,
      explanation:
          'Proklamasi kemerdekaan dibacakan pada 17 Agustus 1945. Tahun 1908 adalah awal Kebangkitan Nasional dan 1928 adalah Sumpah Pemuda.',
    ),
    Question(
      id: 'umum-09',
      category: QuizCategory.general,
      prompt: 'Satelit alami yang mengorbit Bumi adalah ...',
      options: <String>['Matahari', 'Bulan', 'Mars', 'Venus'],
      correctIndex: 1,
      explanation:
          'Bulan adalah satu-satunya satelit alami Bumi. Matahari adalah bintang, sedangkan Mars dan Venus adalah planet.',
    ),
    Question(
      id: 'umum-10',
      category: QuizCategory.general,
      prompt: 'Jumlah pemain inti dalam satu tim sepak bola adalah ...',
      options: <String>['9 orang', '10 orang', '11 orang', '12 orang'],
      correctIndex: 2,
      explanation:
          'Satu tim menurunkan 11 pemain inti, termasuk satu penjaga gawang. Pemain pengganti tidak dihitung sebagai pemain inti.',
    ),
  ];

  static const int total = 30;

  static List<Question> forCategory(QuizCategory? category) {
    if (category == null) return List<Question>.of(all);
    return all.where((question) => question.category == category).toList();
  }

  static int countFor(QuizCategory? category) => forCategory(category).length;
}
