using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class WorkflowJobTemplate : IAnsibleObject {
        public Tower AnsibleTower { get; set; }
        public bool allow_simultaneous { get; set; }
        public bool ask_inventory_on_launch { get; set; }
        public bool ask_variables_on_launch { get; set; }
        public DateTime created { get; set; }
        public string description { get; set; }
        public string extra_vars { get; set; }
        public int id { get; set; }
        public object inventory { get; set; }
        public bool last_job_failed { get; set; }
        public DateTime? last_job_run { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public DateTime? next_job_run { get; set; }
        public object organization { get; set; }
        public string status { get; set; }
        public bool survey_enabled { get; set; }
        public string type { get; set; }
        public string url { get; set; }
    }
}