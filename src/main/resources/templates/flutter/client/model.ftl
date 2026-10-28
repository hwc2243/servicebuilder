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
<#assign serverKeyName = "server" + entity.key.name?cap_first>
<#assign serverKeyType = dartKeyType(entity.key)>
<#assign hasTenantAttribute = false>
<#if entity.multitenant && tenantDiscriminator??>
  <#list entity.attributes as attribute>
    <#if attribute.name == tenantDiscriminator.name>
      <#assign hasTenantAttribute = true>
    </#if>
  </#list>
</#if>
<#assign hasFirstName = false>
<#assign hasLastName = false>
<#list entity.attributes as attribute>
  <#if attribute.name == "firstName"><#assign hasFirstName = true></#if>
  <#if attribute.name == "lastName"><#assign hasLastName = true></#if>
</#list>

class ${className} {
  const ${className}({
    this.id,
    this.${serverKeyName},
<#list entity.attributes as attribute>
    this.${attribute.name},
</#list>
<#if entity.multitenant && tenantDiscriminator?? && !hasTenantAttribute>
    this.${tenantDiscriminator.name},
</#if>
<#list entity.relateds as related>
<#if related.keyOnly && !isTenantKeyOnly(entity, related)>
    this.${related.name}Id,
</#if>
</#list>
  });

  factory ${className}.fromJson(Map<String, dynamic> json) => ${className}(
    ${serverKeyName}: json['${entity.key.name}'] as ${serverKeyType}?,
<#list entity.attributes as attribute>
    ${attribute.name}: json['${attribute.name}'] as ${dartDataType(attribute.type)}?,
</#list>
<#if entity.multitenant && tenantDiscriminator?? && !hasTenantAttribute>
    ${tenantDiscriminator.name}: json['${tenantDiscriminator.name}'] as ${dartDataType(tenantDiscriminator.type)}?,
</#if>
<#list entity.relateds as related>
<#if related.keyOnly && !isTenantKeyOnly(entity, related)>
    ${related.name}Id: json['${related.name}Id'] as ${dartKeyType(entityMap[related.entityName].key)}?,
</#if>
</#list>
  );

  final int? id;
  final ${serverKeyType}? ${serverKeyName};
<#list entity.attributes as attribute>
<#if attribute.type.value == "date">
  /// ISO-8601 calendar date (`yyyy-MM-dd`).
</#if>
  final ${dartDataType(attribute.type)}? ${attribute.name};
</#list>
<#if entity.multitenant && tenantDiscriminator?? && !hasTenantAttribute>
  final ${dartDataType(tenantDiscriminator.type)}? ${tenantDiscriminator.name};
</#if>
<#list entity.relateds as related>
<#if related.keyOnly && !isTenantKeyOnly(entity, related)>
  final ${dartKeyType(entityMap[related.entityName].key)}? ${related.name}Id;
</#if>
</#list>

<#if entity.multitenant && tenantDiscriminator??>
  ${className} for${tenantDiscriminator.name?cap_first}(${dartDataType(tenantDiscriminator.type)} selected${tenantDiscriminator.name?cap_first}) => ${className}(
    id: id,
    ${serverKeyName}: ${serverKeyName},
<#list entity.attributes as attribute>
    ${attribute.name}: ${attribute.name},
</#list>
<#if hasTenantAttribute>
    ${tenantDiscriminator.name}: selected${tenantDiscriminator.name?cap_first},
<#else>
    ${tenantDiscriminator.name}: selected${tenantDiscriminator.name?cap_first},
</#if>
<#list entity.relateds as related>
<#if related.keyOnly && !isTenantKeyOnly(entity, related)>
    ${related.name}Id: ${related.name}Id,
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
<#list entity.attributes as attribute>
    if (${attribute.name} != null) '${attribute.name}': ${attribute.name},
</#list>
<#if entity.multitenant && tenantDiscriminator?? && !hasTenantAttribute>
    if (${tenantDiscriminator.name} != null) '${tenantDiscriminator.name}': ${tenantDiscriminator.name},
</#if>
<#list entity.relateds as related>
<#if related.keyOnly && !isTenantKeyOnly(entity, related)>
    if (${related.name}Id != null) '${related.name}Id': ${related.name}Id,
</#if>
</#list>
  };
}
