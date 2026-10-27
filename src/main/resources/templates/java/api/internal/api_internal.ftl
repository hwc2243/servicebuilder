<#include "/functions.ftl">
package ${internalApiPackage};

import ${baseInternalApiPackage}.BaseInternal${entity.name?cap_first}Rest;

public interface Internal${entity.name?cap_first}Rest extends BaseInternal${entity.name?cap_first}Rest
{
}
