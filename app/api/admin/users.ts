import postgres from "postgres";
import {createClient} from "@supabase/supabase-js";
import type {VercelRequest,VercelResponse} from "@vercel/node";
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const send=(res:VercelResponse,code:number,data:unknown)=>res.status(code).json(data);
export default async function handler(req:VercelRequest,res:VercelResponse){
 res.setHeader("Cache-Control","no-store");
 if(req.method!=="GET"&&req.method!=="POST")return send(res,405,{error:"Method not allowed"});
 const db=process.env.TPMP_DATABASE_URL, url=process.env.TPMP_SUPABASE_URL,anon=process.env.TPMP_SUPABASE_ANON_KEY,service=process.env.TPMP_SUPABASE_SERVICE_ROLE_KEY;
 if(!db||!url||!anon||!service)return send(res,503,{error:"User management is not available yet."});
 const bearer=req.headers.authorization||"";
 if(!bearer.startsWith("Bearer "))return send(res,401,{error:"Sign in required."});
 const sql=postgres(db,{max:1,prepare:false,ssl:"require",idle_timeout:5,connect_timeout:8});
 try{
  const verify=await fetch(url+"/auth/v1/user",{headers:{Authorization:bearer,apikey:anon}});
  if(!verify.ok)return send(res,401,{error:"Please sign in again."});
  const actor=await verify.json() as {id?:string};
  if(!actor.id||!uuid.test(actor.id))return send(res,401,{error:"Please sign in again."});
  const permitted=await sql`SELECT 1 FROM tpmp_admin_poc.platform_administrators WHERE user_id=${actor.id}::uuid AND status='active' AND revoked_at IS NULL LIMIT 1`;
  if(!permitted.length)return send(res,403,{error:"You do not have permission to manage users."});
  const admin=createClient(url,service,{auth:{autoRefreshToken:false,persistSession:false}});
  if(req.method==="GET"){
   const {data,error}=await admin.auth.admin.listUsers({page:1,perPage:100});
   if(error)throw error;
   return send(res,200,{users:data.users.map(u=>({id:u.id,email:u.email||"",createdAt:u.created_at,lastSignInAt:u.last_sign_in_at||null,invitedAt:u.invited_at||null,emailConfirmedAt:u.email_confirmed_at||null})),hasMore:data.users.length===100});
  }
  const body=typeof req.body==="object"&&req.body?req.body:{};
  const email=typeof body.email==="string"?body.email.trim().toLowerCase():"";
  if(email.length>254||!(/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)))return send(res,400,{error:"Enter a valid email address."});
  const {data,error}=await admin.auth.admin.inviteUserByEmail(email);
  if(error){
   if(/already|registered|exists/i.test(error.message))return send(res,409,{error:"This user already has an account."});
   console.error("TPMP user invitation failed",error.status||"unknown");
   return send(res,502,{error:"Unable to send invitation. Please try again."});
  }
  console.info("TPMP user invitation issued",JSON.stringify({actorId:actor.id,inviteeId:data.user.id}));
  return send(res,201,{userId:data.user.id});
 }catch(e){
  console.error("TPMP user management failed",(e as {code?:string;status?:number}).code||(e as {status?:number}).status||"internal");
  return send(res,500,{error:"Unable to complete this request. Please try again."});
 }finally{await sql.end({timeout:2}).catch(()=>{})}
}
