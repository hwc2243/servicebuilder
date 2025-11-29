<#macro key_attribute entity key>
  @Id
  <#if key.dbName?has_content>
  @Column(name="${key.dbName}")
  <#else>
  @Column
  </#if>
  <#if key.type.javaType == "Long" || key.type.javaType == "Integer">
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  </#if>
  protected ${className(key.type.javaType)} ${key.name} = null;
</#macro>
<#macro client_key_attribute entity key>
  @Id
  <#if key.dbName?has_content>
  @Column(name="${key.dbName}")
  <#else>
  @Column
  </#if>
  protected ${className(key.type.javaType)} ${key.name} = null;
</#macro>
