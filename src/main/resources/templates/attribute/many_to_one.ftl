<#macro many_to_one_attribute entity related type>
  @ManyToOne
  @JoinColumn(name= "${related.name}Id", nullable=true)
  protected ${type} ${related.name};
</#macro>