<#macro enum_accessors entity attribute>
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
  public ${attribute.name?cap_first}Type get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${attribute.name?cap_first}Type ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
</#if>
</#macro>
