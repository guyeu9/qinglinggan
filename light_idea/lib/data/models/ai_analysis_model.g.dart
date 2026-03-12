// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_analysis_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAIAnalysisModelCollection on Isar {
  IsarCollection<AIAnalysisModel> get aIAnalysisModels => this.collection();
}

const AIAnalysisModelSchema = CollectionSchema(
  name: r'AIAnalysisModel',
  id: 5167579411413882294,
  properties: {
    r'aiHint': PropertySchema(
      id: 0,
      name: r'aiHint',
      type: IsarType.string,
    ),
    r'categoryResult': PropertySchema(
      id: 1,
      name: r'categoryResult',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'ideaId': PropertySchema(
      id: 3,
      name: r'ideaId',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 4,
      name: r'status',
      type: IsarType.string,
      enumMap: _AIAnalysisModelstatusEnumValueMap,
    ),
    r'summary': PropertySchema(
      id: 5,
      name: r'summary',
      type: IsarType.string,
    ),
    r'tagResults': PropertySchema(
      id: 6,
      name: r'tagResults',
      type: IsarType.longList,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _aIAnalysisModelEstimateSize,
  serialize: _aIAnalysisModelSerialize,
  deserialize: _aIAnalysisModelDeserialize,
  deserializeProp: _aIAnalysisModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'ideaId': IndexSchema(
      id: -5045731461153631420,
      name: r'ideaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ideaId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _aIAnalysisModelGetId,
  getLinks: _aIAnalysisModelGetLinks,
  attach: _aIAnalysisModelAttach,
  version: '3.1.0+1',
);

int _aIAnalysisModelEstimateSize(
  AIAnalysisModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aiHint.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.summary.length * 3;
  bytesCount += 3 + object.tagResults.length * 8;
  return bytesCount;
}

void _aIAnalysisModelSerialize(
  AIAnalysisModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiHint);
  writer.writeLong(offsets[1], object.categoryResult);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.ideaId);
  writer.writeString(offsets[4], object.status.name);
  writer.writeString(offsets[5], object.summary);
  writer.writeLongList(offsets[6], object.tagResults);
  writer.writeDateTime(offsets[7], object.updatedAt);
}

AIAnalysisModel _aIAnalysisModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AIAnalysisModel();
  object.aiHint = reader.readString(offsets[0]);
  object.categoryResult = reader.readLongOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.ideaId = reader.readLong(offsets[3]);
  object.status =
      _AIAnalysisModelstatusValueEnumMap[reader.readStringOrNull(offsets[4])] ??
          AnalysisStatus.pending;
  object.summary = reader.readString(offsets[5]);
  object.tagResults = reader.readLongList(offsets[6]) ?? [];
  object.updatedAt = reader.readDateTime(offsets[7]);
  return object;
}

P _aIAnalysisModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (_AIAnalysisModelstatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AnalysisStatus.pending) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLongList(offset) ?? []) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AIAnalysisModelstatusEnumValueMap = {
  r'pending': r'pending',
  r'processing': r'processing',
  r'completed': r'completed',
  r'failed': r'failed',
};
const _AIAnalysisModelstatusValueEnumMap = {
  r'pending': AnalysisStatus.pending,
  r'processing': AnalysisStatus.processing,
  r'completed': AnalysisStatus.completed,
  r'failed': AnalysisStatus.failed,
};

Id _aIAnalysisModelGetId(AIAnalysisModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _aIAnalysisModelGetLinks(AIAnalysisModel object) {
  return [];
}

void _aIAnalysisModelAttach(
    IsarCollection<dynamic> col, Id id, AIAnalysisModel object) {
  object.id = id;
}

extension AIAnalysisModelQueryWhereSort
    on QueryBuilder<AIAnalysisModel, AIAnalysisModel, QWhere> {
  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhere> anyIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ideaId'),
      );
    });
  }
}

