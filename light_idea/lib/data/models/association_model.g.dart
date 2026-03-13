// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'association_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAssociationModelCollection on Isar {
  IsarCollection<AssociationModel> get associationModels => this.collection();
}

const AssociationModelSchema = CollectionSchema(
  name: r'AssociationModel',
  id: -6781125240943387113,
  properties: {
    r'confidence': PropertySchema(
      id: 0,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'reason': PropertySchema(
      id: 2,
      name: r'reason',
      type: IsarType.string,
    ),
    r'sourceIdeaId': PropertySchema(
      id: 3,
      name: r'sourceIdeaId',
      type: IsarType.long,
    ),
    r'targetIdeaId': PropertySchema(
      id: 4,
      name: r'targetIdeaId',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 5,
      name: r'type',
      type: IsarType.string,
      enumMap: _AssociationModeltypeEnumValueMap,
    )
  },
  estimateSize: _associationModelEstimateSize,
  serialize: _associationModelSerialize,
  deserialize: _associationModelDeserialize,
  deserializeProp: _associationModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'sourceIdeaId': IndexSchema(
      id: 6866051947064508675,
      name: r'sourceIdeaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sourceIdeaId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'targetIdeaId': IndexSchema(
      id: 9195339677695715165,
      name: r'targetIdeaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'targetIdeaId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _associationModelGetId,
  getLinks: _associationModelGetLinks,
  attach: _associationModelAttach,
  version: '3.1.0+1',
);

int _associationModelEstimateSize(
  AssociationModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.reason.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _associationModelSerialize(
  AssociationModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.confidence);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.reason);
  writer.writeLong(offsets[3], object.sourceIdeaId);
  writer.writeLong(offsets[4], object.targetIdeaId);
  writer.writeString(offsets[5], object.type.name);
}

AssociationModel _associationModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AssociationModel();
  object.confidence = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.reason = reader.readString(offsets[2]);
  object.sourceIdeaId = reader.readLong(offsets[3]);
  object.targetIdeaId = reader.readLong(offsets[4]);
  object.type =
      _AssociationModeltypeValueEnumMap[reader.readStringOrNull(offsets[5])] ??
          RelationType.similar;
  return object;
}

P _associationModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (_AssociationModeltypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          RelationType.similar) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AssociationModeltypeEnumValueMap = {
  r'similar': r'similar',
  r'complementary': r'complementary',
  r'evolutionary': r'evolutionary',
};
const _AssociationModeltypeValueEnumMap = {
  r'similar': RelationType.similar,
  r'complementary': RelationType.complementary,
  r'evolutionary': RelationType.evolutionary,
};

Id _associationModelGetId(AssociationModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _associationModelGetLinks(AssociationModel object) {
  return [];
}

void _associationModelAttach(
    IsarCollection<dynamic> col, Id id, AssociationModel object) {
  object.id = id;
}

extension AssociationModelQueryWhereSort
    on QueryBuilder<AssociationModel, AssociationModel, QWhere> {
  QueryBuilder<AssociationModel, AssociationModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhere>
      anySourceIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sourceIdeaId'),
      );
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhere>
      anyTargetIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'targetIdeaId'),
      );
    });
  }
}

