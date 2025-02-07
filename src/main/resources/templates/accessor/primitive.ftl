<#macro primitive_accessors entity attribute>
  public ${className(attribute.type)} get${attribute.name?cap_first} ()
  {
    return this.${attribute.name};
  }
  
  public void set${attribute.name?cap_first} (${className(attribute.type)} ${attribute.name})
  {
    this.${attribute.name} = ${attribute.name};
  }
</#macro>