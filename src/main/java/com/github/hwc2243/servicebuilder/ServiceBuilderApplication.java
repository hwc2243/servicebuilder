package com.github.hwc2243.servicebuilder;

import java.io.IOException;
import java.util.Locale;

import org.xml.sax.SAXException;

import com.beust.jcommander.JCommander;

import com.github.hwc2243.servicebuilder.service.BuilderArgs;
import com.github.hwc2243.servicebuilder.service.BuilderService;
import com.github.hwc2243.servicebuilder.service.BuilderServiceImpl;
import com.github.hwc2243.servicebuilder.service.DefinitionReaderServiceImpl;

import freemarker.template.Configuration;
import freemarker.template.TemplateExceptionHandler;
import freemarker.template.Version;

public class ServiceBuilderApplication {

	public ServiceBuilderApplication ()
	{
	}
	
	public static void main(String[] args) throws IOException, SAXException {
		BuilderArgs builderArgs = new BuilderArgs();
		JCommander cmd = JCommander.newBuilder()
		  .addObject(builderArgs)
		  .build();
		
		cmd.parse(args);
		
		Configuration freemarker = new Configuration(new Version(2, 3, 20));
		
        freemarker.setClassForTemplateLoading(ServiceBuilderApplication.class, "/templates");
        freemarker.setDefaultEncoding("UTF-8");
        freemarker.setLocale(Locale.US);
        freemarker.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
        
		BuilderService builderService = new BuilderServiceImpl(freemarker, new DefinitionReaderServiceImpl());
		builderService.build(builderArgs);
	}
}
