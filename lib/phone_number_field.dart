library phone_field;

import 'package:country_icons/country_icons.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phone_field/constants/picker_type.dart';
import 'package:phone_field/countries.dart';
import 'package:phone_field/models/phone_number_model.dart';

import 'models/country_model.dart';

class PhoneNumberField extends StatefulWidget {
  final String? hint;
  final String? label;
  final Key? formKey;
  final TextEditingController? controller;
  final Function? validator;
  final List<Country>? countries;
  final PickerType? pickerType;
  final String? initialCountry;
  final bool? showFlag;
  final Function(PhoneNumberModel value)? onChanged;
  final Function(PhoneNumberModel value)? onSaved;
  final Function(PhoneNumberModel value)? onFieldSubmitted;

  const PhoneNumberField({
    this.hint,
    this.label,
    this.formKey,
    this.controller,
    this.validator,
    this.countries = defaultCountries,
    this.pickerType = PickerType.bottomSheet,
    this.initialCountry,
    this.showFlag = true,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    super.key,
  });

  @override
  State<PhoneNumberField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneNumberField> {
  Country dropdownValue = defaultCountries[0];

  @override
  void initState() {
    super.initState();
    if (widget.initialCountry != null) {
      dropdownValue = widget.countries?.firstWhereOrNull(
              (element) => element.code == widget.initialCountry) ??
          defaultCountries[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.formKey,
      controller: widget.controller,
      decoration: InputDecoration(
        prefix: Text('${dropdownValue.dialCode} '),
        prefixIcon: widget.pickerType == PickerType.dropDown
            ? showCountryDropDown()
            : GestureDetector(
                onTap: () {
                  if (widget.pickerType == PickerType.bottomSheet) {
                    showCountriesInBottomSheet();
                  }
                  if (widget.pickerType == PickerType.dialog) {
                    showCountriesInDialog();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 25,
                        width: 25,
                        child: CountryIcons.getSvgFlag(
                            dropdownValue.code.toLowerCase()),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          dropdownValue.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        hintText: widget.hint,
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      keyboardType: TextInputType.phone,
      onChanged: (val) => widget.onChanged?.call(
        PhoneNumberModel(phoneNumber: val, countryCode: dropdownValue.dialCode),
      ),
      onSaved: (val) => widget.onSaved?.call(
        PhoneNumberModel(phoneNumber: val, countryCode: dropdownValue.dialCode),
      ),
      onFieldSubmitted: (val) => widget.onFieldSubmitted?.call(
        PhoneNumberModel(phoneNumber: val, countryCode: dropdownValue.dialCode),
      ),
      validator: widget.validator == null
          ? (value) {
              if (value!.isEmpty) {
                return 'Please enter Phone number';
              }
              return null;
            }
          : widget.validator?.call(),
    );
  }

  Widget showCountryDropDown() {
    return DropdownButton<Country>(
      value: dropdownValue,
      elevation: 16,
      alignment: Alignment.center,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(),
      iconSize: 0,
      onChanged: (Country? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      selectedItemBuilder: (BuildContext context) {
        return widget.countries!
            .map<Widget>(
              (Country value) => Container(
                constraints: const BoxConstraints(maxWidth: 120),
                child: dropDownMenuItem(value),
              ),
            )
            .toList();
      },
      items: widget.countries!.map<DropdownMenuItem<Country>>((Country value) {
        return DropdownMenuItem<Country>(
          value: value,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 250),
            child: dropDownMenuItem(value),
          ),
        );
      }).toList(),
    );
  }

  Widget dropDownMenuItem(Country country) {
    return Row(
      children: [
        const SizedBox(width: 8),
        if (widget.showFlag == true)
          SizedBox(
            height: 25,
            width: 25,
            child: CountryIcons.getSvgFlag(country.code.toLowerCase()),
          ),
        const SizedBox(width: 10),
        Flexible(child: Text(country.name)),
        // Text(country.dialCode.toString()),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget countryListTile(List<Country> countries, int index) {
    return ListTile(
      leading: SizedBox(
        width: 25,
        height: 25,
        child: CountryIcons.getSvgFlag(countries![index].code.toLowerCase()),
      ),
      trailing: Text(countries[index].dialCode.toString()),
      title: Text(countries[index].name),
      onTap: () {
        setState(() {
          dropdownValue = countries![index];
        });
        Navigator.pop(context);
      },
    );
  }

  Widget countryList() {
    final searchData = ValueNotifier([...?widget.countries]);

    return Column(
      children: [
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Search Country',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            searchData.value = widget.countries!
                .where((element) =>
                    (element.name
                        .toLowerCase()
                        .startsWith(value.toLowerCase())) ||
                    element.dialCode.contains(value))
                .toList();
          },
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: searchData,
            builder: (context, val, _) {
              return ListView.builder(
                itemCount: val.length,
                itemBuilder: (context, index) {
                  return countryListTile(searchData.value, index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void showCountriesInDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: countryList(),
        );
      },
    );
  }

  void showCountriesInBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return countryList();
      },
    );
  }
}
