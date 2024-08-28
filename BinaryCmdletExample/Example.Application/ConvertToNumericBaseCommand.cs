using Example.Specification;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.IO;
using System.Linq;
using System.Management.Automation;

namespace Example.Application
{
    [Cmdlet(VerbsData.ConvertTo, "NumericBase", ConfirmImpact = ConfirmImpact.Low)]
    [Alias("ConvertTo-Base")]
    public sealed class ConvertToNumericBaseCommand : Cmdlet
    {
        private const String SpecificationResultFile = "Example.Specification.json";

        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public Int32 SourceDigit { get; set; } = Int32.MinValue;

        [Parameter(Mandatory = true)]
        public Int32 SourceBase { get; set; } = 10;

        [Parameter(Mandatory = true)]
        [Alias("TargetBase")]
        public Int32 DestinationBase { get; set; } = 10;

        [Parameter(Mandatory = true)]
        public IStack<Int32> DataStructure { get; set; }

        private String SpecPath => Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), SpecificationResultFile);

        protected override void BeginProcessing()
        {
            //JObject specResults = JObject.Parse(File.ReadAllText(SpecPath)); // gives error
            //JArray specResults = (JArray)JsonConvert.DeserializeObject(File.ReadAllText(SpecPath)); // kudos to https://stackoverflow.com/a/24645588
            JArray specResults = JArray.Parse(File.ReadAllText(SpecPath));
            if (! specResults
                //.Children()
                .Where(x => x["ModuleId"]["Name"].ToString() == "Example.Specification")
                .Where(x => x["TypeId"]["Name"].ToString() == DataStructure.GetType().Name)
                .SelectMany(x => x["TestResultIds"].Children())
                .All(x => (Boolean)x["Passed"]))
            {
                ThrowTerminatingError(new ErrorRecord(
                    new ArgumentException($"Type {DataStructure.GetType().Name} is not known to meet specification. See {SpecPath}"),
                    "SpecificationSecurityException",
                    ErrorCategory.PermissionDenied,
                    DataStructure));
            }
        }

        protected override void ProcessRecord()
        {
            DataStructure.Push(SourceDigit);
        }

        protected override void EndProcessing()
        {
            Int32 number = 0;
            if (DataStructure.Count > 0)
            {
                // digit == 0
                number += DataStructure.Pop();
            }
            Int32 digit = 1;
            while (DataStructure.Count > 0)
            {
                digit *= SourceBase;
                number += digit * DataStructure.Pop();
            }

            while (number > 0)
            {
                number = Math.DivRem(number, DestinationBase, out var remainder);
                DataStructure.Push(remainder);
            }
            while (DataStructure.Count > 0)
            {
                WriteObject(DataStructure.Pop());
            }
        }
    }
}
