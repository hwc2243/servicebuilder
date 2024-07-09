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
<#if attribute.dbName?has_content>
  @Column(name="${attribute.dbName}")
<#else>
  @Column
</#if>
  @Enumerated(EnumType.STRING)
  protected ${attribute.enumClass} ${attribute.name};
  
<#else>
<#if attribute.dbName?has_content>
  @Column(name="${attribute.dbName}")
<#else>
  @Column
</#if>
  protected ${className(attribute.type)} ${attribute.name};
  
</#if>
</#list>

<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_ONE">
<#if related.owner>
  @OneToOne(mappedBy = "${entity.name}", cascade = CascadeType.ALL, orphanRemoval = true, fetch=FetchType.LAZY)
<#else>
  @OneToOne(cascade=CascadeType.ALL)
  @JoinColumn(name= "${related.name}_id", nullable=true)
</#if>
  protected ${related.entityName?cap_first} ${related.name};
  
<#elseif related.relationshipType.name() == "ONE_TO_MANY">
  @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
  @JoinColumn(name = "${entity.name}Id")
  protected ${related.collectionType.collectionType}<${related.entityName?cap_first}> ${related.name};
  
<#elseif related.relationshipType.name() == "MANY_TO_ONE">
  @ManyToOne
  @JoinColumn(name= "${related.name}Id", nullable=true)
  protected ${related.entityName?cap_first} ${related.name};

<#elseif related.relationshipType.name() == "MANY_TO_MANY">
<#if related.owner>
  @ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
  @JoinTable(name = "${entity.name}_${related.entityName}",
             joinColumns = @JoinColumn(name = "${entity.name}_id"),
             inverseJoinColumns = @JoinColumn(name = "${related.entityName}_id"))
  protected ${related.collectionType.collectionType}<${related.entityName?cap_first}> ${related.name};
<#elseif related.mappedBy?has_content>
  @ManyToMany(mappedBy = "${related.mappedBy}")
  protected ${related.collectionType.collectionType}<${related.entityName?cap_first}> ${related.name};
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
<#else>
  public ${className(attribute.type)} get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${className(attribute.type)} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
</#if>
</#list>
<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_MANY">
  public ${related.collectionType.collectionType}<${related.entityName?cap_first}> get${related.name?cap_first} ()
  {
    return this.${related.name};
  }
  
  public void set${related.name?cap_first} (${related.collectionType.collectionType}<${related.entityName?cap_first}> ${related.name})
  {
    this.${related.name} = ${related.name};
  }
<#elseif related.relationshipType.name() == "MANY_TO_MANY">
  public ${related.collectionType.collectionType}<${related.entityName?cap_first}> get${related.name?cap_first} ()
  {
    return this.${related.name};
  }
  
  public void set${related.name?cap_first} (${related.collectionType.collectionType}<${related.entityName?cap_first}> ${related.name})
  {
    this.${related.name} = ${related.name};
  }
<#else>
  public ${related.entityName?cap_first} get${related.name?cap_first} ()
  {
    return (${related.entityName?cap_first})this.${related.name};
  }
  
  public void set${related.name?cap_first} (${related.entityName?cap_first} ${related.name})
  {
    this.${related.name} = ${related.name};
  }
</#if>

</#list>
}