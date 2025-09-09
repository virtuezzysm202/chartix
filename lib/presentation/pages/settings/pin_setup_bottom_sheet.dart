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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Set PIN",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              widget.onPinSet(_pinController.text);
              Navigator.pop(context);
            },
            child: const Text("Save PIN"),
          ),
        ],
      ),
    );
  }
}
