<#macro one_to_many_attribute entity related>
  @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
  @JoinColumn(name = "${entity.name}Id")
  protected ${related.collectionType.collectionType}<${related.entityName?cap_first}> ${related.name};
</#macro>