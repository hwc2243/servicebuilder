<#macro builder_class entity>
<#if entity.abstractEntity>
    public abstract static class Builder<B extends Builder<B>> {

<#list entity.attributes as attribute>
<#assign fieldType = (attribute.type == "ENUM")?then((attribute.enumClass?has_content)?then(attribute.enumClass, entity.name?cap_first + attribute.name?cap_first), attribute.type.javaType)>
        protected ${className(fieldType)} ${attribute.name} = null;
</#list>

<#list entity.attributes as attribute>
<#assign fieldType = (attribute.type == "ENUM")?then((attribute.enumClass?has_content)?then(attribute.enumClass, entity.name?cap_first + attribute.name?cap_first), attribute.type.javaType)>
        public B ${attribute.name}(${className(fieldType)} ${attribute.name}) {
            this.${attribute.name} = ${attribute.name};
            return self();
        }

</#list>
        protected abstract B self();
    }
<#else>
    public static class Builder<#if entity.parent?? && entity.parent?has_content> extends ${entity.parent?cap_first}Entity.Builder<Builder></#if> {

<#list entity.attributes as attribute>
<#assign fieldType = (attribute.type == "ENUM")?then((attribute.enumClass?has_content)?then(attribute.enumClass, entity.name?cap_first + attribute.name?cap_first), attribute.type.javaType)>
        private ${className(fieldType)} ${attribute.name} = null;
</#list>

<#list entity.attributes as attribute>
<#assign fieldType = (attribute.type == "ENUM")?then((attribute.enumClass?has_content)?then(attribute.enumClass, entity.name?cap_first + attribute.name?cap_first), attribute.type.javaType)>
        public Builder ${attribute.name}(${className(fieldType)} ${attribute.name}) {
            this.${attribute.name} = ${attribute.name};
            return this;
        }

</#list>
<#if entity.parent?? && entity.parent?has_content>
        @Override
        protected Builder self() {
            return this;
        }

</#if>
        /**
         * The build method creates and returns the immutable Entity object.
         */
        public ${entity.name?cap_first}Entity build() {
            return new ${entity.name?cap_first}Entity(this);
        }
    }
</#if>
</#macro>