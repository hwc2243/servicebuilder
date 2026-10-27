<#macro table_definition entity dbName uniqueFinders=[]>
@Table(name="${dbName}"<#if uniqueFinders?has_content>,
       uniqueConstraints = {
           <#list uniqueFinders as finder>
               <#-- Generate a unique constraint for each finder -->
               <#-- The columnNames are derived from the 'name' attribute of each finder-attribute -->
               @UniqueConstraint(columnNames = {
                   <#list finder.finderAttributes as finderAttribute>
                       <#assign finderRelated = inheritedRelated(entity, finderAttribute.name)>
                       <#if finderRelated?has_content>
                       "${finderRelated.name}_id"<#if finderAttribute?index < finder.finderAttributes?size - 1>, </#if>
                       <#else>
                       <#assign finderAttributeModel = inheritedAttribute(entity, finderAttribute.name)>
                       "<#if finderAttributeModel.dbName?has_content>${finderAttributeModel.dbName}<#else>${finderAttributeModel.name}</#if>"<#if finderAttribute?index < finder.finderAttributes?size - 1>, </#if>
                       </#if>
                   </#list>
               })<#if finder?index < uniqueFinders?size - 1>,</#if>
           </#list>
       }
</#if>)
</#macro>
