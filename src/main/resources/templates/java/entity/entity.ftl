<#include "/functions.ftl">
<#include "/entity/table.ftl">
<#include "/entity/builder_class.ftl">
<#include "/entity/builder_constructor.ftl">
package ${entityPackage};

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<#if attribute.enumClass?has_content>
<#assign imports += { attribute.enumClass : true }>
<#else>
<#assign imports += { modelPackage +"." + entity.name?cap_first + attribute.name?cap_first + "Type" : true }>
</#if>
<#elseif attribute.type.javaType?last_index_of(".") gt 0>
<#assign imports += { attribute.type.javaType : true }>
</#if>
</#list>
<#assign imports +=  {
  jpaPackage + ".Entity" : true,
  jpaPackage + ".Inheritance" : true,
  jpaPackage + ".InheritanceType" : true,
  jpaPackage + ".Table" : true,
  jpaPackage + ".UniqueConstraint" : true,
  "java.io.Serializable" : true,
  modelPackage + "." + entity.name?cap_first : true,
  entityBasePackage + ".Base" + entity.name?cap_first + "Entity": true
}>

<@import imports/>

<#assign modelGenericTypes = []>
<#list entity.relateds as related>
  <#assign modelGenericTypes += [related.entityName?cap_first + "Entity"]>
</#list>
<#assign modelGenericDeclaration = "">
<#if modelGenericTypes?size gt 0>
  <#assign modelGenericDeclaration = "<" + modelGenericTypes?join(", ") + ">">
</#if>
@Entity(name="${entity.name?cap_first}")
<#if entity.dbName?has_content>
<@table_definition dbName=entity.dbName uniqueFinders=entity.uniqueFinders/>
<#else>
<@table_definition dbName=entity.name uniqueFinders=entity.uniqueFinders/>
</#if>
<#if entity.abstractEntity>
@Inheritance(strategy = InheritanceType.JOINED)
</#if>
<#if entity.abstractEntity>
public abstract class ${entity.name?cap_first}Entity<T extends Base${entity.name?cap_first}Entity<T>>
    extends Base${entity.name?cap_first}Entity<T>
<#else>
public class ${entity.name?cap_first}Entity
    extends Base${entity.name?cap_first}Entity<${entity.name?cap_first}Entity>
</#if>
    implements ${entity.name?cap_first}${modelGenericDeclaration}, Serializable
{
	public ${entity.name?cap_first}Entity ()
	{
		super();
	}
	
<@builder_constructor entity=entity/>

<@builder_class entity=entity/>
}