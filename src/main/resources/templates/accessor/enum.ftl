<#macro enum_accessors_impl entity attribute>
<#if attribute.enumClass?has_content>
  public ${attribute.enumClass} get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${attribute.enumClass} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
<#else>
  public ${entity.name?cap_first}${attribute.name?cap_first}Type get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${entity.name?cap_first}${attribute.name?cap_first}Type ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
</#if>
</#macro>
<#macro enum_accessors_api entity attribute>
<#if attribute.enumClass?has_content>
  public ${attribute.enumClass} get${attribute.name?cap_first} ();
  public void set${attribute.name?cap_first} (${attribute.enumClass} ${attribute.name});

<#else>
  public ${entity.name?cap_first}${attribute.name?cap_first}Type get${attribute.name?cap_first} ();
  public void set${attribute.name?cap_first} (${entity.name?cap_first}${attribute.name?cap_first}Type ${attribute.name});
  
</#if>
</#macro>