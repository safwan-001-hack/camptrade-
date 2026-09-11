import { NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";

const schema = z.object({
  orderId: z.string().uuid(),
  email: z.string().email(),
  amountNaira: z.number().positive()
});

export async function POST(req: Request) {
  try {
    const body = schema.parse(await req.json());
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json({error:"Unauthorized"}, {status:401});

    const { data: order } = await supabase.from("orders")
      .select("id,buyer_id,total_amount,status").eq("id",body.orderId).eq("buyer_id",user.id).single();
    if (!order) return NextResponse.json({error:"Order not found"}, {status:404});

    const secret = process.env.PAYSTACK_SECRET_KEY;
    if (!secret) return NextResponse.json({error:"Paystack is not configured yet"}, {status:503});

    const response = await fetch("https://api.paystack.co/transaction/initialize", {
      method:"POST",
      headers:{Authorization:`Bearer ${secret}`,"Content-Type":"application/json"},
      body:JSON.stringify({email:body.email,amount:Math.round(body.amountNaira*100),reference:`camptrade_${order.id}`})
    });
    const data = await response.json();
    if (!response.ok || !data.status) return NextResponse.json({error:data.message ?? "Payment initialization failed"}, {status:400});
    await supabase.from("orders").update({payment_reference:data.data.reference,payment_status:"pending"}).eq("id",order.id);
    return NextResponse.json({authorization_url:data.data.authorization_url,reference:data.data.reference});
  } catch (e) {
    return NextResponse.json({error:e instanceof Error ? e.message : "Invalid request"}, {status:400});
  }
}