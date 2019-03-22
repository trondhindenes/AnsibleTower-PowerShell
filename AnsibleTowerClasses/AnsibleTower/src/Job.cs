using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class Job : IAnsibleObject
    {
        [JsonIgnore]
        public Tower AnsibleTower { get; set; }
        public string controller_node { get; set; }
        public DateTime created { get; set; }
        public string description { get; set; }
        public double elapsed { get; set; }
        public string execution_node { get; set; }
        public string extra_vars { get; set; }
        public bool failed { get; set; }
        public DateTime? finished { get; set; }
        public int forks { get; set; }
        public int id { get; set; }
        public object instance_group { get; set; }
        public object inventory { get; set; }
        public string job_explanation { get; set; }
        public string job_tags { get; set; }
        public object job_template { get; set; }
        public string job_type { get; set; }
        public string launch_type { get; set; }
        public string limit { get; set; }
        public string name { get; set; }
        public string playbook { get; set; }
        public object project { get; set; }
        public string result_stdout { get; set; }
        public string scm_revision { get; set; }
        public string skip_tags { get; set; }
        public DateTime? started { get; set; }
        public string status { get; set; }
        public string type { get; set; }
        public int? unified_job_template { get; set; }
        public string url { get; set; }
        //public object credential { get; set; }
        //public object cloud_credential { get; set; }
        public int verbosity { get; set; }
    }
}