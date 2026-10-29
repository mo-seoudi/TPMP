import {useState} from "react";
import {Activity,ArrowRight,Building2,GitBranch,LayoutDashboard,LockKeyhole,Search,ShieldCheck,UserRoundPlus,Users} from "lucide-react";
import {LiveOrganizations} from "./LiveOrganizations";

type Section="overview"|"organizations"|"relationships"|"people"|"roles"|"security";
const sections:{id:Section;label:string;detail:string;icon:typeof Building2}[]=[
 {id:"overview",label:"Overview",detail:"Your administration workspace",icon:LayoutDashboard},
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
 const [section,setSection]=useState<Section>("overview"),[search,setSearch]=useState("");
 const selected=sections.find(s=>s.id===section)!;
 return <div className="tp-admin">
  <header className="tp-admin-head"><div><div className="eyebrow">TPMP / PLATFORM MANAGEMENT</div><h1>Administration</h1><p>A single place to manage organizations, connections and controlled access.</p></div><span className="tp-admin-head-pill"><ShieldCheck size={15}/> Scoped administration</span></header>
  <div className="tp-admin-layout">
   <nav className="tp-admin-nav" aria-label="Administration navigation"><div className="tp-admin-nav-title">MANAGE</div>{sections.map(s=><button key={s.id} className={section===s.id?"active":""} onClick={()=>setSection(s.id)} aria-current={section===s.id?"page":undefined}><s.icon size={18}/><span>{s.label}</span>{section===s.id&&<ArrowRight size={14}/>}</button>)}<div className="tp-admin-nav-foot"><LockKeyhole size={16}/><span>Actions are verified by the backend, not by the selected workspace.</span></div></nav>
   <main className="tp-admin-main"><div className="tp-admin-section-head"><div><div className="tp-admin-section-icon"><selected.icon size={21}/></div><div><h2>{selected.label}</h2><p>{selected.detail}</p></div></div></div>
   {section==="overview"&&<><div className="tp-admin-intro"><div><div className="eyebrow">ADMINISTRATION WORKSPACE</div><h2>Manage the structure. Keep access precise.</h2><p>Register organizations once, connect suppliers to the schools they serve, and grant people only the access they need.</p></div><Building2 size={58}/></div><div className="tp-admin-cards">{sections.filter(s=>s.id!=="overview").map(s=><button className="tp-admin-feature" key={s.id} onClick={()=>setSection(s.id)}><span className="tp-admin-feature-icon"><s.icon size={21}/></span><strong>{s.label}</strong><small>{s.detail}</small><span className="tp-admin-feature-arrow">Open section <ArrowRight size={14}/></span></button>)}</div><div className="tp-admin-guidance"><ShieldCheck size={20}/><div><strong>School-first supplier onboarding</strong><p>A school administrator can register a supplier in the school's workspace without creating a supplier user. The relationship is established automatically. Inviting a supplier user is a separate, optional step.</p></div></div></>}
   {(section==="organizations"||section==="relationships")&&<LiveOrganizations view={section}/>}
   {section==="people"&&<><div className="tp-admin-preview"><UserRoundPlus size={18}/><div><strong>User administration is the next live integration</strong><p>The organization directory uses protected Supabase operations. User invitations, membership changes and role assignments are not yet connected. This page does not show fictional people or pretend to send invitations.</p></div></div><div className="tp-admin-empty"><Users size={35}/><h3>People & memberships</h3><p>One person can have memberships in several organizations and different roles at each scope. We will manage those assignments here after implementing the secure invitation API.</p><button className="secondary" onClick={()=>setSection("roles")}>Explore role model <ArrowRight size={15}/></button></div></>}
   {section==="roles"&&<><div className="tp-admin-preview"><ShieldCheck size={18}/><div><strong>Proposed role catalogue · reference only</strong><p>These are intended TPMP roles, not verified live assignments. Effective permissions must be validated server-side before editing access.</p></div></div><label className="tp-admin-search"><Search size={17}/><input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Find a role or capability…" aria-label="Search roles"/></label><div className="tp-admin-role-list">{roles.filter(r=>[r.name,r.scope,r.desc,...r.capabilities].join(" ").toLowerCase().includes(search.toLowerCase())).map(r=><article key={r.name}><div className="tp-admin-role-head"><span className="tp-admin-role-icon"><ShieldCheck size={18}/></span><div><h3>{r.name}</h3><p>{r.desc}</p></div><span className="tp-admin-scope">{r.scope}</span></div><div className="tp-admin-capabilities">{r.capabilities.map(x=><span key={x}>{x}</span>)}</div></article>)}</div></>}
   {section==="security"&&<><div className="tp-admin-guidance"><LockKeyhole size={20}/><div><strong>Default-deny and explicit authorization</strong><p>Platform administrator identity is checked server-side for current organization commands. Scoped school administration, user invitations and a complete audit ledger require further implementation and security testing.</p></div></div><div className="tp-admin-empty"><Activity size={35}/><h3>Audit timeline</h3><p>Live audit events are not yet connected. This section will show actor, action, affected record, organization scope and timestamp when the audit backend is ready.</p></div></>}
   </main>
  </div>
 </div>
}
