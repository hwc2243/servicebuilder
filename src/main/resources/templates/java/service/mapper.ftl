<#include "/functions.ftl">
package ${servicePackage};

<#assign imports +=  {
  dtoPackage + "." + entity.name?cap_first + "DTO": true,
  entityPackage + "." + entity.name?cap_first + "Entity": true,
  "java.util.List": true,
  "java.util.Set": true,
  "org.mapstruct.IterableMapping": true,
  "org.mapstruct.Mapper": true,
  "org.mapstruct.Mapping": true,
  "org.mapstruct.Named": true
}>

<#list entity.relateds as related>
  <#assign imports += {
    dtoPackage + "." + related.entityName?cap_first + "DTO": true,
    entityPackage + "." + related.entityName?cap_first + "Entity": true
  }>
</#list>

<@import imports/>

@Mapper(componentModel = "spring")
public interface ${entity.name?cap_first}Mapper {

  @Named("${entity.name}Default")
<#list entity.relateds as related>
  @Mapping(target = "${related.name}", ignore = true)
</#list>
  ${entity.name?cap_first}DTO toDto(${entity.name?cap_first}Entity entity);

  @Named("${entity.name}Shallow")
<#list entity.relateds as related>
  @Mapping(
      target = "${related.name}",
      source = "${related.name}",
      qualifiedByName = "${related.entityName}Default"
  )
</#list>
  ${entity.name?cap_first}DTO toDtoShallow(${entity.name?cap_first}Entity entity);

<#list entity.relateds as related>
  <#assign relatedEntity = entityMap[related.entityName]>

  @Named("${related.entityName}Default")
  <#list relatedEntity.relateds as nestedRelated>
  @Mapping(target = "${nestedRelated.name}", ignore = true)
  </#list>
  ${related.entityName?cap_first}DTO ${related.entityName}ToDto(
      ${related.entityName?cap_first}Entity entity
  );

</#list>

<#list entity.relateds as related>
  @IterableMapping(qualifiedByName = "${related.entityName}Default")
  ${related.collectionType.collectionType}<${related.entityName?cap_first}DTO> ${related.name}ToDtos(
      ${related.collectionType.collectionType}<${related.entityName?cap_first}Entity> entities
  );

</#list>

<#list entity.relateds as related>
  @Mapping(target = "${related.name}", ignore = true)
</#list>
  ${entity.name?cap_first}Entity toEntity(${entity.name?cap_first}DTO dto);

  @IterableMapping(qualifiedByName = "${entity.name}Default")
  List<${entity.name?cap_first}DTO> toDtos(List<${entity.name?cap_first}Entity> entities);

  @IterableMapping(qualifiedByName = "${entity.name}Shallow")
  List<${entity.name?cap_first}DTO> toDtosShallow(List<${entity.name?cap_first}Entity> entities);

  List<${entity.name?cap_first}Entity> toEntities(List<${entity.name?cap_first}DTO> dtos);
}