<#macro many_to_many_accessors_impl entity related type>
  public ${related.collectionType.collectionType}<${type}> get${related.name?cap_first} ()
  {
    return this.${related.name};
  }
  
  public void set${related.name?cap_first} (${related.collectionType.collectionType}<${type}> ${related.name})
  {
    this.${related.name} = ${related.name};
  }
</#macro>
<#macro many_to_many_accessors_api entity related type>
  public ${related.collectionType.collectionType}<${type}> get${related.name?cap_first} ();
  public void set${related.name?cap_first} (${related.collectionType.collectionType}<${type}> ${related.name});

</#macro>