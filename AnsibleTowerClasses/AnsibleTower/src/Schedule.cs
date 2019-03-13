using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class Schedule : IAnsibleObject {
        public Tower AnsibleTower { get; set; }
        public DateTime created { get; set; }
        public string description { get; set; }
        public DateTime? dtstart { get; set; }
        public DateTime? dtend { get; set; }
        public bool enabled { get; set; }
        public object extra_data { get; set; }
        public int id { get; set; }
        public object inventory { get; set; }
        public string job_type { get; set; }
        public string job_tags { get; set; }
        public string limit { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public DateTime next_run { get; set; }
        public string rrule { get; set; }
        public string skip_tags { get; set; }
        public string timezone { get; set; }
        public string type { get; set; }
        public object unified_job_template { get; set; }
        public string until { get; set; }
        public string url { get; set; }
        public int? verbosity { get; set; }
    }
}