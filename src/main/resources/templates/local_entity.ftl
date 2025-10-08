<#include "/functions.ftl">
<#include "/entity/table.ftl">
<#include "/entity/builder_class.ftl">
<#include "/entity/builder_constructor.ftl">
package ${localModelPackage};

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<#if attribute.enumClass?has_content>
import ${attribute.enumClass};
<#else>
import ${localModelPackage}.${attribute.name?cap_first}Type;
</#if>
<#elseif attribute.type.javaType?last_index_of(".") gt 0>
import ${attribute.type.javaType};
</#if>
</#list>

import java.io.Serializable;

import ${jpaPackage}.Entity;
import ${jpaPackage}.Inheritance;
import ${jpaPackage}.InheritanceType;
import ${jpaPackage}.Table;
import ${jpaPackage}.UniqueConstraint;


import ${baseModelPackage}.Base${entity.name?cap_first};

@Entity
<#if entity.dbName?has_content>
<@table_definition dbName=entity.dbName uniqueFinders=entity.uniqueFinders/>
<#else>
<@table_definition dbName=entity.name uniqueFinders=entity.uniqueFinders/>
</#if>
<#if entity.abstractEntity>
@Inheritance(strategy = InheritanceType.JOINED)
</#if>
<#if entity.abstractEntity>
public abstract class ${entity.name?cap_first}<T extends Base${entity.name?cap_first}> extends Base${entity.name?cap_first}<T>
<#else>
public class ${entity.name?cap_first} extends Base${entity.name?cap_first}<${entity.name?cap_first}>
</#if>
    implements Serializable
{
	public ${entity.name?cap_first} ()
	{
		super();
	}
	
<@builder_constructor entity=entity/>

<@builder_class entity=entity/>
}