<#include "/functions.ftl">

<#function dartDataType type>
  <#if type.value == "boolean">
    <#return "bool">
  <#elseif type.value == "int" || type.value == "long">
    <#return "int">
  <#elseif type.value == "float" || type.value == "double" || type.value == "money">
    <#return "double">
  <#else>
    <#return "String">
  </#if>
</#function>

<#function dartKeyType key>
  <#if key.type.value == "int" || key.type.value == "long">
    <#return "int">
  <#else>
    <#return "String">
  </#if>
</#function>

<#assign className = entity.name?cap_first + "Dto">
<#assign allAttributes = inheritedAndOwnAttributes(entity)>
<#assign serverKeyName = "server" + entity.key.name?cap_first>
<#assign serverKeyType = dartKeyType(entity.key)>
<#assign tenantFieldName = "">
<#if isEffectivelyMultitenant(entity) && tenantDiscriminator??>
  <#assign tenantFieldName = tenantDiscriminator.name>
</#if>
<#function isTenantRelation related>
  <#return related.apiIdReference && tenantFieldName?has_content
      && related.name + "Id" == tenantFieldName>
</#function>
<#function isObjectRelation related>
  <#return related.apiObjectReference && !isTenantRelation(related)>
</#function>
<#assign hasTenantAttribute = false>
<#if isEffectivelyMultitenant(entity) && tenantDiscriminator??>
  <#list allAttributes as attribute>
    <#if attribute.name == tenantDiscriminator.name>
      <#assign hasTenantAttribute = true>
    </#if>
  </#list>
</#if>
<#assign hasFirstName = false>
<#assign hasLastName = false>
<#list allAttributes as attribute>
  <#if attribute.name == "firstName"><#assign hasFirstName = true></#if>
  <#if attribute.name == "lastName"><#assign hasLastName = true></#if>
</#list>

class ${className} {
  const ${className}({
    this.id,
    this.${serverKeyName},
<#list allAttributes as attribute>
    this.${attribute.name},
</#list>
<#if isEffectivelyMultitenant(entity) && tenantDiscriminator?? && !hasTenantAttribute>
    this.${tenantDiscriminator.name},
</#if>
<#list inheritedAndOwnRelateds(entity) as related>
<#if related.apiIdReference && !isTenantRelation(related)>
    this.${related.name}Id,
<#elseif isObjectRelation(related) && (related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE")>
    this.${related.name},
<#elseif isObjectRelation(related)>
    this.${related.name},
</#if>
</#list>
  });

  factory ${className}.fromJson(Map<String, dynamic> json) => ${className}(
    ${serverKeyName}: json['${entity.key.name}'] as ${serverKeyType}?,
<#list allAttributes as attribute>
    ${attribute.name}: json['${attribute.name}'] as ${dartDataType(attribute.type)}?,
</#list>
<#if isEffectivelyMultitenant(entity) && tenantDiscriminator?? && !hasTenantAttribute>
    ${tenantDiscriminator.name}: json['${tenantDiscriminator.name}'] as ${dartDataType(tenantDiscriminator.type)}?,
</#if>
<#list inheritedAndOwnRelateds(entity) as related>
<#if related.apiIdReference && !isTenantRelation(related)>
    ${related.name}Id: json['${related.name}Id'] as ${dartKeyType(entityMap[related.entityName].key)}?,
<#elseif isObjectRelation(related) && (related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE")>
    ${related.name}: json['${related.name}'] == null ? null : ${related.entityName?cap_first}Dto.fromJson(json['${related.name}'] as Map<String, dynamic>),
<#elseif isObjectRelation(related)>
    ${related.name}: (json['${related.name}'] as List<dynamic>?)
        ?.map((item) => ${related.entityName?cap_first}Dto.fromJson(item as Map<String, dynamic>)).toList(),
</#if>
</#list>
  );

  final int? id;
  final ${serverKeyType}? ${serverKeyName};
<#list allAttributes as attribute>
<#if attribute.type.value == "date">
  /// ISO-8601 calendar date (`yyyy-MM-dd`).
</#if>
  final ${dartDataType(attribute.type)}? ${attribute.name};
</#list>
<#if isEffectivelyMultitenant(entity) && tenantDiscriminator?? && !hasTenantAttribute>
  final ${dartDataType(tenantDiscriminator.type)}? ${tenantDiscriminator.name};
</#if>
<#list inheritedAndOwnRelateds(entity) as related>
<#if related.apiIdReference && !isTenantRelation(related)>
  final ${dartKeyType(entityMap[related.entityName].key)}? ${related.name}Id;
<#elseif isObjectRelation(related) && (related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE")>
  final ${related.entityName?cap_first}Dto? ${related.name};
<#elseif isObjectRelation(related)>
  final List<${related.entityName?cap_first}Dto>? ${related.name};
</#if>
</#list>

<#if isEffectivelyMultitenant(entity) && tenantDiscriminator??>
  ${className} for${tenantDiscriminator.name?cap_first}(${dartDataType(tenantDiscriminator.type)} selected${tenantDiscriminator.name?cap_first}) => ${className}(
    id: id,
    ${serverKeyName}: ${serverKeyName},
<#list allAttributes as attribute>
<#if !hasTenantAttribute || attribute.name != tenantDiscriminator.name>
    ${attribute.name}: ${attribute.name},
</#if>
</#list>
    ${tenantDiscriminator.name}: selected${tenantDiscriminator.name?cap_first},
<#list inheritedAndOwnRelateds(entity) as related>
<#if related.apiIdReference && !isTenantRelation(related)>
    ${related.name}Id: ${related.name}Id,
<#elseif isObjectRelation(related)>
    ${related.name}: ${related.name},
</#if>
</#list>
  );
</#if>

<#if hasFirstName && hasLastName>
  String get displayName => [
    firstName,
    lastName,
  ].whereType<String>().where((name) => name.isNotEmpty).join(' ');
</#if>

  Map<String, dynamic> toJson() => {
    if (${serverKeyName} != null) '${entity.key.name}': ${serverKeyName},
<#list allAttributes as attribute>
    if (${attribute.name} != null) '${attribute.name}': ${attribute.name},
</#list>
<#if isEffectivelyMultitenant(entity) && tenantDiscriminator?? && !hasTenantAttribute>
    if (${tenantDiscriminator.name} != null) '${tenantDiscriminator.name}': ${tenantDiscriminator.name},
</#if>
<#list inheritedAndOwnRelateds(entity) as related>
<#if related.apiIdReference && !isTenantRelation(related)>
    if (${related.name}Id != null) '${related.name}Id': ${related.name}Id,
<#elseif isObjectRelation(related)>
    if (${related.name} != null) '${related.name}': ${related.name} is List
        ? ${related.name}!.map((item) => item.toJson()).toList()
        : (${related.name} as dynamic).toJson(),
</#if>
</#list>
  };
}
