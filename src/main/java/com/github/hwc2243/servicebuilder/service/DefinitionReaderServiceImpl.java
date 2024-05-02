package com.github.hwc2243.servicebuilder.service;

import java.io.File;
import java.io.IOException;

import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;

import com.github.hwc2243.servicebuilder.model.Service;

public class DefinitionReaderServiceImpl implements DefinitionReaderService {

	protected XmlMapper xmlMapper;
	
	public DefinitionReaderServiceImpl ()
	{
		this.xmlMapper = XmlMapper.builder()
				.enable(MapperFeature.ACCEPT_CASE_INSENSITIVE_ENUMS)
				.build();
	}
	
	@Override
	public Service read(File file) throws IOException {
		Service service = xmlMapper.readValue(file, Service.class);

		return service;
	}

}
