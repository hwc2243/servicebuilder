<#macro primitive_attribute entity attribute>
  @Column<#if attribute.dbName?has_content>(name="${attribute.dbName}")</#if>
  protected ${className(attribute.type.javaType)} ${attribute.name} = null;
</#macro>