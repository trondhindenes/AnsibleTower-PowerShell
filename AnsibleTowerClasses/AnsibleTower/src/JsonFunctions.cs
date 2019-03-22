using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace AnsibleTower
{
    public class JsonFunctions
    {
        public static AnsibleTower.Organization ParseToOrganization(string JsonString)
        {
            AnsibleTower.Organization ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Organization>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.User ParseToUser(string JsonString)
        {

            AnsibleTower.User ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.User>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.JobTemplate ParseToJobTemplate(string JsonString)
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

        public static AnsibleTower.Host ParseToHost(string JsonString)
        {
            AnsibleTower.Host ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Host>(JsonString.ToString());
            return ConvertedObject;
        }

        public static AnsibleTower.Group ParseToGroup(string JsonString)
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

        public static AnsibleTower.WorkflowJob ParseToWorkflowJob(string JsonString) {
            AnsibleTower.WorkflowJob ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.WorkflowJob>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.WorkflowJobTemplate ParseToWorkflowJobTemplate(string JsonString) {
            AnsibleTower.WorkflowJobTemplate ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.WorkflowJobTemplate>(JsonString);
            return ConvertedObject;
        }

        public static AnsibleTower.Role ParseToRole(string JsonString) {
            JObject Json = JObject.Parse(JsonString);
            AnsibleTower.Role ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Role>(Json.ToString());
            ConvertedObject.resource_name = (string)Json.SelectToken("summary_fields.resource_name");
            ConvertedObject.resource_type = (string)Json.SelectToken("summary_fields.resource_type");
            return ConvertedObject;
        }
        public static AnsibleTower.Team ParseToTeam(string JsonString) {
            AnsibleTower.Team ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Team>(JsonString);
            return ConvertedObject;
        }
    }
}
