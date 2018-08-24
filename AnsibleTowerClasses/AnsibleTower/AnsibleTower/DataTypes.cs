using Newtonsoft.Json;
using System;
using System.Collections.Generic;

namespace AnsibleTower
{
    public class Organization
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        //public Related related { get; set; }
        //public SummaryFields summary_fields { get; set; }
        public string created { get; set; }
        public string modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
    }

    public class User
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
        public DateTime? created { get; set; }
    }

    public class Project
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
        public DateTime last_job_run { get; set; }
        public bool last_job_failed { get; set; }
        public bool has_schedules { get; set; }
        public object next_job_run { get; set; }
        public string status { get; set; }
        public bool scm_delete_on_next_update { get; set; }
        public bool scm_update_on_launch { get; set; }
        public int scm_update_cache_timeout { get; set; }
        public bool last_update_failed { get; set; }
        public string last_updated { get; set; }
    }


    public class JobTemplate
    {
        public int id { get; set; }
        public string name { get; set; }
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
    }

    public class Job
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public int unified_job_template { get; set; }
        public string launch_type { get; set; }
        public string status { get; set; }
        public bool failed { get; set; }
        public double elapsed { get; set; }
        public string job_explanation { get; set; }
        public string job_type { get; set; }
        public object inventory { get; set; }
        public object project { get; set; }
        public string playbook { get; set; }
        //public object credential { get; set; }
        //public object cloud_credential { get; set; }
        public int forks { get; set; }
        public string limit { get; set; }
        public int verbosity { get; set; }
        public string extra_vars { get; set; }
        public string job_tags { get; set; }
        public int job_template { get; set; }
        public string result_stdout { get; set; }
        public DateTime? started { get; set; }
        public DateTime? finished { get; set; }
    }

    public class Inventory
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
    }

    public class Host
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public int inventory { get; set; }
        public bool enabled { get; set; }
        public string instance_id { get; set; }
        public string variables { get; set; }
        public bool has_active_failures { get; set; }
        public bool has_inventory_sources { get; set; }
        public int? last_job { get; set; }
        public int? last_job_host_summary { get; set; }
        public List<Group> groups { get; set; }
    }


    public class Group
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public string created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public int inventory { get; set; }
        public string variables { get; set; }
        public bool has_active_failures { get; set; }
        public int total_hosts { get; set; }
        public int hosts_with_active_failures { get; set; }
        public int total_groups { get; set; }
        public int groups_with_active_failures { get; set; }
        public bool has_inventory_sources { get; set; }
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

        public AnsibleTower.Job ParseToJob(string JsonString)
        {
            AnsibleTower.Job ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Job>(JsonString);
            return ConvertedObject;
        }

        public AnsibleTower.Inventory ParseToInventory(string JsonString)
        {
            AnsibleTower.Inventory ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Inventory>(JsonString);
            return ConvertedObject;
        }

        public AnsibleTower.Host ParseToHost(string JsonString)
        {
            AnsibleTower.Host ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Host>(JsonString);
            return ConvertedObject;
        }

        public AnsibleTower.Group ParseToGroup(string JsonString)
        {
            AnsibleTower.Group ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Group>(JsonString);
            return ConvertedObject;
        }
    }
}
