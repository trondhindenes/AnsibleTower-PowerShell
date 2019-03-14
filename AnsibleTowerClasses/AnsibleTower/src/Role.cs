using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class Role : IAnsibleObject
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public string resource_type { get; set; }
        public string resource_name { get; set; }
        public Tower AnsibleTower { get; set; }
    }
}