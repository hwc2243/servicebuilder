<#macro key_accessors_impl entity key write_get_key=true> 
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
<#macro key_accessors_api entity key write_get_key=true> 
  public ${className(key.type.javaType)} get${key.name?cap_first} ();
  public void set${key.name?cap_first} (${className(key.type.javaType)} ${key.name});
<#if write_get_key>  
  public Object getKey ();
</#if>

</#macro>