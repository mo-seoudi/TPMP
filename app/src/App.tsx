import {useState} from "react";
import {Shell,type Page} from "./components/Shell";
import {Dashboard} from "./features/Dashboard";
import {Suppliers} from "./features/Suppliers";
import {SupplierWorkspace} from "./features/SupplierWorkspace";
import {SupplierForm} from "./features/SupplierForm";
import {WorkflowDemo} from "./features/WorkflowDemo";
import {Repository} from "./features/Repository";
import {Administration} from "./features/Administration";
import {suppliers as initialSuppliers,type Supplier} from "./data/suppliers";
const descriptions:Record<Exclude<Page,"dashboard"|"suppliers"|"repository"|"workflows"|"settings">,{title:string,description:string}> = {
compliance:{title:"Compliance",description:"Client-specific compliance requirements, validity and approvals will be introduced here."},
documents:{title:"Documents",description:"Document collection, versioning and expiry tracking will be introduced here."},
reviews:{title:"Reviews & approvals",description:"Pending reviews and decision history will be introduced here."},
reports:{title:"Reports",description:"Compliance analytics and reporting will be introduced here."}

};
export default function App(){
const [workspace,setWorkspace]=useState("Harbour Education Group");
const [page,setPage]=useState<Page>("dashboard"),[supplierId,setSupplierId]=useState<string|null>(null),[creating,setCreating]=useState(false),[records,setRecords]=useState<Supplier[]>(initialSuppliers);
const navigate=(p:Page)=>{setPage(p);setSupplierId(null);setCreating(false)};
const openSupplier=(id:string)=>{setPage("suppliers");setSupplierId(id);setCreating(false)};
const selected=records.find(s=>s.id===supplierId);
const saveSupplier=(s:Supplier)=>{setRecords(old=>[s,...old]);setCreating(false);openSupplier(s.id)};
return <Shell page={page} onNavigate={navigate}>{page==="dashboard"?<Dashboard suppliers={records} onSuppliers={()=>navigate("suppliers")} onSupplier={openSupplier}/>:page==="workflows"?<WorkflowDemo/>:page==="repository"?<Repository suppliers={records} onSupplier={openSupplier}/>:page==="settings"?<Administration workspace={workspace} onWorkspace={setWorkspace}/>:page==="suppliers"?(creating?<SupplierForm onCancel={()=>navigate("suppliers")} onSave={saveSupplier}/>:selected?<SupplierWorkspace supplier={selected} onBack={()=>navigate("suppliers")} onWorkflow={()=>navigate("workflows")}/>:<Suppliers suppliers={records} onOpen={openSupplier} onCreate={()=>setCreating(true)}/>):<><div className="heading"><div><div className="eyebrow">COMING IN A FUTURE MILESTONE</div><h1>{descriptions[page].title}</h1><p>{descriptions[page].description}</p></div></div><div className="panel padded"><h2>Module reserved</h2><p className="muted">This screen is a placeholder, not a live workflow. No database or production access is connected.</p></div></>}</Shell>
}
