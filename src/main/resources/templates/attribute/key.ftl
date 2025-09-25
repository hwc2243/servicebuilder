<#macro key_attribute entity key>
  @Id
  <#if key.dbName?has_content>
  @Column(name="${key.dbName}")
  <#else>
  @Column
  </#if>
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  protected ${className(key.type.javaType)} ${key.name} = null;
</#macro>