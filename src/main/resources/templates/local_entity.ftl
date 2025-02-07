package ${localModelPackage};

import java.io.Serializable;

import ${jpaPackage}.Entity;
import ${jpaPackage}.Inheritance;
import ${jpaPackage}.InheritanceType;
import ${jpaPackage}.Table;

import ${baseModelPackage}.Base${entity.name?cap_first};

@Entity
<#if entity.dbName?has_content>
@Table (name="${entity.dbName}")
<#else>
@Table (name="${entity.name}")
</#if>
<#if entity.abstractEntity>
@Inheritance(strategy = InheritanceType.JOINED)
</#if>
<#if entity.abstractEntity>
public abstract class ${entity.name?cap_first}<T extends Base${entity.name?cap_first}> extends Base${entity.name?cap_first}<T>
<#else>
public class ${entity.name?cap_first} extends Base${entity.name?cap_first}<${entity.name?cap_first}>
</#if>
    implements Serializable
{
}