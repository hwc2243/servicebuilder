package com.github.hwc2243.servicebuilder.config;

import java.util.Locale;

import com.github.hwc2243.servicebuilder.ServiceBuilderApplication;

import freemarker.template.Configuration;
import freemarker.template.TemplateExceptionHandler;
import freemarker.template.Version;

@org.springframework.context.annotation.Configuration
public class FreemarkerConfig {

	public Configuration freemarkerConfiguration ()
	{
		Configuration cfg = new Configuration(new Version(2, 3, 20));
		
        cfg.setClassForTemplateLoading(ServiceBuilderApplication.class, "templates");
        cfg.setDefaultEncoding("UTF-8");
        cfg.setLocale(Locale.US);
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
        
        return cfg;
	}
}
