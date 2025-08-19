package ${externalApiPackage};

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

import ${baseExternalApiPackage}.BaseExternal${entity.name?cap_first}RestImpl;

@RestController
@RequestMapping("/api/external/${entity.name}")
public class External${entity.name?cap_first}RestImpl
   extends BaseExternal${entity.name?cap_first}RestImpl
   implements External${entity.name?cap_first}Rest
{
}