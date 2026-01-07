<#macro finder_preprocessor finder>
<#assign finderName = "">
<#assign finderAttributes = "">
<#assign finderArguments = "">
<#assign finderParameters = "">
<#list finder.finderAttributes as finderAttribute>
<#if finderAttributes?length != 0><#assign finderAttributes += "And"></#if>
<#assign finderAttributes += finderAttribute.name?cap_first>
<#if finderArguments?length != 0><#assign finderArguments += ", "><#assign finderParameters += ", "></#if>
<#assign finderParameter = entity.getAttribute(finderAttribute.name)>
<#assign finderArguments += finderParameter.name>
<#assign parameterJavaType = "">
<#if finderParameter.type.value == "enum">
<#if finderParameter.enumClass?has_content>
<#assign parameterJavaType = finderParameter.enumClass>
<#else>
<#assign parameterJavaType = finderParameter.name?cap_first + "Type">
</#if>
<#else>
<#assign parameterJavaType = finderParameter.type.javaType>
</#if>
<#assign finderParameters += parameterJavaType>
<#assign finderParameters += " ">
<#assign finderParameters += finderParameter.name>
<#if finder.unique>
<#assign finderName = "findFirstBy">
<#assign finderReturn = "T">
<#else>
<#assign finderName = "findBy">
<#assign finderReturn = "List<T>">
</#if>
</#list>
</#macro>