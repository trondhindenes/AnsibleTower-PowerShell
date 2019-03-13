using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class User : IAnsibleObject
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        //public string created { get; set; }
        public string username { get; set; }
        public string first_name { get; set; }
        public string last_name { get; set; }
        public string email { get; set; }
        public bool is_superuser { get; set; }
        public bool is_system_auditor { get; set; }
        public string ldap_dn { get; set; }
        public string external_account { get; set; }
        public DateTime created { get; set; }
        public Tower AnsibleTower { get; set; }
    }
}