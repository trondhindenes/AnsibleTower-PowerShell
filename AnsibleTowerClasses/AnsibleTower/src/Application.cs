using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class Application : IAnsibleObject
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public string client_id { get; set; }
        public string client_secret { get; set; }
        public string client_type { get; set; }
        public string redirect_uris { get; set; }
        public string authorization_grant_type { get; set; }
        public bool skip_authorization { get; set; }
        public int organization { get; set; }
        public Tower AnsibleTower { get; set; }
    }
}