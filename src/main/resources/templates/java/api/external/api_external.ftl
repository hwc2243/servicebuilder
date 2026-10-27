<#include "/functions.ftl">
package ${externalApiPackage};

import ${baseExternalApiPackage}.BaseExternal${entity.name?cap_first}Rest;

public interface External${entity.name?cap_first}Rest extends BaseExternal${entity.name?cap_first}Rest
{
}
