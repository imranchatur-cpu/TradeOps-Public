// Fresh teaching schema only. Not a production migration or broker integration test.
import { PGlite } from "npm:@electric-sql/pglite@0.2.17";
import { assertRejects } from "jsr:@std/assert@1.0.14";
const source = await Deno.readTextFile(new URL("../templates/schema.sql", import.meta.url));
async function fixture() {
  const pg = new PGlite();
  // PGlite already has core gen_random_uuid; its optional pgcrypto extension is not needed here.
  await pg.exec(source.replace("create extension if not exists pgcrypto;", ""));
  const { rows } = await pg.query<{ id: string }>("insert into plans(week_of) values ('2030-01-07') returning id");
  return { pg, plan: rows[0].id };
}
Deno.test("starter: armed row rejects null/fail/wait verdict and missing/low R:R", async () => {
  const { pg, plan } = await fixture();
  try {
    for (const [verdict, rr] of [[null, 2], ["wait", 2], ["fail", 2], ["pass", null], ["pass", 1]]) {
      await assertRejects(() => pg.query("insert into setups(plan_id,ticker,direction,status,red_team_verdict,expected_outcome,rr_t1) values ($1,'XYZ','long','armed',$2,'fictional claim',$3)", [plan, verdict, rr]));
    }
    await assertRejects(() => pg.query("insert into setups(plan_id,ticker,direction,status,red_team_verdict,rr_t1) values ($1,'XYZ','long','armed','pass',2)", [plan]));
    await pg.query("insert into setups(plan_id,ticker,direction,status,red_team_verdict,expected_outcome,rr_t1) values ($1,'XYZ','long','armed','pass','fictional claim',2)", [plan]);
  } finally { await pg.close(); }
});
Deno.test("starter: Wait is recorded without arming; locked claim cannot be rewritten", async () => {
  const { pg, plan } = await fixture();
  try {
    const { rows } = await pg.query<{ id: string }>("insert into setups(plan_id,ticker,direction,red_team_verdict,expected_outcome) values ($1,'XYZ','long','wait','original fictional claim') returning id", [plan]);
    await assertRejects(() => pg.query("update setups set expected_outcome='replacement' where id=$1", [rows[0].id]));
    await pg.query("update setups set red_team_note='awaiting named print' where id=$1", [rows[0].id]);
  } finally { await pg.close(); }
});
Deno.test("starter: active setup cannot be deleted; override is tagged rather than blocked", async () => {
  const { pg, plan } = await fixture();
  try {
    const { rows } = await pg.query<{ id: string }>("insert into setups(plan_id,ticker,direction,status,entry_source) values ($1,'XYZ','long','active','override') returning id", [plan]);
    await assertRejects(() => pg.query("delete from setups where id=$1", [rows[0].id]));
  } finally { await pg.close(); }
});
