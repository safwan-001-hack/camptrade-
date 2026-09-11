 "use client";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";

type Campus={id:string;name:string;short_name:string;theme_color:string};
type Listing={id:string;title:string;description:string;price:number;category:string;image_url:string|null;campus_id:string;seller_id:string;status:string};
type Wanted={id:string;title:string;description:string;budget:number|null;campus_id:string;status:string};

const campuses:Campus[]=[
 {id:"fut-minna",name:"Federal University of Technology, Minna",short_name:"FUT Minna",theme_color:"#8ecae6"},
 {id:"ibbu",name:"Ibrahim Badamasi Babangida University, Lapai",short_name:"IBBU",theme_color:"#77b255"},
 {id:"newgate",name:"Newgate University, Minna",short_name:"Newgate",theme_color:"#8ecae6"}
];

export default function CampTradeApp({initialUser}:{initialUser:{id:string,email:string}|null}) {
 const supabase=createClient();
 const [user,setUser]=useState(initialUser);
 const [campus,setCampus]=useState<Campus>(campuses[0]);
 const [tab,setTab]=useState("home");
 const [listings,setListings]=useState<Listing[]>([]);
 const [wanted,setWanted]=useState<Wanted[]>([]);
 const [search,setSearch]=useState("");
 const [loading,setLoading]=useState(false);
 const [message,setMessage]=useState("");
 const [authEmail,setAuthEmail]=useState("");
 const [showAuth,setShowAuth]=useState(!initialUser);
 const [showList,setShowList]=useState(false);
 const [showWanted,setShowWanted]=useState(false);

 async function load() {
   setLoading(true);
   const [a,b]=await Promise.all([
     supabase.from("listings").select("*").eq("campus_id",campus.id).eq("status","active").order("created_at",{ascending:false}),
     supabase.from("wanted_posts").select("*").eq("campus_id",campus.id).eq("status","open").order("created_at",{ascending:false})
   ]);
   setListings(a.data??[]); setWanted(b.data??[]); setLoading(false);
 }
 useEffect(()=>{load()},[campus.id]);

 async function login(e:React.FormEvent) {
   e.preventDefault(); setMessage("Sending sign-in link...");
   const {error}=await supabase.auth.signInWithOtp({email:authEmail,options:{emailRedirectTo:window.location.origin}});
   setMessage(error?.message??"Check your email for the sign-in link.");
 }
 async function logout(){await supabase.auth.signOut();setUser(null);setShowAuth(true)}
 const filtered=useMemo(()=>listings.filter(x=>`${x.title} ${x.description}`.toLowerCase().includes(search.toLowerCase())),[listings,search]);

 async function addListing(e:React.FormEvent<HTMLFormElement>) {
   e.preventDefault(); if(!user)return;
   const f=new FormData(e.currentTarget);
   const {error}=await supabase.from("listings").insert({
     campus_id:campus.id,seller_id:user.id,title:String(f.get("title")),description:String(f.get("description")),
     price:Number(f.get("price")),category:String(f.get("category")||"Other"),status:"active"
   });
   setMessage(error?.message??"Listing published."); setShowList(false); e.currentTarget.reset(); load();
 }
 async function addWanted(e:React.FormEvent<HTMLFormElement>) {
   e.preventDefault(); if(!user)return;
   const f=new FormData(e.currentTarget);
   const {error}=await supabase.from("wanted_posts").insert({
     campus_id:campus.id,buyer_id:user.id,title:String(f.get("title")),description:String(f.get("description")),
     budget:f.get("budget")?Number(f.get("budget")):null,status:"open"
   });
   setMessage(error?.message??"Wanted post published."); setShowWanted(false); e.currentTarget.reset(); load();
 }

 if(showAuth) return <main className="auth"><div className="authCard"><div className="logo">CT</div><h1>CampTrade</h1><p>Your Campus. Your Market.</p><h2>Choose your campus</h2><select value={campus.id} onChange={e=>setCampus(campuses.find(c=>c.id===e.target.value)!) }>{campuses.map(c=><option key={c.id} value={c.id}>{c.name}</option>)}</select><form onSubmit={login}><input type="email" required placeholder="Student email" value={authEmail} onChange={e=>setAuthEmail(e.target.value)}/><button style={{background:campus.theme_color}}>Send sign-in link</button></form><small>Use your student email. Verification and ID review are handled inside the platform.</small>{message&&<div className="notice">{message}</div>}</div></main>;

 return <main style={{"--accent":campus.theme_color} as React.CSSProperties}>
   <header><div><strong>CampTrade</strong><span>{campus.short_name}</span></div><button className="ghost" onClick={logout}>Sign out</button></header>
   <section className="hero"><div><p className="eyebrow">VERIFIED CAMPUS MARKETPLACE</p><h1>{campus.name}</h1><p>Buy, sell, discover and post what you need — inside your campus community.</p></div></section>
   <nav><button className={tab==="home"?"active":""} onClick={()=>setTab("home")}>Marketplace</button><button className={tab==="wanted"?"active":""} onClick={()=>setTab("wanted")}>Wanted</button><button className={tab==="orders"?"active":""} onClick={()=>setTab("orders")}>Orders</button><button className={tab==="profile"?"active":""} onClick={()=>setTab("profile")}>Profile</button></nav>
   {message&&<div className="notice page">{message}</div>}
   {tab==="home"&&<section className="content"><div className="toolbar"><input placeholder="Search products..." value={search} onChange={e=>setSearch(e.target.value)}/><button onClick={()=>setShowList(true)}>+ Sell item</button></div>{loading?<p>Loading...</p>:<div className="grid">{filtered.map(x=><article className="card" key={x.id}><div className="photo">{x.image_url?<img src={x.image_url} alt=""/>:"🛍️"}</div><div className="pad"><small>{x.category}</small><h3>{x.title}</h3><p>{x.description}</p><strong>₦{Number(x.price).toLocaleString()}</strong></div></article>)}</div>}{!filtered.length&&!loading&&<div className="empty">No listings yet. Be the first to sell something on campus.</div>}</section>}
   {tab==="wanted"&&<section className="content"><div className="toolbar"><div><h2>Wanted on campus</h2><p>Post exactly what you are looking for.</p></div><button onClick={()=>setShowWanted(true)}>+ Post wanted item</button></div><div className="wanted">{wanted.map(x=><article className="wantedCard" key={x.id}><div><h3>{x.title}</h3><p>{x.description}</p></div><strong>{x.budget?`Up to ₦${Number(x.budget).toLocaleString()}`:"Budget open"}</strong></article>)}</div></section>}
   {tab==="orders"&&<section className="content"><h2>Orders & payments</h2><p className="muted">Your real orders will appear here after checkout. Paystack payment initialization and webhook verification are included in this project.</p></section>}
   {tab==="profile"&&<section className="content"><h2>Your profile</h2><p>{user?.email}</p><div className="profileBox"><h3>Student verification</h3><p>Upload your student ID for admin review. Verified users can receive a campus verification badge.</p><button>Start verification</button></div><div className="profileBox"><h3>Safety</h3><p>Report suspicious listings, users or transactions. Keep payments inside CampTrade.</p></div></section>}

   {showList&&<Modal title="Sell an item" close={()=>setShowList(false)}><form className="form" onSubmit={addListing}><input name="title" required placeholder="Item title"/><input name="price" type="number" required placeholder="Price (₦)"/><input name="category" placeholder="Category e.g. Electronics"/><textarea name="description" required placeholder="Describe the item"/><button>Publish listing</button></form></Modal>}
   {showWanted&&<Modal title="Post what you need" close={()=>setShowWanted(false)}><form className="form" onSubmit={addWanted}><input name="title" required placeholder="What are you looking for?"/><input name="budget" type="number" placeholder="Budget (₦)"/><textarea name="description" required placeholder="Add specifications, size, condition, etc."/><button>Publish wanted post</button></form></Modal>}
 </main>
}
function Modal({title,close,children}:{title:string;close:()=>void;children:React.ReactNode}){return <div className="overlay"><div className="modal"><div className="modalHead"><h2>{title}</h2><button onClick={close}>×</button></div>{children}</div></div>}
