
(function(){
"use strict";
var ORDER=[], PART="part", TOTAL=0;
function $(s,r){return (r||document).querySelector(s)}
function $all(s,r){return Array.prototype.slice.call((r||document).querySelectorAll(s))}
function store(k,v){try{if(v===undefined)return localStorage.getItem(k);localStorage.setItem(k,v)}catch(e){}}
function showHome(push){$all(".v2-lesson.open").forEach(function(e){e.classList.remove("open")});
var h=$("#v2-home");if(h)h.style.display="";var t=$("#v2-toolbar");if(t)t.style.display="";
if(push!==false){try{history.replaceState(null,"",location.pathname+"#/")}catch(e){}}window.scrollTo(0,0)}
function showLesson(uid,push){var id="lesson-"+uid;var el=document.getElementById(id);if(!el)return;
var h=$("#v2-home");if(h)h.style.display="none";var t=$("#v2-toolbar");if(t)t.style.display="none";
$all(".v2-lesson.open").forEach(function(e){e.classList.remove("open")});el.classList.add("open");
if(push!==false){try{location.hash="/day/"+uid}catch(e){}}window.scrollTo(0,0)}
function currentFilter(){return {q:($("#v2-q")?$("#v2-q").value:"").toLowerCase()}}
function applyFilter(){var f=currentFilter(),n=0;
$all("#v2-grid .v2-card").forEach(function(c){
var ok=(!f.q||(c.getAttribute("data-search")||"").toLowerCase().indexOf(f.q)>=0);
c.style.display=ok?"":"none";if(ok)n++});
var c=$("#v2-count");if(c)c.textContent=n+" / "+TOTAL+" lessons"}
function markDone(uid,on){var k="done-"+PART+"-"+uid;store(k,on?"1":"");var card=$('.v2-card[data-uid="'+uid+'"]');
if(card){card.classList.toggle("done",!!on);var t=card.querySelector(".v2-done-tag");if(t)t.style.display=on?"":"none"}
var box=document.getElementById("done-"+uid);if(box&&box.checked!==!!on)box.checked=!!on;progress()}
function progress(){var n=0;ORDER.forEach(function(u){if(store("done-"+PART+"-"+u)==="1")n++});
var bar=$("#v2-bar"),tx=$("#v2-progtext");var pct=TOTAL?Math.round(n/TOTAL*100):0;
if(bar)bar.style.width=pct+"%";if(tx)tx.textContent=n+" of "+TOTAL+" complete ("+pct+"%)"}
function speak(text,lang){try{speechSynthesis.cancel()}catch(e){}
try{var u=new SpeechSynthesisUtterance(text);u.lang=lang||"en-US";
var vs=[];try{vs=speechSynthesis.getVoices()}catch(e2){}
for(var i=0;i<vs.length;i++){if((lang||"en").slice(0,2)==="ar"&&vs[i].lang&&vs[i].lang.slice(0,2)==="ar"){u.voice=vs[i];break}
if((lang||"en").slice(0,2)!=="ar"&&vs[i].lang&&vs[i].lang.slice(0,2)==="en"){u.voice=vs[i];break}}
u.rate=0.95;speechSynthesis.speak(u)}catch(e){}}
document.addEventListener("click",function(e){
var say=e.target.closest("[data-say]"),op=e.target.closest("[data-open]");
var chk=e.target.closest("[data-check]"),fl=e.target.closest("[data-flip]");
var hm=e.target.closest("[data-home]");
if(hm){showHome();return}
if(op){showLesson(op.getAttribute("data-open"));return}
if(fl){fl.classList.toggle("flipped");return}
if(say){speak(say.getAttribute("data-say"),say.getAttribute("data-lang"));return}
if(chk){var box=chk.closest("[data-fill]");if(!box)return;var inp=box.querySelector("input");
var fb=box.querySelector("[data-feedback]");var exp=(box.getAttribute("data-answer")||"").trim().toLowerCase();
var got=(inp.value||"").trim().toLowerCase();var ok=got&&got===exp;
fb.hidden=false;fb.textContent=ok?"Correct. Well done!":("Not quite. Answer: "+box.getAttribute("data-answer"));
fb.className="v2-feedback "+(ok?"ok":"no");return}
});
document.addEventListener("change",function(e){
var lab=e.target.closest&&e.target.closest("[data-quiz] label");if(lab){
var box=lab.closest("[data-quiz]");var fb=box.querySelector("[data-feedback]");
var good=lab.hasAttribute("data-correct");
$all("label",box).forEach(function(l){l.classList.remove("ok","no")});
lab.classList.add(good?"ok":"no");
if(!good){var c=box.querySelector("label[data-correct]");if(c)c.classList.add("ok")}
fb.hidden=false;fb.textContent=good?"Correct. Well done!":"Not quite - the highlighted option is correct.";
fb.className="v2-feedback "+(good?"ok":"no");return}
var dn=e.target.closest&&e.target.closest("[data-done]");if(dn){
markDone(dn.getAttribute("data-done"),dn.checked);return}
});
document.addEventListener("input",function(e){
var q=e.target.closest&&e.target.closest("#v2-q");if(q){applyFilter();return}
var dr=e.target.closest&&e.target.closest("[data-draft]");if(dr){store("draft-"+dr.getAttribute("data-draft"),dr.value)}
});
document.addEventListener("keydown",function(e){
if(e.key==="Escape"){showHome()}
if(e.key==="Enter"&&e.target.classList&&e.target.classList.contains("v2-card")){showLesson(e.target.getAttribute("data-uid"))}
});
function route(){var m=(location.hash||"").match(/\/day\/([^\/]+)/);
if(m&&document.getElementById("lesson-"+m[1]))showLesson(m[1],false);else showHome(false)}
window.addEventListener("hashchange",route);
function init(order,part){ORDER=order;PART=part;TOTAL=order.length;
$all("[data-draft]").forEach(function(t){var v=store("draft-"+t.getAttribute("data-draft"));if(v)t.value=v});
order.forEach(function(u){if(store("done-"+part+"-"+u)==="1"){
var card=$('.v2-card[data-uid="'+u+'"]');if(card){card.classList.add("done");var tg=card.querySelector(".v2-done-tag");if(tg)tg.style.display=""}
var box=document.getElementById("done-"+u);if(box)box.checked=true}});
var th=$("#v2-theme");function syncThemeBtn(){var dark=document.documentElement.getAttribute("data-theme")==="dark";
if(th){th.setAttribute("data-theme-state",dark?"dark":"light");th.textContent=dark?"Light":"Dark"}}
if(th){th.addEventListener("click",function(){
var h=document.documentElement;var dark=h.getAttribute("data-theme")==="dark";
h.setAttribute("data-theme",dark?"":"dark");try{localStorage.setItem("theme-"+part,dark?"":"dark")}catch(e){}
syncThemeBtn()});
try{if(localStorage.getItem("theme-"+part)==="dark")document.documentElement.setAttribute("data-theme","dark")}catch(e){}
syncThemeBtn()}
route();progress();applyFilter();
var topBtn=$("#v2-top");if(topBtn){topBtn.addEventListener("click",function(){window.scrollTo(0,0)});
window.addEventListener("scroll",function(){topBtn.classList.toggle("show",(window.scrollY||0)>600)},{passive:true})}}
window.V2={init:init,showHome:showHome,showLesson:showLesson};
})();

