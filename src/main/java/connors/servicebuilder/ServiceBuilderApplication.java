package connors.servicebuilder;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import com.beust.jcommander.JCommander;

import connors.servicebuilder.model.Service;
import connors.servicebuilder.service.BuilderArgs;
import connors.servicebuilder.service.BuilderService;
import connors.servicebuilder.service.DefinitionReaderService;

@SpringBootApplication
public class ServiceBuilderApplication implements CommandLineRunner {

	@Autowired
	protected DefinitionReaderService definitionReaderService;
	
	@Autowired
	protected BuilderService builderService;
	
	public static void main(String[] args) {
		SpringApplication.run(ServiceBuilderApplication.class, args);
	}

	public void run (String... args)  throws IOException
	{
		BuilderArgs builderArgs = new BuilderArgs();
		JCommander cmd = JCommander.newBuilder()
		  .addObject(builderArgs)
		  .build();
		
		cmd.parse(args);
		
		File file = new File(builderArgs.getServiceFile());
		if (!file.exists())
		{
			throw new FileNotFoundException(builderArgs.getServiceFile() + " not found");
		}
		
		Service service = definitionReaderService.read(file);
		builderService.build(service, builderArgs);
	}
}
