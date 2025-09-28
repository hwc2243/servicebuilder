<#include "/entity/table.ftl">
<#include "/entity/builder_class.ftl">
<#include "/entity/builder_constructor.ftl">
package ${localModelPackage};

import java.io.Serializable;

import ${jpaPackage}.Entity;
import ${jpaPackage}.Index;
import ${jpaPackage}.Inheritance;
import ${jpaPackage}.InheritanceType;
import ${jpaPackage}.Table;
import ${jpaPackage}.UniqueConstraint;


import ${baseModelPackage}.Base${entity.name?cap_first};

@Entity
<@table_definition dbName=entity.dbName!"${entity.name}" attributes=entity.attributes uniqueFinders=entity.uniqueFinders/>
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