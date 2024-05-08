package ${baseModelPackage};

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;

import java.util.List;

<#list referencedEntitiesMap[entity.name] as referencedEntity>
import ${localModelPackage}.${referencedEntity.name?cap_first};
</#list>

@Entity
public class Base${entity.name?cap_first} extends AbstractBaseEntity
{
<#list entity.attributes as attribute>
<#if attribute.type != "entity">
  @Column
  protected ${attribute.type} ${attribute.name};

<#elseif attribute.relationship.name() == "ONE_TO_ONE">
<#if attribute.owner>
  @OneToOne(mappedBy = "${entity.name}", cascade = CascadeType.ALL, orphanRemoval = true, fetch=FetchType.LAZY)
<#else>
  @OneToOne(cascade=CascadeType.ALL)
  @JoinColumn(name= "${attribute.name}_id", nullable=true)
</#if>
  protected Base${attribute.entityName?cap_first} ${attribute.name};
  
<#elseif attribute.relationship.name() == "ONE_TO_MANY">
  @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
  @JoinColumn(name = "${entity.name}Id")
  protected List<Base${attribute.entityName?cap_first}> ${attribute.name};
  
<#elseif attribute.relationship.name() == "MANY_TO_ONE">
  @ManyToOne
  @JoinColumn(name= "${attribute.name}Id", nullable=true)
  protected Base${attribute.entityName?cap_first} ${attribute.name};

<#elseif attribute.relationship.name() == "MANY_TO_MANY">
<#if attribute.owner>
  @ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
  @JoinTable(name = "${entity.name}_${attribute.entityName}",
             joinColumns = @JoinColumn(name = "${entity.name}_id"),
             inverseJoinColumns = @JoinColumn(name = "${attribute.entityName}_id"))
  protected List<Base${attribute.entityName?cap_first}> ${attribute.name};
<#else>
  @ManyToMany(mappedBy = "${attribute.mappedBy}")
  protected List<Base${attribute.entityName?cap_first}> ${attribute.name};
</#if>
</#if>
</#list>

<#list entity.attributes as attribute>
<#if attribute.type != "entity">
  public ${attribute.type} get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${attribute.type} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
<#elseif attribute.relationship.name() == "ONE_TO_MANY">
  public List<Base${attribute.entityName?cap_first}> get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (List<Base${attribute.entityName?cap_first}> ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
<#elseif attribute.relationship.name() == "MANY_TO_MANY">
  public List<Base${attribute.entityName?cap_first}> get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (List<Base${attribute.entityName?cap_first}> ${attribute.name})
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