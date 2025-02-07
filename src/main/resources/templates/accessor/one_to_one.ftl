<#macro one_to_one_accessors entity related >
  public ${related.entityName?cap_first} get${related.name?cap_first} ()
  {
    return (${related.entityName?cap_first})this.${related.name};
  }
  
  public void set${related.name?cap_first} (${related.entityName?cap_first} ${related.name})
  {
    this.${related.name} = ${related.name};
  }
</#macro>