using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class WorkflowJob : IAnsibleObject {
        [JsonIgnore]
        public Tower AnsibleTower { get; set; }
        public bool allow_simultaneous { get; set; }
        public DateTime created { get; set; }
        public string description { get; set; }
        public double elapsed { get; set; }
        public string extra_vars { get; set; }
        public bool failed { get; set; }
        public DateTime? finished { get; set; }
        public int id { get; set; }
        public bool is_sliced_job { get; set; }
        public object inventory { get; set; }
        public string job_explanation { get; set; }
        public object job_template { get; set; }
        public string launch_type { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public DateTime? started { get; set; }
        public string status { get; set; }
        public string type { get; set; }
        public object unified_job_template { get; set; }
        public string url { get; set; }
        public object workflow_job_template { get; set; }
    }
}