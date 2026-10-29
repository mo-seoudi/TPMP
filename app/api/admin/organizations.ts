import postgres from "postgres";
import type {VercelRequest,VercelResponse} from "@vercel/node";

const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const send=(res:VercelResponse,code:number,data:unknown)=>res.status(code).json(data);
export default async function handler(req:VercelRequest,res:VercelResponse){
 res.setHeader("Cache-Control","no-store");
 if(!["GET","POST"].includes(req.method||""))return send(res,405,{error:"Method not allowed"});
 if(!process.env.TPMP_DATABASE_URL||!process.env.TPMP_SUPABASE_URL||!process.env.TPMP_SUPABASE_ANON_KEY)return send(res,503,{error:"Development backend not configured"});
 const sql=postgres(process.env.TPMP_DATABASE_URL!,{max:2,prepare:false,ssl:"require",idle_timeout:10});
 const auth=req.headers.authorization||"";
 if(!auth.startsWith("Bearer "))return send(res,401,{error:"Sign in required"});
 try{
  const response=await fetch(process.env.TPMP_SUPABASE_URL+"/auth/v1/user",{
   headers:{Authorization:auth,apikey:process.env.TPMP_SUPABASE_ANON_KEY}
  });
  if(!response.ok)return send(res,401,{error:"Invalid or expired session"});
  const user=await response.json() as {id?:string};
  if(!user.id||!uuid.test(user.id))return send(res,401,{error:"Invalid user identity"});
  const admins=await sql`SELECT 1 FROM tpmp_admin_poc.platform_administrators
   WHERE user_id=${user.id}::uuid AND status='active' AND revoked_at IS NULL LIMIT 1`;
  if(!admins.length)return send(res,403,{error:"Platform administrator access required"});
  if(req.method==="GET"){
   const [orgs,rels]=await Promise.all([
    sql`SELECT id,name,kind,parent_organization_id AS "parentId" FROM tpmp_admin_poc.organizations ORDER BY name`,
    sql`SELECT id,source_organization_id AS "schoolId",target_organization_id AS "supplierId",status
        FROM tpmp_admin_poc.organization_relationships WHERE relationship_type='client_supplier' ORDER BY created_at DESC`
   ]);
   return send(res,200,{organizations:orgs,relationships:rels});
  }
  const body=typeof req.body==="object"&&req.body?req.body:{};
  const action=body.action;
  if(action==="create_organization"){
   if(typeof body.name!=="string"||typeof body.kind!=="string"||body.name.length>200||
      !["group","school","supplier"].includes(body.kind)||
      (body.parentId!=null&&(!uuid.test(body.parentId)||body.kind!=="school")))return send(res,400,{error:"Invalid organization fields"});
   const result=await sql`SELECT tpmp_admin_poc.admin_create_organization(
    ${user.id}::uuid,${body.name}::text,${body.kind}::text,${body.parentId||null}::uuid,NULL::text) AS id`;
   return send(res,201,{id:result[0].id});
  }
  if(action==="register_supplier"){
   if(typeof body.name!=="string"||body.name.length>200||!uuid.test(body.schoolId))return send(res,400,{error:"Invalid supplier fields"});
   const result=await sql`SELECT * FROM tpmp_admin_poc.admin_register_supplier_for_school(
     ${user.id}::uuid,${body.schoolId}::uuid,${body.name}::text)`;
   return send(res,201,{supplierId:result[0].supplier_id,relationshipId:result[0].relationship_id});
  }
  if(action==="link_supplier"){
   if(!uuid.test(body.schoolId)||!uuid.test(body.supplierId))return send(res,400,{error:"Invalid relationship fields"});
   const result=await sql`SELECT tpmp_admin_poc.admin_link_school_supplier(
     ${user.id}::uuid,${body.schoolId}::uuid,${body.supplierId}::uuid) AS id`;
   return send(res,200,{id:result[0].id});
  }
  return send(res,400,{error:"Unknown action"});
 }catch(error){
  const e=error as {code?:string};
  if(e.code==="ENOTFOUND"||e.code==="EAI_AGAIN")return send(res,503,{error:"Unable to load organization data. Please try again."});
  if(e.code==="ECONNREFUSED"||e.code==="ETIMEDOUT")return send(res,503,{error:"Unable to load organization data. Please try again."});
  if(e.code==="28P01")return send(res,503,{error:"Unable to load organization data. Please try again."});
  if(e.code==="23505")return send(res,409,{error:"Organization or relationship already exists. Review before linking."});
  if(e.code==="42501")return send(res,403,{error:"Not authorized"});
  if(e.code==="22023")return send(res,400,{error:"Invalid organization or relationship"});
  console.error("TPMP organization operation failed",e.code||"internal");
  return send(res,500,{error:"Organization operation failed"});
 }
}
