import {useState} from "react";
import {Activity,ArrowLeft,ArrowRight,Building2,GitBranch,LockKeyhole,Search,ShieldCheck,UserRoundPlus,Users} from "lucide-react";
import {LiveOrganizations} from "./LiveOrganizations";

type Section="organizations"|"relationships"|"people"|"roles"|"security";
const sections:{id:Section;label:string;detail:string;icon:typeof Building2}[]=[
 {id:"organizations",label:"Organizations",detail:"Groups, schools and suppliers",icon:Building2},
 {id:"relationships",label:"Relationships",detail:"School–supplier engagements",icon:GitBranch},
 {id:"people",label:"People & access",detail:"Invitations, memberships and access",icon:Users},
 {id:"roles",label:"Roles & permissions",detail:"Who can do what and where",icon:ShieldCheck},
 {id:"security",label:"Security & activity",detail:"Access governance and audit",icon:LockKeyhole}
];
const roles=[
 {name:"Platform Super Admin",scope:"Platform",desc:"Platform-wide administration, identity and governance controls",capabilities:["Organization registry","User access","System configuration"]},
 {name:"Group Administrator",scope:"Group",desc:"Manage authorized schools within an education group",capabilities:["School administration","Supplier oversight","Group reporting"]},
 {name:"School Administrator",scope:"School",desc:"Manage suppliers, documents and authorized users for a school",capabilities:["Register suppliers","Manage school evidence","Invite supplier users"]},
 {name:"Compliance Manager",scope:"Organization",desc:"Manage assigned requirements and compliance reviews",capabilities:["Review evidence","Manage requirements","Monitor expiry"]},
 {name:"Supplier Administrator",scope:"Supplier",desc:"Maintain approved supplier information within granted client engagements",capabilities:["Submit evidence","Manage own users","Update permitted records"]},
 {name:"Reviewer",scope:"Assigned records",desc:"Review only assigned evidence and approvals",capabilities:["Review submissions","Record decisions"]}
];
export function Administration({workspace:_workspace,onWorkspace:_onWorkspace}:{workspace:string;onWorkspace:(v:string)=>void}){
 const [section,setSection]=useState<Section>("organizations"),[search,setSearch]=useState("");
 const [history,setHistory]=useState<Section[]>([]);
 const navigate=(next:Section)=>{if(next===section)return;setHistory(h=>[...h,section]);setSection(next)};
 const back=()=>{setHistory(h=>{if(h.length){setSection(h[h.length-1]);return h.slice(0,-1)}setSection("organizations");return []})};
 const selected=sections.find(s=>s.id===section)!;
 return <div className="tp-admin">
  <header className="tp-admin-head"><div><h1>Administration</h1><p>Manage organizations, relationships and access.</p></div></header>
  <div className="tp-admin-layout">
   <nav className="tp-admin-nav" aria-label="Administration navigation">{sections.map(s=><button key={s.id} className={section===s.id?"active":""} onClick={()=>navigate(s.id)} aria-current={section===s.id?"page":undefined}><s.icon size={18}/><span>{s.label}</span>{section===s.id&&<ArrowRight size={14}/>}</button>)}</nav>
   <main className="tp-admin-main">{history.length>0&&<div className="tp-admin-breadcrumb"><button type="button" onClick={back}><ArrowLeft size={16}/> Back</button><span>Administration <span aria-hidden="true">/</span> {selected.label}</span></div>}<div className="tp-admin-section-head"><div><div className="tp-admin-section-icon"><selected.icon size={21}/></div><div><h2>{selected.label}</h2><p>{selected.detail}</p></div></div></div>
   {(section==="organizations"||section==="relationships")&&<LiveOrganizations view={section}/>}
   {section==="people"&&<><div className="tp-admin-preview"><UserRoundPlus size={18}/><div><strong>User administration is the next live integration</strong><p>The organization directory uses protected Supabase operations. User invitations, membership changes and role assignments are not yet connected. This page does not show fictional people or pretend to send invitations.</p></div></div><div className="tp-admin-empty"><Users size={35}/><h3>People & memberships</h3><p>One person can have memberships in several organizations and different roles at each scope. We will manage those assignments here after implementing the secure invitation API.</p><button className="secondary" onClick={()=>navigate("roles")}>Explore role model <ArrowRight size={15}/></button></div></>}
   {section==="roles"&&<><div className="tp-admin-preview"><ShieldCheck size={18}/><div><strong>Proposed role catalogue · reference only</strong><p>These are intended TPMP roles, not verified live assignments. Effective permissions must be validated server-side before editing access.</p></div></div><label className="tp-admin-search"><Search size={17}/><input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Find a role or capability…" aria-label="Search roles"/></label><div className="tp-admin-role-list">{roles.filter(r=>[r.name,r.scope,r.desc,...r.capabilities].join(" ").toLowerCase().includes(search.toLowerCase())).map(r=><article key={r.name}><div className="tp-admin-role-head"><span className="tp-admin-role-icon"><ShieldCheck size={18}/></span><div><h3>{r.name}</h3><p>{r.desc}</p></div><span className="tp-admin-scope">{r.scope}</span></div><div className="tp-admin-capabilities">{r.capabilities.map(x=><span key={x}>{x}</span>)}</div></article>)}</div></>}
   {section==="security"&&<><div className="tp-admin-guidance"><LockKeyhole size={20}/><div><strong>Default-deny and explicit authorization</strong><p>Platform administrator identity is checked server-side for current organization commands. Scoped school administration, user invitations and a complete audit ledger require further implementation and security testing.</p></div></div><div className="tp-admin-empty"><Activity size={35}/><h3>Audit timeline</h3><p>Live audit events are not yet connected. This section will show actor, action, affected record, organization scope and timestamp when the audit backend is ready.</p></div></>}
   </main>
  </div>
 </div>
}
