import 'package:flutter/material.dart';
import 'package:rishvi_zebra_scanner/zebra_scanner_plugin.dart';

void main() {
  runApp(const ZebraScannerExampleApp());
}

class ZebraScannerExampleApp extends StatelessWidget {
  const ZebraScannerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zebra Scanner Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zebra Scanner Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleCard(
            context,
            title: 'Basic Scanner',
            description: 'Simple barcode scanning example',
            icon: Icons.qr_code_scanner,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BasicScannerExample()),
            ),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            title: 'Inventory Scanner',
            description: 'Scan and manage inventory items',
            icon: Icons.inventory,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InventoryScannerExample(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            title: 'Batch Scanner',
            description: 'Scan multiple items in batch mode',
            icon: Icons.list_alt,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BatchScannerExample()),
            ),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            title: 'Product Lookup',
            description: 'Scan and lookup product information',
            icon: Icons.search,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductLookupExample()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

// Example 1: Basic Scanner
class BasicScannerExample extends StatefulWidget {
  const BasicScannerExample({super.key});

  @override
  State<BasicScannerExample> createState() => _BasicScannerExampleState();
}

class _BasicScannerExampleState extends State<BasicScannerExample> {
  String _barcode = 'No scan yet';
  ScannerStatus _status = ScannerStatus.uninitialized;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    await ZebraScanner.initialize();

    ZebraScanner.scanResultStream.listen((result) {
      setState(() => _barcode = result.data);
    });

    ZebraScanner.statusStream.listen((status) {
      setState(() => _status = status);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Scanner')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: _status == ScannerStatus.scanning
                    ? Colors.blue
                    : Colors.grey,
              ),
              const SizedBox(height: 32),
              Text(
                _barcode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Status: ${_status.name}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _status == ScannerStatus.scanning
                    ? null
                    : () => ZebraScanner.startScan(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Scan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ZebraScanner.dispose();
    super.dispose();
  }
}

// Example 2: Inventory Scanner
class InventoryScannerExample extends StatefulWidget {
  const InventoryScannerExample({super.key});

  @override
  State<InventoryScannerExample> createState() =>
      _InventoryScannerExampleState();
}

class _InventoryScannerExampleState extends State<InventoryScannerExample> {
  final Map<String, int> _inventory = {};
  ScannerStatus _status = ScannerStatus.uninitialized;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    await ZebraScanner.initialize();

    ZebraScanner.scanResultStream.listen((result) {
      setState(() {
        _inventory[result.data] = (_inventory[result.data] ?? 0) + 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added: ${result.data}'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    });

    ZebraScanner.statusStream.listen((status) {
      setState(() => _status = status);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _inventory.isEmpty
                ? null
                : () {
                    setState(() => _inventory.clear());
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Items: ${_inventory.values.fold(0, (a, b) => a + b)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Unique: ${_inventory.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: _inventory.isEmpty
                ? const Center(
                    child: Text(
                      'Scan items to add to inventory',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _inventory.length,
                    itemBuilder: (context, index) {
                      final barcode = _inventory.keys.elementAt(index);
                      final count = _inventory[barcode]!;
                      return ListTile(
                        leading: CircleAvatar(child: Text('$count')),
                        title: Text(barcode),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (count > 1) {
                                _inventory[barcode] = count - 1;
                              } else {
                                _inventory.remove(barcode);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _status == ScannerStatus.scanning
            ? () => ZebraScanner.stopScan()
            : () => ZebraScanner.startScan(),
        icon: Icon(
          _status == ScannerStatus.scanning ? Icons.stop : Icons.play_arrow,
        ),
        label: Text(_status == ScannerStatus.scanning ? 'Stop' : 'Scan'),
        backgroundColor:
            _status == ScannerStatus.scanning ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    ZebraScanner.dispose();
    super.dispose();
  }
}

// Example 3: Batch Scanner
class BatchScannerExample extends StatefulWidget {
  const BatchScannerExample({super.key});

  @override
  State<BatchScannerExample> createState() => _BatchScannerExampleState();
}

class _BatchScannerExampleState extends State<BatchScannerExample> {
  final List<ScanResult> _scans = [];
  bool _isBatchMode = false;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    await ZebraScanner.initialize();

    ZebraScanner.scanResultStream.listen((result) {
      setState(() {
        _scans.insert(0, result);
      });
    });
  }

  void _toggleBatchMode() {
    setState(() {
      _isBatchMode = !_isBatchMode;
      if (_isBatchMode) {
        ZebraScanner.startScan();
      } else {
        ZebraScanner.stopScan();
      }
    });
  }

  void _exportBatch() {
    final data = _scans.map((s) => s.data).join('\n');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${_scans.length} items'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Batch Data'),
                content: SingleChildScrollView(child: Text(data)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Scanner'),
        actions: [
          if (_scans.isNotEmpty)
            IconButton(icon: const Icon(Icons.upload), onPressed: _exportBatch),
          if (_scans.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                setState(() => _scans.clear());
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: _isBatchMode ? Colors.green[50] : Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isBatchMode
                          ? 'Batch Mode Active'
                          : 'Batch Mode Inactive',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isBatchMode ? Colors.green : Colors.grey,
                      ),
                    ),
                    Text(
                      'Scanned: ${_scans.length}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Switch(
                  value: _isBatchMode,
                  onChanged: (_) => _toggleBatchMode(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _scans.isEmpty
                ? const Center(
                    child: Text(
                      'Enable batch mode and start scanning',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _scans.length,
                    itemBuilder: (context, index) {
                      final scan = _scans[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${_scans.length - index}'),
                          ),
                          title: Text(scan.data),
                          subtitle: Text(
                            '${scan.type ?? 'Unknown'} • ${_formatTime(scan.timestamp)}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    ZebraScanner.dispose();
    super.dispose();
  }
}

// Example 4: Product Lookup
class ProductLookupExample extends StatefulWidget {
  const ProductLookupExample({super.key});

  @override
  State<ProductLookupExample> createState() => _ProductLookupExampleState();
}

class _ProductLookupExampleState extends State<ProductLookupExample> {
  String? _scannedBarcode;
  Map<String, dynamic>? _productInfo;
  bool _isLoading = false;

  // Mock product database
  final Map<String, Map<String, dynamic>> _products = {
    '123456789': {
      'name': 'Product A',
      'price': 29.99,
      'stock': 150,
      'category': 'Electronics',
    },
    '987654321': {
      'name': 'Product B',
      'price': 49.99,
      'stock': 75,
      'category': 'Accessories',
    },
  };

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    await ZebraScanner.initialize();

    ZebraScanner.scanResultStream.listen((result) {
      _lookupProduct(result.data);
    });
  }

  Future<void> _lookupProduct(String barcode) async {
    setState(() {
      _scannedBarcode = barcode;
      _isLoading = true;
      _productInfo = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _productInfo = _products[barcode];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Lookup')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_scannedBarcode == null)
                const Column(
                  children: [
                    Icon(Icons.search, size: 100, color: Colors.grey),
                    SizedBox(height: 24),
                    Text(
                      'Scan a barcode to lookup product',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                    Text('Looking up product...'),
                  ],
                )
              else if (_productInfo != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _productInfo!['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Barcode', _scannedBarcode!),
                        _buildInfoRow('Price', '\$${_productInfo!['price']}'),
                        _buildInfoRow(
                          'Stock',
                          '${_productInfo!['stock']} units',
                        ),
                        _buildInfoRow('Category', _productInfo!['category']),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Product Not Found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Barcode: $_scannedBarcode'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => ZebraScanner.startScan(),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Another'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ZebraScanner.dispose();
    super.dispose();
  }
}
