<#include "/entity/util.ftl">
<#assign className = className(entity.name)>
<#assign variableName = entity.name>
package ${clientRestPackage};

import java.io.IOException;

import org.springframework.stereotype.Service;

import ${clientModelPackage}.${className};

import ${clientBaseRestPackage}.Base${className}RestClient;

@Service
public class ${className}RestClient extends Base${className}RestClient<${className}>
{

}