<#include "/functions.ftl">
<#include "/accessor/key.ftl">
<#include "/dto/builder.ftl">
<#include "/dto/related.ftl">
package ${dtoPackage};

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<#if attribute.enumClass?has_content>
import ${attribute.enumClass};
<#else>
import ${dtoPackage}.${attribute.name?cap_first}Type;
</#if>
<#elseif attribute.type.javaType?last_index_of(".") gt 0>
import ${attribute.type.javaType};
</#if>
</#list>

import java.util.List;

public class ${entity.name?cap_first}DTO
{
  protected ${className(entity.key.type.javaType)} ${entity.key.name};

<#list entity.attributes as attribute>
<#assign attributeType = attributeTypeClass(attribute)>
  protected ${attributeType} ${attribute.name} = null;
  
</#list>
<#list entity.relateds as related>
<@related_attribute related=related/>
</#list>

  public ${entity.name?cap_first}DTO () {
  }
  
<@builder_constructor entity=entity/>

<@key_accessors entity=entity key=entity.key write_get_key=false />

<#list entity.attributes as attribute>
<#assign attributeType = attributeTypeClass(attribute)>
  public ${attributeType} get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${attributeType} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
  
</#list>
<#list entity.relateds as related>
<@related_accessor related=related/>
</#list>
<@builder_class entity=entity/>
}