using Example.Specification;
using System;
using System.Management.Automation;

namespace Example.Application
{
    [Cmdlet(VerbsData.ConvertTo, "NumericBase", ConfirmImpact = ConfirmImpact.Low)]
    [Alias("ConvertTo-Base")]
    public sealed class ConvertToNumericBaseCommand : Cmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public Int32 SourceDigit { get; set; } = Int32.MinValue;

        [Parameter(Mandatory = true)]
        public Int32 SourceBase { get; set; } = 10;

        [Parameter(Mandatory = true)]
        [Alias("TargetBase")]
        public Int32 DestinationBase { get; set; } = 10;

        [Parameter(Mandatory = true)]
        public IStack<Int32> DataStructure { get; set; }

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
                WriteObject(remainder);
            }
        }
    }
}
