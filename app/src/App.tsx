import {useState} from "react";
import {Shell,type Page} from "./components/Shell";
import {Dashboard} from "./features/Dashboard";
import {Suppliers,SupplierProfile} from "./features/Suppliers";
import {suppliers} from "./data/suppliers";
const descriptions:Record<Exclude<Page,"dashboard"|"suppliers">,{title:string,description:string}> = {
compliance:{title:"Compliance",description:"Client-specific compliance requirements, validity and approvals will be introduced here."},
documents:{title:"Documents",description:"Document collection, versioning and expiry tracking will be introduced here."},
reviews:{title:"Reviews & approvals",description:"Pending reviews and decision history will be introduced here."},
reports:{title:"Reports",description:"Compliance analytics and reporting will be introduced here."},
settings:{title:"Administration",description:"Organization access, memberships and permissions will be introduced here."}
};
export default function App(){
const [page,setPage]=useState<Page>("dashboard"),[supplierId,setSupplierId]=useState<string|null>(null);
const navigate=(p:Page)=>{setPage(p);setSupplierId(null)};
const openSupplier=(id:string)=>{setPage("suppliers");setSupplierId(id)};
const selected=suppliers.find(s=>s.id===supplierId);
return <Shell page={page} onNavigate={navigate}>{page==="dashboard"?<Dashboard onSuppliers={()=>navigate("suppliers")} onSupplier={openSupplier}/>:page==="suppliers"?(selected?<SupplierProfile supplier={selected} onBack={()=>navigate("suppliers")}/>:<Suppliers onOpen={openSupplier}/>):<><div className="heading"><div><div className="eyebrow">COMING IN A FUTURE MILESTONE</div><h1>{descriptions[page].title}</h1><p>{descriptions[page].description}</p></div></div><div className="panel padded"><h2>Module reserved</h2><p className="muted">This screen is a placeholder, not a live workflow. No database or production access is connected.</p></div></>}</Shell>
}
