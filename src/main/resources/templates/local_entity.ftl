package ${localModelPackage};

import jakarta.persistence.Entity;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.Table;

import ${baseModelPackage}.Base${entity.name?cap_first};

@Entity
@Table (name="${entity.name}")
<#if entity.abstractEntity>
@Inheritance(strategy = InheritanceType.JOINED)
</#if>
<#if entity.abstractEntity>
public abstract class ${entity.name?cap_first}<T extends Base${entity.name?cap_first}> extends Base${entity.name?cap_first}<T>
<#else>
public class ${entity.name?cap_first} extends Base${entity.name?cap_first}<${entity.name?cap_first}>
</#if>
{
}