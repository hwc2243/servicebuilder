<#macro table_definition dbName uniqueFinders=[]>
@Table(name="${dbName}"<#if uniqueFinders?has_content>,
       uniqueConstraints = {
           <#list uniqueFinders as finder>
               <#-- Generate a unique constraint for each finder -->
               <#-- The columnNames are derived from the 'name' attribute of each finder-attribute -->
               @UniqueConstraint(columnNames = {
                   <#list finder.finderAttributes as finderAttribute>
                       "${finderAttribute.name}"<#if finderAttribute?index < finder.finderAttributes?size - 1>, </#if>
                   </#list>
               })<#if finder?index < uniqueFinders?size - 1>,</#if>
           </#list>
       }
</#if>)
</#macro>