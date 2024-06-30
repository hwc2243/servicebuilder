<#include "/functions.ftl">
package ${baseModelPackage};

<#list entity.attributes as attribute>
<#if attribute.type == "enum">
import ${attribute.enumClass};
<#elseif attribute.type?last_index_of(".") gt 0>
import ${attribute.type};
</#if>
</#list>
import ${jpaPackage}.CascadeType;
import ${jpaPackage}.Column;
import ${jpaPackage}.Entity;
import ${jpaPackage}.Enumerated;
import ${jpaPackage}.EnumType;
import ${jpaPackage}.FetchType;
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

import java.util.List;
import java.util.Set;

import ${localModelPackage}.${entity.name?cap_first};
<#list referencedEntitiesMap[entity.name] as referencedEntity>
import ${localModelPackage}.${referencedEntity.name?cap_first};
</#list>
<#if entity.parent??>
import ${localModelPackage}.${entity.parent?cap_first};
</#if>


/*
@Entity
@Table (name="${entity.name}")
<#if entity.abstractEntity>
@Inheritance(strategy = InheritanceType.JOINED)
</#if>
*/
@MappedSuperclass
<#if entity.parent??>
public abstract class Base${entity.name?cap_first}<T extends Base${entity.name?cap_first}> extends ${entity.parent?cap_first}<T>
<#else>
public abstract class Base${entity.name?cap_first}<T extends Base${entity.name?cap_first}> extends AbstractBaseEntity
</#if>
{
<#list entity.attributes as attribute>
<#if attribute.type == "enum">
  @Column
  @Enumerated(EnumType.STRING)
  protected ${attribute.enumClass} ${attribute.name};
  
<#elseif attribute.type != "entity">
  @Column
  protected ${className(attribute.type)} ${attribute.name};

<#elseif attribute.relationship.name() == "ONE_TO_ONE">
<#if attribute.owner>
  @OneToOne(mappedBy = "${entity.name}", cascade = CascadeType.ALL, orphanRemoval = true, fetch=FetchType.LAZY)
<#else>
  @OneToOne(cascade=CascadeType.ALL)
  @JoinColumn(name= "${attribute.name}_id", nullable=true)
</#if>
  protected ${attribute.entityName?cap_first} ${attribute.name};
  
<#elseif attribute.relationship.name() == "ONE_TO_MANY">
  @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
  @JoinColumn(name = "${entity.name}Id")
  protected ${attribute.collectionType.collectionType}<${attribute.entityName?cap_first}> ${attribute.name};
  
<#elseif attribute.relationship.name() == "MANY_TO_ONE">
  @ManyToOne
  @JoinColumn(name= "${attribute.name}Id", nullable=true)
  protected ${attribute.entityName?cap_first} ${attribute.name};

<#elseif attribute.relationship.name() == "MANY_TO_MANY">
<#if attribute.owner>
  @ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
  @JoinTable(name = "${entity.name}_${attribute.entityName}",
             joinColumns = @JoinColumn(name = "${entity.name}_id"),
             inverseJoinColumns = @JoinColumn(name = "${attribute.entityName}_id"))
  protected ${attribute.collectionType.collectionType}<${attribute.entityName?cap_first}> ${attribute.name};
<#elseif attribute.mappedBy?has_content>
  @ManyToMany(mappedBy = "${attribute.mappedBy}")
  protected ${attribute.collectionType.collectionType}<${attribute.entityName?cap_first}> ${attribute.name};
</#if>
</#if>
</#list>

<#list entity.attributes as attribute>
<#if attribute.type == "enum">
  public ${attribute.enumClass} get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${attribute.enumClass} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
<#elseif attribute.type != "entity">
  public ${className(attribute.type)} get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${className(attribute.type)} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
<#elseif attribute.relationship.name() == "ONE_TO_MANY">
  public ${attribute.collectionType.collectionType}<${attribute.entityName?cap_first}> get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${attribute.collectionType.collectionType}<${attribute.entityName?cap_first}> ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
<#elseif attribute.relationship.name() == "MANY_TO_MANY">
  public ${attribute.collectionType.collectionType}<${attribute.entityName?cap_first}> get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${attribute.collectionType.collectionType}<${attribute.entityName?cap_first}> ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
<#else>
  public ${attribute.entityName?cap_first} get${attribute.name?cap_first} ()
  {
    return (${attribute.entityName?cap_first})this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${attribute.entityName?cap_first} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
</#if>

</#list>
}