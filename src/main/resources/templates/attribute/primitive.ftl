<#macro primitive_attribute entity attribute>
  <#if attribute.dbName?has_content>
  @Column(name="${attribute.dbName}")
  <#else>
  @Column
  </#if>
  protected ${className(attribute.type.javaType)} ${attribute.name};
</#macro>