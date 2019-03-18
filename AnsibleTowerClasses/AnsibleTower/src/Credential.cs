using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class Credential : IAnsibleObject {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public int? organization { get; set; }
        public int credential_type { get; set; }
        public Hashtable inputs { get; set; }
        public List<IAnsibleObject> Owners { get; set; }
        [JsonIgnore]
        public Tower AnsibleTower { get; set; }
        public override string ToString() {
            return this.name;
        }
    }
}