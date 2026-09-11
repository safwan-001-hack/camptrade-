import crypto from "crypto";
import { NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";

export async function POST(req: Request) {
  const raw = await req.text();
  const signature = req.headers.get("x-paystack-signature") ?? "";
  const secret = process.env.PAYSTACK_SECRET_KEY ?? "";
  const hash = crypto.createHmac("sha512", secret).update(raw).digest("hex");
  if (!secret || !crypto.timingSafeEqual(Buffer.from(hash), Buffer.from(signature))) {
    return NextResponse.json({error:"Invalid signature"}, {status:401});
  }
  const event = JSON.parse(raw);
  if (event.event === "charge.success") {
    const reference = event.data?.reference;
    if (reference) {
      const admin = createAdminClient();
      await admin.from("orders").update({payment_status:"paid",status:"paid"}).eq("payment_reference",reference);
    }
  }
  return NextResponse.json({received:true});
}