extension AIAnalysisModelQueryWhere
    on QueryBuilder<AIAnalysisModel, AIAnalysisModel, QWhereClause> {
  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause>
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

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause>
      ideaIdEqualTo(int ideaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ideaId',
        value: [ideaId],
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause>
      ideaIdNotEqualTo(int ideaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ideaId',
              lower: [],
              upper: [ideaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ideaId',
              lower: [ideaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ideaId',
              lower: [ideaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ideaId',
              lower: [],
              upper: [ideaId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause>
      ideaIdGreaterThan(
    int ideaId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ideaId',
        lower: [ideaId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause>
      ideaIdLessThan(
    int ideaId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ideaId',
        lower: [],
        upper: [ideaId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause>
      ideaIdBetween(
    int lowerIdeaId,
    int upperIdeaId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ideaId',
        lower: [lowerIdeaId],
        includeLower: includeLower,
        upper: [upperIdeaId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause>
      statusEqualTo(AnalysisStatus status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterWhereClause>
      statusNotEqualTo(AnalysisStatus status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AIAnalysisModelQueryFilter
    on QueryBuilder<AIAnalysisModel, AIAnalysisModel, QFilterCondition> {
  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      aiHintEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      aiHintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      aiHintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      aiHintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiHint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      aiHintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      aiHintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      aiHintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      aiHintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiHint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      aiHintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiHint',
        value: '',
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      aiHintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiHint',
        value: '',
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      categoryResultIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoryResult',
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      categoryResultIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoryResult',
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      categoryResultEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryResult',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      categoryResultGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryResult',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      categoryResultLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryResult',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      categoryResultBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryResult',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
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

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
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

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
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

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
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

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
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

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
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

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      ideaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ideaId',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      ideaIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ideaId',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      ideaIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ideaId',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      ideaIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ideaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      statusEqualTo(
    AnalysisStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      statusGreaterThan(
    AnalysisStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      statusLessThan(
    AnalysisStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      statusBetween(
    AnalysisStatus lower,
    AnalysisStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      summaryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      summaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      summaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      summaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'summary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      summaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      summaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      summaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      summaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'summary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      summaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summary',
        value: '',
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      summaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'summary',
        value: '',
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      tagResultsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagResults',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      tagResultsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tagResults',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      tagResultsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tagResults',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      tagResultsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tagResults',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      tagResultsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagResults',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      tagResultsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagResults',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      tagResultsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagResults',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      tagResultsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagResults',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      tagResultsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagResults',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      tagResultsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagResults',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AIAnalysisModelQueryObject
    on QueryBuilder<AIAnalysisModel, AIAnalysisModel, QFilterCondition> {}

extension AIAnalysisModelQueryLinks
    on QueryBuilder<AIAnalysisModel, AIAnalysisModel, QFilterCondition> {}

extension AIAnalysisModelQuerySortBy
    on QueryBuilder<AIAnalysisModel, AIAnalysisModel, QSortBy> {
  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy> sortByAiHint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiHint', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      sortByAiHintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiHint', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      sortByCategoryResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryResult', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      sortByCategoryResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryResult', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy> sortByIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ideaId', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      sortByIdeaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ideaId', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy> sortBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      sortBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AIAnalysisModelQuerySortThenBy
    on QueryBuilder<AIAnalysisModel, AIAnalysisModel, QSortThenBy> {
  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy> thenByAiHint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiHint', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      thenByAiHintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiHint', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      thenByCategoryResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryResult', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      thenByCategoryResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryResult', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy> thenByIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ideaId', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      thenByIdeaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ideaId', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy> thenBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      thenBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AIAnalysisModelQueryWhereDistinct
    on QueryBuilder<AIAnalysisModel, AIAnalysisModel, QDistinct> {
  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QDistinct> distinctByAiHint(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiHint', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QDistinct>
      distinctByCategoryResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryResult');
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QDistinct> distinctByIdeaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ideaId');
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QDistinct> distinctBySummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QDistinct>
      distinctByTagResults() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagResults');
    });
  }

  QueryBuilder<AIAnalysisModel, AIAnalysisModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AIAnalysisModelQueryProperty
    on QueryBuilder<AIAnalysisModel, AIAnalysisModel, QQueryProperty> {
  QueryBuilder<AIAnalysisModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AIAnalysisModel, String, QQueryOperations> aiHintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiHint');
    });
  }

  QueryBuilder<AIAnalysisModel, int?, QQueryOperations>
      categoryResultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryResult');
    });
  }

  QueryBuilder<AIAnalysisModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AIAnalysisModel, int, QQueryOperations> ideaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ideaId');
    });
  }

  QueryBuilder<AIAnalysisModel, AnalysisStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<AIAnalysisModel, String, QQueryOperations> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summary');
    });
  }

  QueryBuilder<AIAnalysisModel, List<int>, QQueryOperations>
      tagResultsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagResults');
    });
  }

  QueryBuilder<AIAnalysisModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
