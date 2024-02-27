package connors.servicebuilder.service;

import java.io.File;
import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;

import com.fasterxml.jackson.dataformat.xml.XmlMapper;

import connors.servicebuilder.model.Service;

@org.springframework.stereotype.Service
public class DefinitionReaderServiceImpl implements DefinitionReaderService {

	@Autowired
	XmlMapper xmlMapper;
	
	@Override
	public Service read(File file) throws IOException {
		Service service = xmlMapper.readValue(file, Service.class);

		return service;
	}

}
