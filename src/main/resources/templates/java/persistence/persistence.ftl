<#include "/functions.ftl">
package ${persistencePackage};
<#assign imports += {
  entityPackage + "." + entity.name?cap_first + "Entity" : true, 
  persistenceBasePackage + ".Base" + entity.name?cap_first + "Persistence": true
}>

<@import imports/>

public interface ${entity.name?cap_first}Persistence extends Base${entity.name?cap_first}Persistence<${entity.name?cap_first}Entity,Long>
{
} 