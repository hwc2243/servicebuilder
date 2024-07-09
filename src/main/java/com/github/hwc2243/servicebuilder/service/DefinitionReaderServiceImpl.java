package com.github.hwc2243.servicebuilder.service;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import javax.xml.XMLConstants;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;

import com.github.hwc2243.servicebuilder.model.Service;

public class DefinitionReaderServiceImpl implements DefinitionReaderService {

	protected static Logger logger = LoggerFactory.getLogger(DefinitionReaderServiceImpl.class);
	
	protected XmlMapper xmlMapper;
	
	protected Validator validator;
	
	public DefinitionReaderServiceImpl () throws SAXException
	{
		this.xmlMapper = XmlMapper.builder()
				.enable(MapperFeature.ACCEPT_CASE_INSENSITIVE_ENUMS)
				.build();
		
		SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
		InputStream is = this.getClass().getClassLoader().getResourceAsStream("service.xsd");
		Source schemaFile = new StreamSource(is);
		Schema schema = factory.newSchema(schemaFile);
		validator = schema.newValidator();
	}
	
	@Override
	public Service read (File file) throws IOException, SAXException {
		validator.validate(new StreamSource(file));
		
		Service service = xmlMapper.readValue(file, Service.class);

		return service;
	}
}
