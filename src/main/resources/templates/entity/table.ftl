<#macro table_definition dbName attributes=[] uniqueFinders=[]>
<#assign indexedAttributes = attributes?filter(a -> a.indexed)>
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
 </#if><#if indexedAttributes?has_content>,
       indexes = {
           <#list indexedAttributes as attribute>
               <#-- Use dbName if it's set, otherwise use the attribute name -->
               <#assign columnName = attribute.dbName!"${attribute.name}">
               @Index(name = "idx_${attribute.name}", columnList = "${columnName}")<#if attribute?index < indexedAttributes?size - 1>,</#if>
           </#list>
       }
</#if>)
</#macro>