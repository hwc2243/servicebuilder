<#macro related_attribute related>
<#if related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE">
  protected ${related.entityName?cap_first}DTO ${related.name};
<#else>
  protected ${related.collectionType.collectionType}<${related.entityName?cap_first}DTO> ${related.name};
</#if>

</#macro>
<#macro related_accessor related>
<#if related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE">
  public ${related.entityName?cap_first}DTO get${related.name?cap_first} ()
  {
    return (${related.entityName?cap_first}DTO)this.${related.name};
  }
  
  public void set${related.name?cap_first} (${related.entityName?cap_first}DTO ${related.name})
  {
    this.${related.name} = ${related.name};
  }
<#else>
  public ${related.collectionType.collectionType}<${related.entityName?cap_first}DTO> get${related.name?cap_first} ()
  {
    return this.${related.name};
  }
  
  public void set${related.name?cap_first} (${related.collectionType.collectionType}<${related.entityName?cap_first}DTO> ${related.name})
  {
    this.${related.name} = ${related.name};
  }
</#if>

</#macro>