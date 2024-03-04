package ${baseModelPackage};

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

@Entity
public class Base${entity.name?cap_first} extends AbstractBaseEntity
{
<#list entity.attributes as attribute>
  @Column
  protected ${attribute.type} ${attribute.name};

</#list>

<#list entity.attributes as attribute>
  public ${attribute.type} get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${attribute.type} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
  
</#list>
}