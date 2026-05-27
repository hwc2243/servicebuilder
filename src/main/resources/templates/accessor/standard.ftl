<#macro standard_accessors_impl entity attribute>
  public ${className(attribute.type.javaType)} get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${className(attribute.type.javaType)} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
  
</#macro>
<#macro standard_accessors_api entity attribute>
  public ${className(attribute.type.javaType)} get${attribute.name?cap_first} ();
  public void set${attribute.name?cap_first} (${className(attribute.type.javaType)} ${attribute.name});
  
</#macro>