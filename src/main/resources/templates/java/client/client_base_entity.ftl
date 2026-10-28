<#include "/functions.ftl">
<#include "/java/server/entity/equals_hashcode.ftl">
<#include "/java/server/attribute/enum.ftl">
<#include "/java/server/attribute/key.ftl">
<#include "/java/server/attribute/standard.ftl">
<#include "/java/server/attribute/one_to_one.ftl">
<#include "/java/server/attribute/one_to_many.ftl">
<#include "/java/server/attribute/many_to_one.ftl">
<#include "/java/server/attribute/many_to_many.ftl">
<#include "/java/server/accessor/enum.ftl">
<#include "/java/server/accessor/key.ftl">
<#include "/java/server/accessor/standard.ftl">
<#include "/java/server/accessor/one_to_one.ftl">
<#include "/java/server/accessor/one_to_many.ftl">
<#include "/java/server/accessor/many_to_one.ftl">
<#include "/java/server/accessor/many_to_many.ftl">
package ${clientBaseModelPackage};

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

import java.io.Serializable;

import java.util.List;
import java.util.Objects;
import java.util.Set;
<#if entity.key.type.value == "uuid">
import java.util.UUID;
</#if>

import ${clientModelPackage}.${entity.name?cap_first};
<#list referencedEntitiesMap[entity.name] as referencedEntity>
import ${clientModelPackage}.${referencedEntity.name?cap_first};
</#list>
<#if entity.parent??>
import ${clientModelPackage}.${entity.parent?cap_first};
</#if>
<#if entity.multitenant>

import ${clientBaseModelPackage}.Multitenant;
</#if>

@MappedSuperclass
<#if entity.parent??>
public abstract class Base${entity.name?cap_first}<T extends Base${entity.name?cap_first}> extends ${entity.parent?cap_first}<T>
<#else>
public abstract class Base${entity.name?cap_first}<T extends Base${entity.name?cap_first}> extends AbstractBaseEntity
</#if>
    implements <#if entity.multitenant>Multitenant, </#if>Serializable
{
<@client_key_attribute entity entity.key/>

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<@enum_attribute entity=entity attribute=attribute/>
  
<#else>
<@standard_attribute entity=entity attribute=attribute/>
  
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
<#if entity.key.type.value == "uuid">
  public Base${entity.name?cap_first} ()
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
<@one_to_one_accessors_impl entity=entity related=related/>

<#elseif related.relationshipType.name() == "ONE_TO_MANY">
<@one_to_many_accessors_impl entity=entity related=related/>

<#elseif related.relationshipType.name() == "MANY_TO_ONE">
<@many_to_one_accessors_impl entity=entity related=related/>

<#elseif related.relationshipType.name() == "MANY_TO_MANY">
<@many_to_many_accessors_impl entity=entity related=related/>

<#else>
</#if>

</#list>

<@equals_hashcode entity=entity key=entity.key/>

}
