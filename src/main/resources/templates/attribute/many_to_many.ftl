<#macro many_to_many_attribute entity related type>
<#if related.owner>
  @ManyToMany(cascade = {CascadeType.MERGE})
  @JoinTable(name = "${entity.name}_${related.entityName}",
             joinColumns = @JoinColumn(name = "${entity.name}_id"),
             inverseJoinColumns = @JoinColumn(name = "${related.entityName}_id"))
  protected ${related.collectionType.collectionType}<${type}> ${related.name};
<#elseif related.mappedBy?has_content>
  @ManyToMany(mappedBy = "${related.mappedBy}")
  protected ${related.collectionType.collectionType}<${type}> ${related.name};
</#if>
</#macro>