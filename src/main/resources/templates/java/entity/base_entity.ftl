<#include "/functions.ftl">
<#include "/entity/equals_hashcode.ftl">
<#include "/attribute/enum.ftl">
<#include "/attribute/key.ftl">
<#include "/attribute/standard.ftl">
<#include "/attribute/one_to_one.ftl">
<#include "/attribute/one_to_many.ftl">
<#include "/attribute/many_to_one.ftl">
<#include "/attribute/many_to_many.ftl">
<#include "/accessor/enum.ftl">
<#include "/accessor/key.ftl">
<#include "/accessor/standard.ftl">
<#include "/accessor/one_to_one.ftl">
<#include "/accessor/one_to_many.ftl">
<#include "/accessor/many_to_one.ftl">
<#include "/accessor/many_to_many.ftl">
package ${entityBasePackage};

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<#if attribute.enumClass?has_content>
<#assign imports += { attribute.enumClass : true }>
<#else>
<#assign imports += { modelPackage +"." + entity.name?cap_first + attribute.name?cap_first : true }>
</#if>
<#elseif attribute.type.javaType?last_index_of(".") gt 0>
<#assign imports += { attribute.type.javaType : true }>
</#if>
</#list>
<#if entity.multitenant>
<#assign imports += { modelBasePackage + ".Multitenant" : true }>
</#if>
<#if entity.key.type.value == "uuid">
<#assign imports += { "java.util.UUID" : true }>
</#if>
<#list referencedEntitiesMap[entity.name] as referencedEntity>
<#assign imports += { entityPackage + "." + referencedEntity.name?cap_first + "Entity" : true }>
</#list>
<#if entity.parent?has_content>
<#assign imports += { entityBasePackage + ".Base" + entity.parent?cap_first + "Entity" : true }>
</#if>
<#assign imports +=  {
  jpaPackage + ".CascadeType" : true,
  jpaPackage + ".Column" : true,
  jpaPackage + ".Entity" : true,
  jpaPackage + ".Enumerated" : true,
  jpaPackage + ".EnumType" : true,
  jpaPackage + ".FetchType" : true,
  jpaPackage + ".GeneratedValue" : true,
  jpaPackage + ".GenerationType" : true,
  jpaPackage + ".Id" : true,
  jpaPackage + ".Inheritance" : true,
  jpaPackage + ".InheritanceType" : true,
  jpaPackage + ".JoinColumn" : true,
  jpaPackage + ".JoinTable" : true,
  jpaPackage + ".ManyToMany" : true,
  jpaPackage + ".ManyToOne" : true,
  jpaPackage + ".MappedSuperclass" : true,
  jpaPackage + ".OneToMany" : true,
  jpaPackage + ".OneToOne" : true,
  jpaPackage + ".Table" : true,
  "java.io.Serializable" : true,
  "java.util.List": true,
  "java.util.Objects" : true,
  "java.util.Set" : true,
  modelPackage + "." + entity.name?cap_first: true,
  modelBasePackage + ".Base" + entity.name?cap_first: true
}>
<#list inheritedAndOwnEntityGenericTypes(entity) as genericType>
  <#assign imports += { entityPackage + "." + genericType : true }>
</#list>

<@import imports/>

<#assign modelGenericDeclaration = asGenericDeclaration(inheritedAndOwnEntityGenericTypes(entity))>
@MappedSuperclass
<#if entity.parent?has_content>
public abstract class Base${entity.name?cap_first}Entity<T extends Base${entity.name?cap_first}Entity<T>>
  extends Base${entity.parent?cap_first}Entity<T>
<#else>
public abstract class Base${entity.name?cap_first}Entity<T extends Base${entity.name?cap_first}Entity<T>> extends AbstractBaseEntity
</#if>
    implements Base${entity.name?cap_first}${modelGenericDeclaration}, <#if entity.multitenant>Multitenant, </#if>Serializable
{
<@key_attribute entity entity.key/>

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<@enum_attribute entity=entity attribute=attribute/>
  
<#else>
<@standard_attribute entity=entity attribute=attribute/>
  
</#if>
</#list>

<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_ONE">
<@one_to_one_attribute entity=entity related=related type=related.entityName?cap_first + "Entity"/>
  
<#elseif related.relationshipType.name() == "ONE_TO_MANY">
<@one_to_many_attribute entity=entity related=related type=related.entityName?cap_first + "Entity"/>
  
<#elseif related.relationshipType.name() == "MANY_TO_ONE">
<@many_to_one_attribute entity=entity related=related type=related.entityName?cap_first + "Entity"/>

<#elseif related.relationshipType.name() == "MANY_TO_MANY">
<@many_to_many_attribute entity=entity related=related type=related.entityName?cap_first + "Entity"/>

</#if>
</#list>
<#if entity.key.type.value == "uuid">
  public Base${entity.name?cap_first}Entity ()
  {
    if (${entity.key.name} == null || "".equals(${entity.key.name})) {
      ${entity.key.name} = UUID.randomUUID().toString();
    }
  }
</#if>
  
<@key_accessors_impl entity=entity key=entity.key/>

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<@enum_accessors_impl entity=entity attribute=attribute/>

<#else>
<@standard_accessors_impl entity=entity attribute=attribute/>

</#if>
</#list>
<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_ONE">
<@one_to_one_accessors_impl entity=entity related=related type=related.entityName?cap_first + "Entity"/>

<#elseif related.relationshipType.name() == "ONE_TO_MANY">
<@one_to_many_accessors_impl entity=entity related=related type=related.entityName?cap_first + "Entity"/>

<#elseif related.relationshipType.name() == "MANY_TO_ONE">
<@many_to_one_accessors_impl entity=entity related=related type=related.entityName?cap_first + "Entity"/>

<#elseif related.relationshipType.name() == "MANY_TO_MANY">
<@many_to_many_accessors_impl entity=entity related=related type=related.entityName?cap_first + "Entity"/>

<#else>
</#if>

</#list>

<@equals_hashcode entity=entity key=entity.key/>

}