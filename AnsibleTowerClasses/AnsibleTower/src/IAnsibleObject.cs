using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public interface IAnsibleObject {
        int id { get; set; }
        string type { get; set; }
        string url { get; set; }
        Tower AnsibleTower { get; set; }
    }
}