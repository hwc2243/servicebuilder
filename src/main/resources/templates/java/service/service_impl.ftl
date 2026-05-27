<#include "/functions.ftl">
package ${servicePackage};
<#assign imports +=  {
  "java.util.List": true,
  "org.springframework.beans.factory.annotation.Autowired" : true,
  "org.springframework.stereotype.Service": true,
  serviceBasePackage + ".Base" + entity.name?cap_first + "ServiceImpl": true,
  dtoPackage + "." + entity.name?cap_first + "DTO": true,
  entityPackage + "." + entity.name?cap_first + "Entity": true
 }>

<@import imports/>

@Service
public class ${entity.name?cap_first}ServiceImpl
  extends Base${entity.name?cap_first}ServiceImpl<${entity.name?cap_first}DTO, ${entity.name?cap_first}Entity,${entity.key.type.javaType}>
  implements ${entity.name?cap_first}Service
{
  
  @Autowired
  protected ${entity.name?cap_first}Mapper ${entity.name}Mapper;
  
  protected ${entity.name?cap_first}Entity toEntity (${entity.name?cap_first}DTO dto) {
    return ${entity.name}Mapper.toEntity(dto);
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
}