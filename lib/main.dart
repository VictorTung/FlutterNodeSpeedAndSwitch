import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(
    GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
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
          icon: const Icon(Icons.arrow_back_ios_new_sharp, size: 18),
          onPressed: () => debugPrint('Back tapped!'),
        ),
        title: const Text(
          "節點切換",
          style: TextStyle(fontWeight: FontWeight(500), fontSize: 16),
        ),
      ),
      body: Container(
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
                      size: 16,
                      color: controller.isTesting.value
                          ? Colors.grey.shade600
                          : Colors.blue.shade600,
                    ),
                    label: const Text("手動測速"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: controller.isTesting.value
                          ? Colors.grey.shade600
                          : Colors.blue.shade600,
                      side: BorderSide(
                        color: controller.isTesting.value
                            ? Colors.grey.shade300
                            : Colors.blue.shade300,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: controller.isTesting.value
                        ? null
                        : controller.runSpeedTest,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "測速時間",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.lastTestTime.value.isEmpty
                            ? 'Never tested'
                            : controller.lastTestTime.value,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                        ),
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
              child: Obx(
                () => FilledButton.icon(
                  label: const Text(
                    '複製測速結果',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  onPressed: controller.isTesting.value
                      ? null
                      : controller.copyNodesToClipboard,
                  style: FilledButton.styleFrom(
                    backgroundColor: controller.isTesting.value
                        ? Colors.grey.shade400
                        : Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                "在使用應用時，如果遇到數據載入問題，你可以通過手動切換網路節點來提升存取體驗。\n\n網路節點測速的狀態提示分為三種：正常、異常和未知。這些狀態是根據你當前的網路情況而定的。你可以通過切換手機的網路類型（如4G/5G、WiFi）來手動測速網路節點的健康狀況，並選擇最適合你的節點。",
                textAlign: TextAlign.start,
                style: TextStyle(color: Colors.grey, fontSize: 12),
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
          : node.isTesting
          ? Colors.grey.shade500
          : Colors.red.shade400;

      return InkWell(
        onTap: () =>
            controller.isTesting.value ? null : controller.selectNode(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            children: [
              Text(node.name),
              const Spacer(),
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
      name: '節點01',
      status: "未知",
      isSelected: true,
    ),
    const Node(url: "https://hk.yahoo.com", name: '節點02', status: "未知"),
    const Node(url: "http://bremsregelungen.xyz", name: '節點03', status: "未知"),
    const Node(url: "https://www.bing.com", name: '節點04', status: "未知"),
    const Node(url: "https://1.1.1.1", name: '節點05', status: "未知"),
    const Node(url: "https://8.8.8.8", name: '節點06', status: "未知"),
    const Node(url: "https://www.baidu.com", name: '節點07', status: "未知"),
    const Node(url: "https://www.apple.com", name: '節點08', status: "未知"),
    const Node(url: "https://github.com", name: '節點09', status: "未知"),
    const Node(url: "https://www.amazon.com", name: '節點10', status: "未知"),
    const Node(url: "https://www.microsoft.com", name: '節點11', status: "未知"),
    const Node(url: "https://www.wikipedia.org", name: '節點12', status: "未知"),
  ].obs;

  final RxBool isTesting = false.obs;
  final RxString lastTestTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    runSpeedTest();
  }

  Future<void> runSpeedTest() async {
    if (isTesting.value) return;

    lastTestTime.value = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    isTesting.value = true;

    for (var i = 0; i < nodeList.length; i++) {
      nodeList[i] = nodeList[i].copyWith(
        status: '測速中',
        isSelected: nodeList[i].isSelected,
      );
    }

    for (var i = 0; i < nodeList.length; i++) {
      nodeList[i] = await _pingNode(nodeList[i]);
    }

    isTesting.value = false;
  }

  Future<Node> _pingNode(Node node) async {
    final stopwatch = Stopwatch()..start();
    try {
      debugPrint("Pinging: ${node.url}");
      final uriParsed = Uri.parse(node.url);

      await http.head(uriParsed).timeout(const Duration(seconds: 1));
      stopwatch.stop();

      return node.copyWith(status: "正常 (${stopwatch.elapsedMilliseconds}ms)");
    } catch (e) {
      debugPrint("Ping failed for ${node.url}: $e");
      stopwatch.stop();
      return node.copyWith(status: "異常");
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

    ToastHelper.show("已複製");
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

  bool get isNormal => status.startsWith('正常');
  bool get isTesting => status.toLowerCase() == '測速中';

  Node copyWith({String? url, String? name, String? status, bool? isSelected}) {
    return Node(
      url: url ?? this.url,
      name: name ?? this.name,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class ToastHelper {
  static OverlayEntry? _currentToast;

  static void show(String message) {
    _currentToast?.remove();
    _currentToast = null;

    final overlay = Get.key.currentState?.overlay;
    if (overlay == null) return;

    final newToast = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _currentToast = newToast;
    overlay.insert(newToast);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentToast == newToast) {
        _currentToast?.remove();
        _currentToast = null;
      }
    });
  }
}
