import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(
    GetMaterialApp(
      // Bind the controller cleanly at startup
      initialBinding: BindingsBuilder(() {
        Get.put(ListController());
      }),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

// ==========================================
// VIEW LAYER
// ==========================================

class Home extends GetView<ListController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
          onPressed: () => debugPrint('Back tapped!'),
        ),
        title: const Text("Node Switch"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => OutlinedButton.icon(
                    icon: Icon(
                      Icons.speed,
                      size: 20,
                      color: controller.isTesting.value
                          ? Colors.grey.shade600
                          : Colors.blue.shade600,
                    ),
                    label: const Text("Speed Test"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: controller.isTesting.value
                          ? Colors.grey.shade600
                          : Colors.blue.shade600,
                      side: BorderSide(
                        color: controller.isTesting.value
                            ? Colors.grey.shade300
                            : Colors.blue.shade300,
                      ),
                    ),
                    // Passing null automatically disables the button elegantly
                    onPressed: controller.isTesting.value
                        ? null
                        : controller.runSpeedTest,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "test date time:",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    Obx(
                      () => Text(
                        controller.lastTestTime.value.isEmpty
                            ? 'Never tested'
                            : controller.lastTestTime.value,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: controller.nodeList.length,
                itemBuilder: (context, i) => NodeTile(index: i),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy Results to Clipboard'),
                onPressed: controller.copyNodesToClipboard,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                "Refactored to enforce separation of concerns. UI stays dumb and pretty; logic stays smart and testable.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NodeTile extends GetView<ListController> {
  final int index;
  const NodeTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final node = controller.nodeList[index];
      final statusColor = node.isNormal
          ? Colors.green.shade400
          : Colors.red.shade400;

      return InkWell(
        onTap: () => controller.selectNode(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            children: [
              Text(
                node.name,
                style: TextStyle(
                  fontWeight: node.isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const Spacer(), // Replaces hardcoded spacing that breaks on small screens
              Icon(Icons.circle, size: 10, color: statusColor),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Text(
                  node.status,
                  style: TextStyle(color: statusColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (node.isSelected)
                const Icon(Icons.check, color: Colors.blue, size: 20)
              else
                const SizedBox(width: 20),
            ],
          ),
        ),
      );
    });
  }
}

// ==========================================
// CONTROLLER (STATE & LOGIC LAYER)
// ==========================================

class ListController extends GetxController {
  final RxList<Node> nodeList = <Node>[
    const Node(
      url: "https://www.google.com.hk",
      name: 'node01',
      status: "unknown",
    ),
    const Node(url: "https://hk.yahoo.com", name: 'node02', status: "unknown"),
    const Node(
      url: "http://bremsregelungen.xyz",
      name: 'node03',
      status: "unknown",
    ),
    const Node(url: "https://www.bing.com", name: 'node04', status: "unknown"),
    const Node(url: "https://1.1.1.1", name: 'node05', status: "unknown"),
    const Node(url: "https://8.8.8.8", name: 'node06', status: "unknown"),
    const Node(url: "https://www.baidu.com", name: 'node07', status: "unknown"),
    const Node(url: "https://www.apple.com", name: 'node08', status: "unknown"),
    const Node(url: "https://github.com", name: 'node09', status: "unknown"),
    const Node(
      url: "https://www.amazon.com",
      name: 'node10',
      status: "unknown",
    ),
    const Node(
      url: "https://www.microsoft.com",
      name: 'node11',
      status: "unknown",
    ),
    const Node(
      url: "https://www.wikipedia.org",
      name: 'node12',
      status: "unknown",
    ),
  ].obs;

  final RxBool isTesting = false.obs;
  final RxString lastTestTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    runSpeedTest(); // Correctly executes async on startup
  }

  Future<void> runSpeedTest() async {
    if (isTesting.value) return;
    isTesting.value = true;

    // 1. Reset all states to default values
    for (var i = 0; i < nodeList.length; i++) {
      nodeList[i] = nodeList[i].copyWith(status: 'unknown', isSelected: false);
    }

    // 2. Measure sequential latency
    for (var i = 0; i < nodeList.length; i++) {
      nodeList[i] = await _pingNode(nodeList[i]);
    }

    lastTestTime.value = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());
    isTesting.value = false;
  }

  Future<Node> _pingNode(Node node) async {
    final stopwatch = Stopwatch()..start();
    try {
      debugPrint("Pinging: ${node.url}");
      final uriParsed = Uri.parse(node.url);

      // Using HTTP HEAD instead of GET avoids downloading the payload
      await http.head(uriParsed).timeout(const Duration(seconds: 5));
      stopwatch.stop();

      return node.copyWith(
        status: "normal (${stopwatch.elapsedMilliseconds}ms)",
      );
    } catch (e) {
      debugPrint("Ping failed for ${node.url}: $e");
      stopwatch.stop();
      return node.copyWith(status: "abnormal");
    }
  }

  void selectNode(int selectedIdx) {
    final targetNode = nodeList[selectedIdx];
    if (!targetNode.isNormal || targetNode.isSelected) return;

    for (int i = 0; i < nodeList.length; i++) {
      nodeList[i] = nodeList[i].copyWith(isSelected: (i == selectedIdx));
    }
  }

  Future<void> copyNodesToClipboard() async {
    final String formattedString = nodeList
        .map((node) => '${node.name}: ${node.status}')
        .join('\n');

    await Clipboard.setData(ClipboardData(text: formattedString));

    Get.snackbar(
      'Copied',
      'Node status report copied to clipboard!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}

// ==========================================
// DATA MODEL LAYER
// ==========================================

@immutable
class Node {
  final String url;
  final String name;
  final String status;
  final bool isSelected;

  const Node({
    required this.url,
    required this.name,
    required this.status,
    this.isSelected = false,
  });

  // Business logic helper getters keeping the UI clean of Regex checks
  bool get isNormal => status.toLowerCase().startsWith('normal');
  bool get isUnknown => status.toLowerCase() == 'unknown';

  Node copyWith({String? url, String? name, String? status, bool? isSelected}) {
    return Node(
      url: url ?? this.url,
      name: name ?? this.name,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
