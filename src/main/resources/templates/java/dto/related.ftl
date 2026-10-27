<#macro related_attribute related>
<#if isTenantKeyOnly(entity, related)>
<#-- The tenant discriminator field already represents this relationship. -->
<#elseif related.keyOnly>
  <#assign relatedEntity = entityMap[related.entityName]>
  protected ${className(relatedEntity.key.type.javaType)} ${related.name}Id;
<#elseif related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE">
  protected ${related.entityName?cap_first}DTO ${related.name};
<#else>
  protected ${related.collectionType.collectionType}<${related.entityName?cap_first}DTO> ${related.name};
</#if>

</#macro>
<#macro related_accessor related>
<#if isTenantKeyOnly(entity, related)>
<#-- The tenant discriminator accessors already represent this relationship. -->
<#elseif related.keyOnly>
  <#assign relatedEntity = entityMap[related.entityName]>
  public ${className(relatedEntity.key.type.javaType)} get${related.name?cap_first}Id ()
  {
    return this.${related.name}Id;
  }

  public void set${related.name?cap_first}Id (${className(relatedEntity.key.type.javaType)} ${related.name}Id)
  {
    this.${related.name}Id = ${related.name}Id;
  }
<#elseif related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE">
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
