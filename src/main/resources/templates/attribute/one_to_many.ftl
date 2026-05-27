<#macro one_to_many_attribute entity related type>
  @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER, orphanRemoval = true)
  @JoinColumn(name = "${entity.name}Id")
  protected ${related.collectionType.collectionType}<${type}> ${related.name};
</#macro>