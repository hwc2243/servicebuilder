package ${baseModelPackage};

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;

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
  @OneToOne
  @JoinColumn(name= "${attribute.name}_id", nullable=true)
  protected Base${attribute.entityName?cap_first} ${attribute.name};
  
<#elseif attribute.relationship.name() == "MANY_TO_ONE">
  @ManyToOne
  @JoinColumn(name= "${attribute.name}_id", nullable=true)
  protected Base${attribute.entityName?cap_first} ${attribute.name};

<#elseif attribute.relationship.name() == "MANY_TO_MANY">
  @ManyToMany
  @JoinTable(name = "${entity.name}_${attribute.entityName}",
             joinColumns = @JoinColumn(name = "${attribute.name}_id"),
             inverseJoinColumns = @JoinColumn(name = "${attribute.entityName}_id"))
  protected List<Base${attribute.entityName?cap_first}> ${attribute.name};

<#elseif attribute.relationship.name() == "ONE_TO_MANY">
  @OneToMany(mappedBy = "Base${entity.name}")
  protected List<Base${attribute.entity_name?cap_first}> ${attribute.name};
  
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