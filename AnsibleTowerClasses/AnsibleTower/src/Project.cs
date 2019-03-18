using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class Project : IAnsibleObject
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public string local_path { get; set; }
        public string scm_type { get; set; }
        public string scm_url { get; set; }
        public string scm_branch { get; set; }
        public bool scm_clean { get; set; }
        public bool scm_delete_on_update { get; set; }
        public object credential { get; set; }
        public DateTime? last_job_run { get; set; }
        public bool last_job_failed { get; set; }
        public bool has_schedules { get; set; }
        public object next_job_run { get; set; }
        public string status { get; set; }
        public bool scm_delete_on_next_update { get; set; }
        public bool scm_update_on_launch { get; set; }
        public int scm_update_cache_timeout { get; set; }
        public bool last_update_failed { get; set; }
        public string last_updated { get; set; }
        [JsonIgnore]
        public Tower AnsibleTower { get; set; }
        public override string ToString() {
            return this.name;
        }
    }
}