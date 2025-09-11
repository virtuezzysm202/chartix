import 'package:flutter/material.dart';

class PinSetupBottomSheet extends StatefulWidget {
  final String currentPin;
  final ValueChanged<String> onPinSet;

  const PinSetupBottomSheet({
    super.key,
    required this.currentPin,
    required this.onPinSet,
  });

  @override
  State<PinSetupBottomSheet> createState() => _PinSetupBottomSheetState();
}

class _PinSetupBottomSheetState extends State<PinSetupBottomSheet> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pinController.text = widget.currentPin;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Padding dengan viewInsets agar keyboard tidak menutupi
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Set PIN",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter 4-6 digit PIN",
                    counterText: "",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_pinController.text.isEmpty) return;
                    widget.onPinSet(_pinController.text);
                    Navigator.pop(context);
                  },
                  child: const Text("Save PIN"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
