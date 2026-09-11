import { createClient } from "@/lib/supabase/server";
import CampTradeApp from "./ui";

export default async function Page() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  return <CampTradeApp initialUser={user ? {id:user.id,email:user.email ?? ""} : null}/>;
}