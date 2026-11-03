<#macro standard_attribute entity attribute>
  <#if attribute.dbName?has_content>
  @Column(name="${attribute.dbName}"
    <#if attribute.type == "MONEY">
      , precision = 10, scale = 2
    </#if>
    <#if isTenantDiscriminatorAttribute(entity, attribute)>, insertable = false, updatable = false</#if>
    )
  <#elseif attribute.type == "MONEY">
  @Column(precision = 10, scale = 2)
  <#else>
  @Column<#if isTenantDiscriminatorAttribute(entity, attribute)>(insertable = false, updatable = false)</#if>
  </#if>
  protected ${className(attribute.type.javaType)} ${attribute.name} = null;
</#macro>
