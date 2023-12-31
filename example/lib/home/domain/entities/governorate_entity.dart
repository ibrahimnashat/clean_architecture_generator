import 'package:eitherx/eitherx.dart';
import 'package:example/core/base_response.dart';
import 'package:example/core/failure.dart';
import 'package:injectable/injectable.dart';
import 'package:example/core/base_use_case.dart';
import 'package:example/home/domain/entities/available_results_entity.dart';

class GovernorateEntity {
final int id;
final String name;
final bool isFavourite;
final List<AvailableResultsEntity> availableResults;
const GovernorateEntity({
required this.id,
required this.name,
required this.isFavourite,
required this.availableResults,
 });

}

