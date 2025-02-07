<#macro many_to_one_attribute entity related>
  @ManyToOne
  @JoinColumn(name= "${related.name}Id", nullable=true)
  protected ${related.entityName?cap_first} ${related.name};
</#macro>