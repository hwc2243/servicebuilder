<#macro key_accessors entity key write_get_key=true> 
  public ${className(key.type.javaType)} get${key.name?cap_first} ()
  {
    return this.${key.name};
  }
  
  public void set${key.name?cap_first} (${className(key.type.javaType)} ${key.name})
  {
    this.${key.name} = ${key.name};
  }

<#if write_get_key>  
  public Object getKey ()
  {
    return this.${key.name};
  }
</#if>
</#macro>