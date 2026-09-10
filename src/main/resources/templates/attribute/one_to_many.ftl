<#macro one_to_many_attribute entity related type>
<#if related.mappedBy?has_content>
  @OneToMany(mappedBy = "${related.mappedBy}", cascade = CascadeType.ALL, fetch = FetchType.EAGER, orphanRemoval = true)
<#else>
  @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER, orphanRemoval = true)
  @JoinColumn(name = "${entity.name}Id")
</#if>
  protected ${related.collectionType.collectionType}<${type}> ${related.name};
</#macro>
