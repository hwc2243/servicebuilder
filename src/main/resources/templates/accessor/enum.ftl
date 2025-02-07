<#macro enum_accessors entity attribute>
  public ${attribute.enumClass} get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${attribute.enumClass} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
</#macro>
