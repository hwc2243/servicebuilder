<#macro many_to_many_attribute entity related>
<#if related.owner>
  @ManyToMany(cascade = {CascadeType.MERGE})
  @JoinTable(name = "${entity.name}_${related.entityName}",
             joinColumns = @JoinColumn(name = "${entity.name}_id"),
             inverseJoinColumns = @JoinColumn(name = "${related.entityName}_id"))
  protected ${related.collectionType.collectionType}<${related.entityName?cap_first}> ${related.name};
<#elseif related.mappedBy?has_content>
  @ManyToMany(mappedBy = "${related.mappedBy}")
  protected ${related.collectionType.collectionType}<${related.entityName?cap_first}> ${related.name};
</#if>
</#macro>