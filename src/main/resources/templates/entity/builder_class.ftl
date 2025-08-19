<#macro builder_class entity>
    public static class Builder {

<#list entity.attributes as attribute>
<#assign fieldType = (attribute.type == "ENUM")?then((attribute.enumClass?has_content)?then(attribute.enumClass, attribute.name?cap_first + "Type"), attribute.javaType)>
        private ${fieldType} ${attribute.name};
</#list>

<#list entity.attributes as attribute>
<#assign fieldType = (attribute.type == "ENUM")?then((attribute.enumClass?has_content)?then(attribute.enumClass, attribute.name?cap_first + "Type"), attribute.javaType)>
        public Builder ${attribute.name}(${fieldType} ${attribute.name}) {
            this.${attribute.name} = ${attribute.name};
            return this;
        }

</#list>
        /**
         * The build method creates and returns the immutable Entity object.
         */
        public ${entity.name?cap_first} build() {
            return new ${entity.name?cap_first}(this);
        }
    }
</#macro>