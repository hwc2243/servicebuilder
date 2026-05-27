<#include "/functions.ftl">
package ${servicePackage};
<#assign imports +=  {
  dtoPackage + "." + entity.name?cap_first + "DTO": true,
  entityPackage + "." + entity.name?cap_first + "Entity": true,
  "java.util.List": true,
  "org.mapstruct.Mapper": true,
  "org.mapstruct.Mapping": true
}>

<@import imports/>

@Mapper(componentModel = "spring")
public interface ${entity.name?cap_first}Mapper {
  
<#list entity.relateds as related>
<#if related.bidirectional
    || related.relationshipType.name() == "ONE_TO_MANY"
    || related.relationshipType.name() == "MANY_TO_MANY">
  @Mapping(target = "${related.name}", ignore = true)
</#if>
</#list>
  ${entity.name?cap_first}DTO toDto(${entity.name?cap_first}Entity entity);
  
<#list entity.relateds as related>
<#if related.bidirectional
    || related.relationshipType.name() == "ONE_TO_MANY"
    || related.relationshipType.name() == "MANY_TO_MANY">
  @Mapping(target = "${related.name}", ignore = true)
</#if>
</#list>
  ${entity.name?cap_first}Entity toEntity(${entity.name?cap_first}DTO dto);
  
  List<${entity.name?cap_first}DTO> toDtos(List<${entity.name?cap_first}Entity> entities);

  List<${entity.name?cap_first}Entity> toEntities(List<${entity.name?cap_first}DTO> dtos);
}