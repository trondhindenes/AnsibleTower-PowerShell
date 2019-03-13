using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class ModuleConfig
    {
        public Dictionary<string,Application> applications { get; set; }
    }
}