extension AssociationModelQueryWhere
    on QueryBuilder<AssociationModel, AssociationModel, QWhereClause> {
  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      sourceIdeaIdEqualTo(int sourceIdeaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sourceIdeaId',
        value: [sourceIdeaId],
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      sourceIdeaIdNotEqualTo(int sourceIdeaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceIdeaId',
              lower: [],
              upper: [sourceIdeaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceIdeaId',
              lower: [sourceIdeaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceIdeaId',
              lower: [sourceIdeaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceIdeaId',
              lower: [],
              upper: [sourceIdeaId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      sourceIdeaIdGreaterThan(
    int sourceIdeaId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sourceIdeaId',
        lower: [sourceIdeaId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      sourceIdeaIdLessThan(
    int sourceIdeaId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sourceIdeaId',
        lower: [],
        upper: [sourceIdeaId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      sourceIdeaIdBetween(
    int lowerSourceIdeaId,
    int upperSourceIdeaId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sourceIdeaId',
        lower: [lowerSourceIdeaId],
        includeLower: includeLower,
        upper: [upperSourceIdeaId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      targetIdeaIdEqualTo(int targetIdeaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'targetIdeaId',
        value: [targetIdeaId],
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      targetIdeaIdNotEqualTo(int targetIdeaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetIdeaId',
              lower: [],
              upper: [targetIdeaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetIdeaId',
              lower: [targetIdeaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetIdeaId',
              lower: [targetIdeaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetIdeaId',
              lower: [],
              upper: [targetIdeaId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      targetIdeaIdGreaterThan(
    int targetIdeaId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'targetIdeaId',
        lower: [targetIdeaId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      targetIdeaIdLessThan(
    int targetIdeaId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'targetIdeaId',
        lower: [],
        upper: [targetIdeaId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterWhereClause>
      targetIdeaIdBetween(
    int lowerTargetIdeaId,
    int upperTargetIdeaId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'targetIdeaId',
        lower: [lowerTargetIdeaId],
        includeLower: includeLower,
        upper: [upperTargetIdeaId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AssociationModelQueryFilter
    on QueryBuilder<AssociationModel, AssociationModel, QFilterCondition> {
  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      confidenceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      confidenceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      confidenceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      confidenceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      sourceIdeaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceIdeaId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      sourceIdeaIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceIdeaId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      sourceIdeaIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceIdeaId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      sourceIdeaIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceIdeaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      targetIdeaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetIdeaId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      targetIdeaIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetIdeaId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      targetIdeaIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetIdeaId',
        value: value,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      targetIdeaIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetIdeaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      typeEqualTo(
    RelationType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      typeGreaterThan(
    RelationType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      typeLessThan(
    RelationType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      typeBetween(
    RelationType lower,
    RelationType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension AssociationModelQueryObject
    on QueryBuilder<AssociationModel, AssociationModel, QFilterCondition> {}

extension AssociationModelQueryLinks
    on QueryBuilder<AssociationModel, AssociationModel, QFilterCondition> {}

extension AssociationModelQuerySortBy
    on QueryBuilder<AssociationModel, AssociationModel, QSortBy> {
  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortBySourceIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceIdeaId', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortBySourceIdeaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceIdeaId', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortByTargetIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetIdeaId', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortByTargetIdeaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetIdeaId', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension AssociationModelQuerySortThenBy
    on QueryBuilder<AssociationModel, AssociationModel, QSortThenBy> {
  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenBySourceIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceIdeaId', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenBySourceIdeaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceIdeaId', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenByTargetIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetIdeaId', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenByTargetIdeaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetIdeaId', Sort.desc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension AssociationModelQueryWhereDistinct
    on QueryBuilder<AssociationModel, AssociationModel, QDistinct> {
  QueryBuilder<AssociationModel, AssociationModel, QDistinct>
      distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QDistinct> distinctByReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QDistinct>
      distinctBySourceIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceIdeaId');
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QDistinct>
      distinctByTargetIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetIdeaId');
    });
  }

  QueryBuilder<AssociationModel, AssociationModel, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension AssociationModelQueryProperty
    on QueryBuilder<AssociationModel, AssociationModel, QQueryProperty> {
  QueryBuilder<AssociationModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AssociationModel, double, QQueryOperations>
      confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<AssociationModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AssociationModel, String, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<AssociationModel, int, QQueryOperations> sourceIdeaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceIdeaId');
    });
  }

  QueryBuilder<AssociationModel, int, QQueryOperations> targetIdeaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetIdeaId');
    });
  }

  QueryBuilder<AssociationModel, RelationType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
