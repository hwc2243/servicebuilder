<#macro enum_attribute entity attribute>
<#if attribute.dbName?has_content>
  @Column(name="${attribute.dbName}")
<#else>
  @Column
</#if>
  @Enumerated(EnumType.STRING)
<#if attribute.enumClass?has_content>
  protected ${attribute.enumClass} ${attribute.name} = null;
<#else>
  protected ${attribute.name?cap_first}Type ${attribute.name} = null;
</#if>
</#macro>