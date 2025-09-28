<#include "/functions.ftl">
<#include "entity/equals_hashcode.ftl">
<#include "/attribute/enum.ftl">
<#include "/attribute/key.ftl">
<#include "/attribute/primitive.ftl">
<#include "/attribute/one_to_one.ftl">
<#include "/attribute/one_to_many.ftl">
<#include "/attribute/many_to_one.ftl">
<#include "/attribute/many_to_many.ftl">
<#include "/accessor/enum.ftl">
<#include "/accessor/key.ftl">
<#include "/accessor/primitive.ftl">
<#include "/accessor/one_to_one.ftl">
<#include "/accessor/one_to_many.ftl">
<#include "/accessor/many_to_one.ftl">
<#include "/accessor/many_to_many.ftl">
package ${baseModelPackage};

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
import ${jpaPackage}.CascadeType;
import ${jpaPackage}.Column;
import ${jpaPackage}.Entity;
import ${jpaPackage}.Enumerated;
import ${jpaPackage}.EnumType;
import ${jpaPackage}.FetchType;
import ${jpaPackage}.GeneratedValue;
import ${jpaPackage}.GenerationType;
import ${jpaPackage}.Id;
import ${jpaPackage}.Inheritance;
import ${jpaPackage}.InheritanceType;
import ${jpaPackage}.JoinColumn;
import ${jpaPackage}.JoinTable;
import ${jpaPackage}.ManyToMany;
import ${jpaPackage}.ManyToOne;
import ${jpaPackage}.MappedSuperclass;
import ${jpaPackage}.OneToMany;
import ${jpaPackage}.OneToOne;
import ${jpaPackage}.Table;
<#if entity.multitenant>

import ${multitenantPackage}.Multitenant;

</#if>
import java.io.Serializable;

import java.util.List;
import java.util.Objects;
import java.util.Set;

import ${localModelPackage}.${entity.name?cap_first};
<#list referencedEntitiesMap[entity.name] as referencedEntity>
import ${localModelPackage}.${referencedEntity.name?cap_first};
</#list>
<#if entity.parent??>
import ${localModelPackage}.${entity.parent?cap_first};
</#if>

@MappedSuperclass
<#if entity.parent??>
public abstract class Base${entity.name?cap_first}<T extends Base${entity.name?cap_first}> extends ${entity.parent?cap_first}<T>
<#else>
public abstract class Base${entity.name?cap_first}<T extends Base${entity.name?cap_first}> extends AbstractBaseEntity
</#if>
    implements <#if entity.multitenant>Multitenant, </#if>Serializable
{
<@key_attribute entity entity.key/>

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<@enum_attribute entity=entity attribute=attribute/>
  
<#else>
<@primitive_attribute entity=entity attribute=attribute/>
  
</#if>
</#list>

<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_ONE">
<@one_to_one_attribute entity=entity related=related/>
  
<#elseif related.relationshipType.name() == "ONE_TO_MANY">
<@one_to_many_attribute entity=entity related=related/>
  
<#elseif related.relationshipType.name() == "MANY_TO_ONE">
<@many_to_one_attribute entity=entity related=related/>

<#elseif related.relationshipType.name() == "MANY_TO_MANY">
<@many_to_many_attribute entity=entity related=related/>

</#if>
</#list>

<@key_accessors entity=entity key=entity.key/>

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<@enum_accessors entity=entity attribute=attribute/>

<#else>
<@primitive_accessors entity=entity attribute=attribute/>

</#if>
</#list>
<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_ONE">
<@one_to_one_accessors entity=entity related=related/>

<#elseif related.relationshipType.name() == "ONE_TO_MANY">
<@one_to_many_accessors entity=entity related=related/>

<#elseif related.relationshipType.name() == "MANY_TO_ONE">
<@many_to_one_accessors entity=entity related=related/>

<#elseif related.relationshipType.name() == "MANY_TO_MANY">
<@many_to_many_accessors entity=entity related=related/>

<#else>
</#if>

</#list>

<@equals_hashcode entity=entity key=entity.key/>

}