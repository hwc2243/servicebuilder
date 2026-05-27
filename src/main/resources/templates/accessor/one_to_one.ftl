<#macro one_to_one_accessors_impl entity related type>
  public ${type} get${related.name?cap_first} ()
  {
    return this.${related.name};
  }
  
  public void set${related.name?cap_first} (${type} ${related.name})
  {
    this.${related.name} = ${related.name};
  }
</#macro>
<#macro one_to_one_accessors_api entity related type>
  public ${type} get${related.name?cap_first} ();
  public void set${related.name?cap_first} (${type} ${related.name});

</#macro>