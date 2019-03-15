using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class CredentialType : IAnsibleObject {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public string kind { get; set; }
        public bool managed_by_tower { get; set; }
        //public string inputs { get; set; }
        //public string injectors { get; set; }
        [JsonIgnore]
        public Tower AnsibleTower { get; set; }
    }
}