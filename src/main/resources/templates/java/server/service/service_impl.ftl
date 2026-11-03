<#include "/functions.ftl">
package ${servicePackage};
<#assign imports +=  {
  "java.util.Collection": true,
  "java.util.List": true,
  "org.springframework.beans.factory.annotation.Autowired" : true,
  "org.springframework.stereotype.Service": true,
  serviceBasePackage + ".Base" + entity.name?cap_first + "ServiceImpl": true,
  dtoPackage + "." + entity.name?cap_first + "DTO": true,
  entityPackage + "." + entity.name?cap_first + "Entity": true
 }>
<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_MANY" || related.relationshipType.name() == "MANY_TO_MANY">
<#assign imports += { dtoPackage + "." + related.entityName?cap_first + "DTO" : true }>
</#if>
<#if isGeneratedApiIdReference(related) && (related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE")>
<#assign relatedEntity = entityMap[related.entityName]>
<#assign imports += {
  entityPackage + "." + relatedEntity.name?cap_first + "Entity" : true,
  persistencePackage + "." + relatedEntity.name?cap_first + "Persistence" : true
}>
</#if>
</#list>

<@import imports/>

@Service
public class ${entity.name?cap_first}ServiceImpl
  extends Base${entity.name?cap_first}ServiceImpl<${entity.name?cap_first}DTO, ${entity.name?cap_first}Entity,${entity.key.type.javaType}>
  implements ${entity.name?cap_first}Service
{
  
  @Autowired
  protected ${entity.name?cap_first}Mapper ${entity.name}Mapper;

<#list entity.relateds as related>
<#if isGeneratedApiIdReference(related) && (related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE")>
  @Autowired
  protected ${related.entityName?cap_first}Persistence ${related.name}Persistence;
</#if>
</#list>
  
  protected ${entity.name?cap_first}Entity toEntity (${entity.name?cap_first}DTO dto) {
    ${entity.name?cap_first}Entity entity = ${entity.name}Mapper.toEntity(dto);
<#list entity.relateds as related>
<#if isGeneratedApiIdReference(related) && (related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE")>
    entity.set${related.name?cap_first}(dto.get${related.name?cap_first}Id() == null
        ? null
        : ${related.name}Persistence.getReferenceById(dto.get${related.name?cap_first}Id()));
</#if>
</#list>
    return entity;
  }
  
  protected List<${entity.name?cap_first}Entity> toEntities (List<${entity.name?cap_first}DTO> dtos) {
    return ${entity.name}Mapper.toEntities(dtos);
  }

  protected ${entity.name?cap_first}DTO toDto (${entity.name?cap_first}Entity entity) {
    return ${entity.name}Mapper.toDto(entity);
  }
  
  protected List<${entity.name?cap_first}DTO> toDtos (List<${entity.name?cap_first}Entity> entities) {
    return ${entity.name}Mapper.toDtos(entities);
  }

<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_MANY" || related.relationshipType.name() == "MANY_TO_MANY">
  protected Collection<${related.entityName?cap_first}DTO> to${related.name?cap_first}Dtos (${entity.name?cap_first}Entity entity) {
    return ${entity.name}Mapper.${related.name}ToDtos(entity.get${related.name?cap_first}());
  }
</#if>
</#list>
}
