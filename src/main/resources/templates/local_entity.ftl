<#assign referencedTypes = "">
<#if referencedEntitiesMap[entity.name]?has_content>
<#assign referencedTypes += "<">
<#list referencedEntitiesMap[entity.name] as referencedEntity>
<#assign referencedTypes += referencedEntity.name?cap_first>
</#list>
<#assign referencedTypes += ">">
</#if>
package ${localModelPackage};

import jakarta.persistence.Entity;

import ${baseModelPackage}.Base${entity.name?cap_first};

@Entity
public class ${entity.name?cap_first} extends Base${entity.name?cap_first}
{
}