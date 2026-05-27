<#macro builder_class entity>
  public abstract static class Builder {

  <@key_attribute entity=entity key=entity.key visibility="private"/>

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
  <@enum_attribute entity=entity attribute=attribute visibility="private"/>
  
<#else>
  <@standard_attribute entity=entity attribute=attribute visibility="private"/>
  
</#if>
</#list>

<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE">
    private ${related.entityName?cap_first}DTO ${related.name} = null;
<#else>
    private ${related.collectionType.collectionType}<${related.entityName?cap_first}DTO> ${related.name} = null;
</#if>
</#list>

    public Builder ${entity.key.name}(${entity.key.type.javaType} ${entity.key.name}) {
      this.${entity.key.name} = ${entity.key.name};
      return this;
    }
    
<#list entity.attributes as attribute>
<#assign fieldType = (attribute.type == "ENUM")?then((attribute.enumClass?has_content)?then(attribute.enumClass, entity.name?cap_first + attribute.name?cap_first + "Type"), attribute.type.javaType)>
    public Builder ${attribute.name}(${className(fieldType)} ${attribute.name}) {
      this.${attribute.name} = ${attribute.name};
      return this;
    }

</#list>
<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_ONE" || related.relationshipType.name() == "MANY_TO_ONE">
    public Builder ${related.name}(${related.entityName?cap_first}DTO ${related.name}) {
      this.${related.name} = ${related.name};
      return this;
    }
<#else>
    public Builder ${related.name}(${related.collectionType.collectionType}<${related.entityName?cap_first}DTO> ${related.name}) {
      this.${related.name} = ${related.name};
      return this;
    }
</#if>
</#list>
    /**
     * The build method creates and returns the immutable Entity object.
     */
    public abstract ${entity.name?cap_first}DTO build();
  }
</#macro>

<#macro builder_constructor entity>
  // Private constructor to force the use of the Builder
  protected Base${entity.name?cap_first}DTO (Builder builder)
  {
    this.${entity.key.name} = builder.${entity.key.name};
    <#-- Assign the builder's properties to the entity's properties -->
<#list entity.attributes as attribute>
    this.${attribute.name} = builder.${attribute.name};
</#list>
<#list entity.relateds as related>
    this.${related.name} = builder.${related.name};
</#list>
  }
</#macro>