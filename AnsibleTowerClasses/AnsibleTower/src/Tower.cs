using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using System.Runtime.Caching;

namespace AnsibleTower
{
    public class Tower
    {
        public Tower () {
            this.Endpoints = new Dictionary<string,string>();
            this.Cache = new MemoryCache("AnsibleTower");
        }

        public string AnsibleUrl { get; set; }
        public string TowerApiUrl { get; set; }
        public Token Token { get; set; }
        public DateTime TokenExpiration { get; set; }
        public User Me { get; set; }
        public Dictionary<string, string> Endpoints { get; set; }
        public override string ToString() {
            try {
                return (new Uri(this.AnsibleUrl)).Authority;
            } catch {
                return "";
            }
        }

        public MemoryCache Cache { get; private set; }
    }
}