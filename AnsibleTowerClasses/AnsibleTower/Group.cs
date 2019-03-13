using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class Group : IAnsibleObject
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public int inventory { get; set; }
        //public string variables { get; set; }
        [JsonIgnore()]
        public Hashtable variables { get; set; }
        public bool has_active_failures { get; set; }
        public int total_hosts { get; set; }
        public int hosts_with_active_failures { get; set; }
        public int total_groups { get; set; }
        public int groups_with_active_failures { get; set; }
        public bool has_inventory_sources { get; set; }
        public Tower AnsibleTower { get; set; }
    }
}