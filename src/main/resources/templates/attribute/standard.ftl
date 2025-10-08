<#macro standard_attribute entity attribute>
  <#if attribute.dbName?has_content>
  @Column(name="${attribute.dbName}"
    <#if attribute.type == "MONEY">
      , precision = 10, scale = 2
    </#if>
    )
  <#elseif attribute.type == "MONEY">
  @Column(precision = 10, scale = 2)
  <#else>
  @Column
  </#if>
  protected ${className(attribute.type.javaType)} ${attribute.name} = null;
</#macro>