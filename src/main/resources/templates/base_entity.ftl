package ${baseModelPackage};

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
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

<#else>
  @OneToOne
  @JoinColumn(name= "${attribute.name}_id", nullable=true)
  protected Base${attribute.entityName?cap_first} ${attribute.name};
  
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