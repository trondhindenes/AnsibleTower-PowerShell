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
        DateTime created { get; set; }
        Tower AnsibleTower { get; set; }
    }
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
    public class Organization : IAnsibleObject
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        //public Related related { get; set; }
        //public SummaryFields summary_fields { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public Tower AnsibleTower { get; set; }
    }

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
        public Tower AnsibleTower { get; set; }
    }

    public class CredentialType : IAnsibleObject {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public string kind { get; set; }
        public bool managed_by_tower { get; set; }
        //public string inputs { get; set; }
        //public string injectors { get; set; }
        public Tower AnsibleTower { get; set; }
    }

    public class Token {
        public string access_token { get; set; }
        public string token_type { get; set; }
        public Int64 expires_in { get; set; }
        public string refresh_token { get; set; }
        public string scope { get; set; }
    }

    public class Tower
    {
        public Tower () {
            this.Endpoints = new Dictionary<string,string>();
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
    }


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
        public Tower AnsibleTower { get; set; }
    }


    public class JobTemplate : IAnsibleObject
    {
        public int id { get; set; }
        public string name { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public string description { get; set; }
        public string job_type { get; set; }
        public object inventory { get; set; }
        public object project { get; set; }
        public string playbook { get; set; }
        public object credential { get; set; }
        public object cloud_credential { get; set; }
        public int forks { get; set; }
        public string limit { get; set; }
        public int verbosity { get; set; }
        public string extra_vars { get; set; }
        public string job_tags { get; set; }
        public string host_config_key { get; set; }
        public bool ask_variables_on_launch { get; set; }
        public Tower AnsibleTower { get; set; }
    }

    public class Job : IAnsibleObject
    {
        public Tower AnsibleTower { get; set; }
        public string controller_node { get; set; }
        public DateTime created { get; set; }
        public string description { get; set; }
        public double elapsed { get; set; }
        public string execution_node { get; set; }
        public string extra_vars { get; set; }
        public bool failed { get; set; }
        public DateTime? finished { get; set; }
        public int forks { get; set; }
        public int id { get; set; }
        public object instance_group { get; set; }
        public object inventory { get; set; }
        public string job_explanation { get; set; }
        public string job_tags { get; set; }
        public int job_template { get; set; }
        public string job_type { get; set; }
        public string launch_type { get; set; }
        public string limit { get; set; }
        public string name { get; set; }
        public string playbook { get; set; }
        public object project { get; set; }
        public string result_stdout { get; set; }
        public string scm_revision { get; set; }
        public string skip_tags { get; set; }
        public DateTime? started { get; set; }
        public string status { get; set; }
        public string type { get; set; }
        public int unified_job_template { get; set; }
        public string url { get; set; }
        //public object credential { get; set; }
        //public object cloud_credential { get; set; }
        public int verbosity { get; set; }
    }

    public class Inventory : IAnsibleObject
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public int organization { get; set; }
        public string variables { get; set; }
        public bool has_active_failures { get; set; }
        public int? total_hosts { get; set; }
        public int? hosts_with_active_failures { get; set; }
        public int? total_groups { get; set; }
        public int groups_with_active_failures { get; set; }
        public bool has_inventory_sources { get; set; }
        public int? total_inventory_sources { get; set; }
        public int? inventory_sources_with_failures { get; set; }
        public List<Group> groups { get; set; }
        public Tower AnsibleTower { get; set; }

        public override string ToString() {
            return this.name;
        }
    }

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

    public class ModuleConfig
    {
        public Dictionary<string,Application> applications { get; set; }
    }

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





    public class JsonFunctions
    {
        public AnsibleTower.Organization ParseToOrganization(string JsonString)
        {
            AnsibleTower.Organization ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Organization>(JsonString);
            return ConvertedObject;
        }

        public AnsibleTower.User ParseToUser(string JsonString)
        {

            AnsibleTower.User ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.User>(JsonString);
            return ConvertedObject;
        }

        public AnsibleTower.JobTemplate ParseToJobTemplate(string JsonString)
        {
            AnsibleTower.JobTemplate ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.JobTemplate>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.Job ParseToJob(string JsonString)
        {
            AnsibleTower.Job ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Job>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.Inventory ParseToInventory(string JsonString)
        {
            AnsibleTower.Inventory ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Inventory>(JsonString);
            return ConvertedObject;
        }

        public AnsibleTower.Host ParseToHost(string JsonString)
        {
            JObject Json = JObject.Parse(JsonString);
            JToken InventoryObject = Json["summary_fields"]["inventory"];
            Json.Property("inventory").Remove();
            Json.Add("inventory", InventoryObject);
            AnsibleTower.Host ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Host>(Json.ToString());
            return ConvertedObject;
        }

        public AnsibleTower.Group ParseToGroup(string JsonString)
        {
            AnsibleTower.Group ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Group>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.ModuleConfig ParseToModuleConfig(string JsonString)
        {
            AnsibleTower.ModuleConfig ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.ModuleConfig>(JsonString);
            return ConvertedObject;
        }

        public static Hashtable ParseToHashtable(string JsonString)
        {
            Hashtable ConvertedObject = JsonConvert.DeserializeObject<Hashtable>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.Credential ParseToCredential(string JsonString) {
            AnsibleTower.Credential ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Credential>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.Project ParseToProject(string JsonString) {
            AnsibleTower.Project ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Project>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.CredentialType ParseToCredentialType(string JsonString) {
            AnsibleTower.CredentialType ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.CredentialType>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.Schedule ParseToSchedule(string JsonString) {
            AnsibleTower.Schedule ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Schedule>(JsonString);
            return ConvertedObject;
        }
    }
}
