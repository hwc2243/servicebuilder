<#macro many_to_many_accessors entity related >
  public ${related.collectionType.collectionType}<${related.entityName?cap_first}> get${related.name?cap_first} ()
  {
    return this.${related.name};
  }
  
  public void set${related.name?cap_first} (${related.collectionType.collectionType}<${related.entityName?cap_first}> ${related.name})
  {
    this.${related.name} = ${related.name};
  }
</#macro>