package ${localServicePackage};

import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import ${dtoPackage}.${entity.name?cap_first}DTO;

import ${localModelPackage}.${entity.name?cap_first};

@Mapper
public interface ${entity.name?cap_first}Mapper {
  ${entity.name?cap_first}Mapper INSTANCE = Mappers.getMapper(${entity.name?cap_first}Mapper.class);
  
  ${entity.name?cap_first}DTO toDto(${entity.name?cap_first} ${entity.name});
}