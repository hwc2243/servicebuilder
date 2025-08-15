package ${internalApiPackage};

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

import ${baseInternalApiPackage}.BaseInternal${entity.name?cap_first}RestImpl;

@RestController
@RequestMapping("/api/internal/${entity.name}")
public class Internal${entity.name?cap_first}RestImpl
   extends BaseInternal${entity.name?cap_first}RestImpl
   implements Internal${entity.name?cap_first}Rest
{
}