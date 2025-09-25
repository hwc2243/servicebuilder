<#macro key_accessors entity key>
  public ${className(key.type.javaType)} get${key.name?cap_first} ()
  {
    return this.${key.name};
  }
  
  public void set${key.name?cap_first} (${className(key.type.javaType)} ${key.name})
  {
    this.${key.name} = ${key.name};
  }
  
  public Object getKey ()
  {
    return this.${key.name};
  }
</#macro>