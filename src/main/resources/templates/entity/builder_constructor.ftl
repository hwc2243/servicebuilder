<#macro builder_constructor entity>
    // Private constructor to force the use of the Builder
    private ${entity.name?cap_first}(Builder builder)
    {
    <#-- Assign the builder's properties to the entity's properties -->
<#list entity.attributes as attribute>
        this.${attribute.name} = builder.${attribute.name};
</#list>
    }
</#macro>