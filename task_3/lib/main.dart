import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyFormPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyFormPage extends StatefulWidget {
  @override
  _MyFormPageState createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  TextEditingController _birthdateController = TextEditingController();
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bytewise Fellowship Task#3',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Name:",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                  ),
                ),
                Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onSaved: (value) => _formData['name'] = value,
                    ),
                  ),
                ),
                Text(
                  "Email:",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                  ),
                ),
                Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      onSaved: (value) => _formData['email'] = value,
                    ),
                  ),
                ),
                Text(
                  "Phone:",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                  ),
                ),
                Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your phone',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        final phoneRegex = RegExp(r'^[0-9]+$');
                        if (!phoneRegex.hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      onSaved: (value) => _formData['phone'] = value,
                    ),
                  ),
                ),
                Text(
                  "Birthdate:",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                  ),
                ),
                Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: _birthdateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: 'Select your birthdate',
                        border: InputBorder.none,
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                            _birthdateController.text =
                                pickedDate.toLocal().toString().split(' ')[0];
                            _formData['birthdate'] =
                                pickedDate.toLocal().toString().split(' ')[0];
                          });
                        }
                      },
                      onSaved: (value) => _formData['birthdate'] = value,
                    ),
                  ),
                ),
                Text(
                  "Address:",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                  ),
                ),
                Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          hintText: 'Enter your address',
                          border: InputBorder.none),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                      onSaved: (value) => _formData['address'] = value,
                    ),
                  ),
                ),
                Text(
                  "Country:",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                  ),
                ),
                Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          hintText: 'Select your country',
                          border: InputBorder.none),
                      items: ['Pakistan', 'Canada', 'Iran', 'Iraq']
                          .map((country) => DropdownMenuItem(
                                value: country,
                                child: Text(country),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        _formData['country'] = value;
                      }),
                      onSaved: (value) => _formData['country'] = value,
                    ),
                  ),
                ),
                Text(
                  "Gender:",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                  ),
                ),
                RadioListTile(
                  title: const Text('Male'),
                  value: 'male',
                  groupValue: _formData['gender'],
                  onChanged: (value) => setState(() {
                    _formData['gender'] = value;
                  }),
                  activeColor: Colors.greenAccent,
                ),
                RadioListTile(
                  title: const Text('Female'),
                  value: 'female',
                  groupValue: _formData['gender'],
                  onChanged: (value) => setState(() {
                    _formData['gender'] = value;
                  }),
                  activeColor: Colors.greenAccent,
                ),
                Text(
                  "Age:",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                  ),
                ),
                Slider(
                  label: '${_formData['age'] ?? 18}',
                  value: (_formData['age'] ?? 18).toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) => setState(() {
                    _formData['age'] = value.toInt();
                  }),
                  activeColor: Colors.greenAccent,
                ),
                CheckboxListTile(
                  title: const Text('Subscribe to newsletter'),
                  value: _formData['subscribe'] ?? false,
                  onChanged: (value) => setState(() {
                    _formData['subscribe'] = value;
                  }),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.greenAccent,
                ),
                SwitchListTile(
                  title: const Text('Receive Notifications'),
                  value: _formData['notifications'] ?? false,
                  onChanged: (value) => setState(() {
                    _formData['notifications'] = value;
                  }),
                  activeColor: Colors.greenAccent,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        _formKey.currentState!.save();
                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisplayDataPage(_formData),
                            ),
                          );
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : const Text('Submit'),
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

class DisplayDataPage extends StatelessWidget {
  final Map<String, dynamic> formData;

  DisplayDataPage(this.formData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Display Data',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: formData.keys.map((key) {
            return Card(
              elevation: 8.0,
              child: ListTile(
                title: Text(
                  '$key:',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: key == 'birthdate'
                    ? Text(
                        '${formData[key]}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        '${formData[key]}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                        ),
                      ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
