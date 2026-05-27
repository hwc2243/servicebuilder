<#include "/functions.ftl">
package ${servicePackage};
<#assign imports +=  {
  serviceBasePackage + ".Base" + entity.name?cap_first + "Service" : true,
  dtoPackage + "." + entity.name?cap_first + "DTO" : true
 }>

<@import imports/>

public interface ${entity.name?cap_first}Service extends Base${entity.name?cap_first}Service<${entity.name?cap_first}DTO,${entity.key.type.javaType}>
{
}