"""Build the public two-page pack. No private inputs; fonts downloaded from Google Fonts."""
from pathlib import Path
from urllib.request import urlopen
from xml.sax.saxutils import escape
from fontTools.ttLib import TTFont as FontFile
from fontTools.varLib.instancer import instantiateVariableFont
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.colors import HexColor

ROOT = Path(__file__).resolve().parents[1]
FONTS = ROOT / '.build-fonts'
FONTS.mkdir(exist_ok=True)
for family, filename, weight in [
    ('Syne', 'Syne[wght].ttf', 700),
    ('Inter', 'Inter[opsz,wght].ttf', 300),
    ('JetBrainsMono', 'JetBrainsMono[wght].ttf', 400),
]:
    folder = family.lower()
    local = FONTS / f'{family}.ttf'
    if not local.exists():
        source = FONTS / filename
        url = f'https://raw.githubusercontent.com/google/fonts/main/ofl/{folder}/{filename.replace("[", "%5B").replace("]", "%5D")}'
        source.write_bytes(urlopen(url, timeout=30).read())
        license_text = urlopen(f'https://raw.githubusercontent.com/google/fonts/main/ofl/{folder}/OFL.txt', timeout=30).read()
        (FONTS / f'{family}-OFL.txt').write_bytes(license_text)
        font = FontFile(source)
        axes = {'wght': weight}
        if family == 'Inter': axes['opsz'] = 14
        instantiateVariableFont(font, axes, inplace=True).save(local)
    pdfmetrics.registerFont(TTFont(family, str(local)))

BG, WHITE, MUTED, BLUE = map(HexColor, ['#0D0D14', '#FFFFFF', '#A0A8C0', '#0066FF'])
c = canvas.Canvas(str(ROOT / 'DESK-pack.pdf'), pagesize=(612,792))
c.setTitle('TradeOps public desk pack - 2026-10-11')
c.setAuthor('Imran Chatur / Lift Off')
def paragraph(text,x,y,w=520,size=10,color=MUTED,font='Inter',leading=None):
    p=Paragraph(escape(text), ParagraphStyle('p',fontName=font,fontSize=size,leading=leading or size*1.35,textColor=color))
    _,h=p.wrap(w,750)
    p.drawOn(c,x,y-h)
    return h
def page(number,title,description):
    c.setFillColor(BG); c.rect(0,0,612,792,fill=1,stroke=0)
    c.setFillColor(BLUE); c.rect(44,738,23,23,fill=1,stroke=0)
    c.setFillColor(WHITE); c.setFont('Syne',18); c.drawString(50,743,'L')
    paragraph(f'LIFT OFF / TRADEOPS / {number} OF 2',80,756,size=9,color=BLUE,font='JetBrainsMono')
    paragraph(title,44,711,size=27,color=WHITE,font='Syne')
    paragraph(description,44,661,size=10)
    c.setStrokeColor(BLUE); c.line(44,620,568,620)
    paragraph('PUBLIC DESIGN / 2026-10-11 / CC BY 4.0',44,36,size=8,color=MUTED,font='JetBrainsMono')
    c.linkURL('https://github.com/imranchatur-cpu/TradeOps-Public',(44,12,568,36))

page(1,'11 agents. One job each.','Agents prepare; humans commit. Wolf and Quartermaster are the intended Floor seats. Workers record finishes in the database; Wolf relays actionable results.')
roster=[
('Wolf','Coordinates, resolves blockers and arms only after Pass. Cannot approve plans or submit orders.'),
('Quartermaster','Stages planned-limit broker instructions and reconciles fills. Human submits.'),
('Architect','Builds the weekly draft, scores and reads lessons. Never approves its own plan.'),
('Sentinel','Full approved-plan premarket refresh. Changes non-active levels and claims only.'),
('Scout','Woken intraday tape and evidence. Entry, promote and stop-risk work; never arms.'),
('Red Team','Attacks the thesis with fresh evidence: Pass / Wait / Fail. Code owns the numbers.'),
('Coach','Grades immutable thesis revisions and overrides. Pilot results stay separate.'),
('Cartographer','Reports multi-timeframe structure facts; does not make the trade decision.'),
('Options','Owns options evidence, scripted pulls and the rate-limited provider queue.'),
('Pulse','Structured news and public X evidence; sentiment alone is not a signal.'),
('Archivist','Gated research ingest and archiving. No duplicate or invented evidence.'),
]
for i,(name,job) in enumerate(roster):
    y=604-i*40
    paragraph(name,44,y,w=133,size=12,color=WHITE,font='Syne')
    h=paragraph(job,183,y,w=385,size=9.5)
    assert h<=36,(name,h)
paragraph('VIDEO INGEST IS A ROUTINE, NOT A TWELFTH DECISION ROLE.',44,142,size=8,color=BLUE,font='JetBrainsMono')
paragraph('Human-only: approve the plan, submit every live order, change capital/risk. Enable unattended schedules explicitly. No agent can cross these boundaries.',44,119,size=10,color=WHITE)
c.showPage()
page(2,'The rules before the order.','Current design: thesis attack, code-gated work and recorded decisions. This public pack excludes private plans, positions, trade levels, accounts, credentials and internal IDs.')
rules=[
('01 / PREREGISTER','Write the observable thesis, invalidation and time window at BUILD/UPDATE. Never invent it at entry.'),
('02 / CODE FIRST','Fresh tape and calendar/plan gates before a wake. Planned-limit R:R, stop, target and earnings math are code.'),
('03 / CHALLENGE','Red Team supplies the strongest opposing case. Only Pass permits Wolf to arm. Wait and Fail both block it.'),
('04 / HUMAN COMMITS','Quartermaster stages a reviewable instruction after the arm. The human reviews and submits every order.'),
('05 / DURABLE EVENTS','Claim stable keys at sender and receiver. Bound definite retries. Reconcile unknown acceptance; never blindly replay.'),
('06 / FRESH DATA','Reject tape older than 120 seconds. Provider failure is a code alert, no model wake. Quotes and chart frames have separate clocks.'),
('07 / SHORT CONTEXT','Read shared core plus one role card. Load references only as needed. Quiet slots finish in code; no repeated Fail chatter.'),
('08 / ORIGINAL REVISION','Preserve immutable decision snapshots. Grade matching outcomes, not the current card. Legacy unversioned evidence is excluded from accuracy.'),
('09 / VERIFY ACTIVATION','A Git merge is not a backend deploy. Schema, receiver guards, functions and controlled smoke checks are separate steps.'),
]
for i,(label,body) in enumerate(rules):
    y=604-i*49
    paragraph(label,44,y,size=10,color=BLUE,font='JetBrainsMono')
    h=paragraph(body,44,y-17,size=9.5)
    assert h<=28,(label,h)
paragraph('TEACHING PACK, NOT A RUNNABLE TRADING SYSTEM.',44,142,size=8,color=BLUE,font='JetBrainsMono')
paragraph('Backend activation was not verified in this public sync. No token-saving percentage or trading return is claimed. Not financial advice. Full contract and editable diagrams are in the public repository.',44,119,size=9.5)
c.save()
print('Built DESK-pack.pdf (2 pages)')
