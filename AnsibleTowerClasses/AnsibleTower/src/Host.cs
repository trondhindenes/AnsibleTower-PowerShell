using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class Host : IAnsibleObject
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public Inventory inventory { get; set; }
        public bool enabled { get; set; }
        public string instance_id { get; set; }
        public string variables { get; set; }
        public bool has_active_failures { get; set; }
        public bool has_inventory_sources { get; set; }
        public int? last_job { get; set; }
        public int? last_job_host_summary { get; set; }
        public List<Group> groups { get; set; }
        public Tower AnsibleTower { get; set; }
    }
}