package ${modelPackage};

import java.util.stream.Stream;

public enum ${entity.name?cap_first}${attribute.name?cap_first}Type {
<#list attribute.enumValues as enumValue>
  ${enumValue?upper_case}("${enumValue}")${enumValue_has_next?string(",", ";")}
</#list>

  private final String name;

  private ${entity.name?cap_first}${attribute.name?cap_first}Type(String name) {
    this.name = name;
  }

  public String getName() {
    return name;
  }

  // A static lookup method to find the enum by its name
  public static ${entity.name?cap_first}${attribute.name?cap_first}Type fromValue(String name) {
    return Stream.of(${entity.name?cap_first}${attribute.name?cap_first}Type.values())
        .filter(type -> type.getName().equals(name))
        .findFirst()
        .orElseThrow(() -> new IllegalArgumentException("Unknown enum value: " + name));
  }
}