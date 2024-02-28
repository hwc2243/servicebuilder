package com.github.hwc2243.servicebuilder;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

import com.beust.jcommander.JCommander;
import com.github.hwc2243.servicebuilder.model.Service;
import com.github.hwc2243.servicebuilder.service.BuilderArgs;
import com.github.hwc2243.servicebuilder.service.BuilderService;
import com.github.hwc2243.servicebuilder.service.DefinitionReaderService;

@SpringBootApplication
public class ServiceBuilderApplication implements CommandLineRunner {

	public ServiceBuilderApplication ()
	{
	}
	
	public static void main(String[] args) throws IOException {
		// HWC this isn't the try spring way of doing things but it gives a simple way to use
		// spring for maven plugin
		ConfigurableApplicationContext context = SpringApplication.run(ServiceBuilderApplication.class, args);

		BuilderArgs builderArgs = new BuilderArgs();
		JCommander cmd = JCommander.newBuilder()
		  .addObject(builderArgs)
		  .build();
		
		cmd.parse(args);
		
		BuilderService builderService = context.getBean(BuilderService.class);
		builderService.build(builderArgs);
	}

	public void run (String... args)  throws IOException
	{
		
	}
}
