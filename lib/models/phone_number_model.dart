class PhoneNumberModel {
  String? phoneNumber;
  String? countryCode;

  get completeNumber => "$countryCode$phoneNumber";

  PhoneNumberModel({required this.phoneNumber, required this.countryCode});
}
