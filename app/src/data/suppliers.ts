export type Status = "Compliant" | "Attention" | "Expired";
export type Supplier = {id:string;name:string;category:string;status:Status;documents:number;contact:string;location:string;updated:string};
export const suppliers:Supplier[] = [
{id:"SUP-001",name:"Northstar Transport",category:"Transport",status:"Compliant",documents:12,contact:"operations@northstar.example",location:"Dubai",updated:"2026-10-20"},
{id:"SUP-002",name:"Fresh Table Catering",category:"Catering",status:"Attention",documents:9,contact:"admin@freshtable.example",location:"Abu Dhabi",updated:"2026-10-18"},
{id:"SUP-003",name:"Crest Uniforms",category:"Uniforms",status:"Compliant",documents:15,contact:"hello@crest.example",location:"Dubai",updated:"2026-10-19"},
{id:"SUP-004",name:"Summit Activities",category:"Enrichment",status:"Expired",documents:7,contact:"info@summit.example",location:"Dubai",updated:"2026-10-16"},
{id:"SUP-005",name:"Brightline Facilities",category:"Services",status:"Attention",documents:11,contact:"support@brightline.example",location:"Sharjah",updated:"2026-10-17"},
{id:"SUP-006",name:"Blue Horizon Coaches",category:"Transport",status:"Compliant",documents:13,contact:"team@bluehorizon.example",location:"Abu Dhabi",updated:"2026-10-21"}
];
// All records above are fictional demonstration fixtures.
