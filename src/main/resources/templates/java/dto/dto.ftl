<#include "/functions.ftl">
package ${dtoPackage};
<#assign imports +=  {
  dtoBasePackage + ".Base" + entity.name?cap_first + "DTO": true
}>
<#list inheritedAndOwnDtoGenericTypes(entity) as genericType>
  <#assign imports += { dtoPackage + "." + genericType : true }>
</#list>

<@import imports/>

public class ${entity.name?cap_first}DTO extends Base${entity.name?cap_first}DTO
{
  private static final long serialVersionUID = 1L;

  public ${entity.name?cap_first}DTO () {
  }
  
  public ${entity.name?cap_first}DTO (Builder builder) {
    super(builder);
  }
  
  public static class Builder extends Base${entity.name?cap_first}DTO.Builder {
    public ${entity.name?cap_first}DTO build() {
      return new ${entity.name?cap_first}DTO(this);
    }
  }
}