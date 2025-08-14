<#macro finder_processor finder>
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
<#assign finderParameters += finderParameter.type>
<#assign finderParameters += " ">
<#assign finderParameters += finderParameter.name>
<#if finder.unique>
<#assign finderName = "fetchBy" + finderAttributes>
<#else>
<#assign finderName = "findBy" + finderAttributes>
</#if>
</#list>
</#macro>