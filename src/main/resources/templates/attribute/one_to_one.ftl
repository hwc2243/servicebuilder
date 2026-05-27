<#macro one_to_one_attribute entity related type>
<#if related.owner>
  @OneToOne(mappedBy = "${entity.name}", cascade = CascadeType.ALL, orphanRemoval = true, fetch=FetchType.LAZY)
<#else>
  @OneToOne(cascade=CascadeType.ALL)
  @JoinColumn(name= "${related.name}_id", nullable=true)
</#if>
  protected ${type} ${related.name};
</#macro>