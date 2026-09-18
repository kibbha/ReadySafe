import 'package:flutter/material.dart';
import '../app/localizations.dart';
import '../data/country_repository.dart';
import '../models/country_profile.dart';

String countryFlag(String code) =>
    String.fromCharCodes(code.codeUnits.map((unit) => unit + 127397));

List<CountryProfile> filterCountries(
  List<CountryProfile> countries,
  String query,
  AppLocalizations strings,
) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return countries;
  return countries.where((country) {
    final name = strings.get(country.nameKey).toLowerCase();
    return name.contains(needle) ||
        country.isoCode.toLowerCase().contains(needle);
  }).toList();
}

Future<String?> showCountryPicker(
  BuildContext context, {
  String? selectedCode,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _CountryPickerSheet(selectedCode: selectedCode),
);

class CountrySearchList extends StatefulWidget {
  const CountrySearchList({
    super.key,
    required this.onSelected,
    this.selectedCode,
  });
  final ValueChanged<String> onSelected;
  final String? selectedCode;
  @override
  State<CountrySearchList> createState() => _CountrySearchListState();
}

class _CountrySearchListState extends State<CountrySearchList> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final countries = filterCountries(
      CountryRepository.supported,
      query,
      strings,
    );
    return Column(
      children: [
        SearchBar(
          hintText: strings.get('search_country'),
          leading: const Icon(Icons.search),
          onChanged: (value) => setState(() => query = value),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: countries.length,
            itemBuilder: (_, index) {
              final country = countries[index];
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  minTileHeight: 60,
                  leading: Text(
                    countryFlag(country.isoCode),
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(strings.get(country.nameKey)),
                  subtitle: Text(country.isoCode),
                  trailing: country.isoCode == widget.selectedCode
                      ? const Icon(Icons.check_circle)
                      : country.hasVerifiedNumbers
                      ? const Icon(Icons.verified_outlined)
                      : Icon(
                          Icons.warning_amber_rounded,
                          semanticLabel: strings.get('numbers_unverified'),
                        ),
                  onTap: () => widget.onSelected(country.isoCode),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CountryPickerSheet extends StatelessWidget {
  const _CountryPickerSheet({this.selectedCode});
  final String? selectedCode;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      16,
      16,
      16,
      16 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: CountrySearchList(
      selectedCode: selectedCode,
      onSelected: (code) => Navigator.pop(context, code),
    ),
  );
}
