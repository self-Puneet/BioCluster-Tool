import 'package:flutter/material.dart';

class DynamicTextFields extends StatefulWidget {
  final Map<String, String> initialData;

  const DynamicTextFields({Key? key, required this.initialData})
    : super(key: key);

  @override
  DynamicTextFieldsState createState() => DynamicTextFieldsState();
}

class DynamicTextFieldsState extends State<DynamicTextFields> {
  late List<MapEntry<String, String>> entries;
  // Removed keyControllers since key is no longer editable.
  late List<TextEditingController> valueControllers;
  late List<bool> valueIsValid;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    entries = widget.initialData.entries.toList();
    valueControllers =
        entries.map((e) => TextEditingController(text: e.value)).toList();
    // Initialize validity for each entry using our validator.
    valueIsValid =
        entries.map((e) => isValidNucleotideSequence(e.value)).toList();
  }

  @override
  void didUpdateWidget(covariant DynamicTextFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update only if the initial data changed.
    if (oldWidget.initialData != widget.initialData) {
      for (var controller in valueControllers) {
        controller.dispose();
      }
      _initializeData();
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (var controller in valueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Returns the current data from the text fields as a Map.
  Map<String, String> getCurrentData() {
    return {for (var entry in entries) entry.key: entry.value};
  }

  void removeEntry(int index) {
    setState(() {
      entries.removeAt(index);
      valueControllers.removeAt(index).dispose();
      valueIsValid.removeAt(index);
    });
  }

  // Inside DynamicTextFieldsState, for example after dispose():
List<String> getKeys() {
  return entries.map((entry) => entry.key).toList();
}


  /// Validator: returns true if [sequence] contains only A, T, C, or G (case-insensitive)
  bool isValidNucleotideSequence(String sequence) {
    final regex = RegExp(r'^[ATCGatcg]+$');
    return regex.hasMatch(sequence);
  }

  /// Returns true if all value text fields contain valid nucleotide sequences.
  bool areAllSequencesValid() {
    return valueIsValid.every((valid) => valid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...entries.asMap().entries.map((entry) {
          int index = entry.key;
          return Container(
            padding: EdgeInsets.symmetric(vertical: 7.5),
            child: Row(
              children: [
                Expanded(
                  flex: 10,
                  child: TextField(
                    cursorColor: Color.fromRGBO(251, 135, 5, 1),
                    controller: valueControllers[index],
                    decoration: InputDecoration(
                      // Display the key as the label for this text field.
                      labelText: entries[index].key,
                      labelStyle: TextStyle(
                        color: Color.fromRGBO(251, 135, 5, 1),
                        fontSize: 20,
                      ),
                      hintText: "Value",
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(251, 135, 5, 1),
                          width: 1.5,
                        ),
                      ),
                      errorText:
                          valueIsValid[index]
                              ? null
                              : "Invalid nucleotide sequence",
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        // Update the value for the corresponding key.
                        entries[index] = MapEntry(entries[index].key, newValue);
                        valueIsValid[index] = isValidNucleotideSequence(
                          newValue,
                        );
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  // padding: EdgeInsets.only(bottom: 18),
                  child: IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      size: 30,
                      color: Colors.red,
                    ),
                    onPressed: () => removeEntry(index),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
