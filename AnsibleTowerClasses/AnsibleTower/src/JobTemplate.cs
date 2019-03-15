using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class JobTemplate : IAnsibleObject
    {
        public int id { get; set; }
        public string name { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public string description { get; set; }
        public string job_type { get; set; }
        public object inventory { get; set; }
        public object project { get; set; }
        public string playbook { get; set; }
        public object credential { get; set; }
        public object cloud_credential { get; set; }
        public int forks { get; set; }
        public string limit { get; set; }
        public int verbosity { get; set; }
        public string extra_vars { get; set; }
        public string job_tags { get; set; }
        public string host_config_key { get; set; }
        public bool ask_variables_on_launch { get; set; }
        [JsonIgnore]
        public Tower AnsibleTower { get; set; }
    }
}