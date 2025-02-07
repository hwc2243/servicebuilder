<#macro enum_attribute entity attribute>
<#if attribute.dbName?has_content>
  @Column(name="${attribute.dbName}")
<#else>
  @Column
</#if>
  @Enumerated(EnumType.STRING)
  protected ${attribute.enumClass} ${attribute.name};
</#macro>