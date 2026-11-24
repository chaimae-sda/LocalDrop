'use strict';

// Les identifiants correspondent aux planches de répartition de l’équipe.
const groups = [
  ['Découverte', [
    ['00_splash','Bienvenue sur LocalDrop'], ['01_onboarding','Les bons paniers'],
    ['02_onboarding_proximite','Votre quartier'], ['03_onboarding_retrait','Le retrait']]],
  ['Accès au compte', [
    ['04_choix_profil','Choix du profil'], ['05_connexion','Connexion'],
    ['06_inscription_client','Inscription client'], ['07_inscription_commercant','Inscription commerçant'],
    ['08_verification','Vérification'], ['09_mot_de_passe','Mot de passe oublié']]],
  ['Personnalisation', [
    ['10_autorisation_position','Localisation'], ['11_autorisation_notifications','Notifications'],
    ['12_bienvenue','Compte prêt']]],
  ['Espace client', [
    ['32_client_profil','Mon profil'], ['33_client_modifier_profil','Modifier mon profil'],
    ['34_client_adresses','Mes adresses'], ['37_client_aide','Centre d’aide'],
    ['38_client_contact','Contacter le support']]],
];
const screens = groups.flatMap(([, values]) => values);
const byNumber = new Map(screens.map(([id, label]) => [id.slice(0, 2), [id, label]]));
// Rectangles des liens des maquettes, exprimés en pourcentage de leur image.
const links = {
  '00': [[6,83,88,10,'01']],
  '01': [[80,6,19,7,'04'],[5,87,90,9,'02']],
  '02': [[80,6,19,7,'04'],[5,87,90,9,'03']],
  '03': [[80,6,19,7,'04'],[5,87,90,9,'04']],
  '04': [[5,34,90,23,'06'],[5,58,90,23,'07'],[20,81,60,8,'05']],
  '05': [[55,52,43,6,'09'],[4,58,92,7,'32'],[4,68,92,8,'04']],
  '06': [[4,66,92,7,'08'],[20,73,60,5,'05']],
  '07': [[4,79,92,7,'08'],[20,86,60,5,'05']],
  '08': [[7,48,86,8,'10']], '09': [[7,43,86,13,'05']],
  '10': [[4,69,92,16,'11']], '11': [[4,69,92,16,'12']],
  '12': [[4,56,92,10,'32']],
  '32': [[4,44,92,8,'33'],[4,59,92,8,'34']],
  '33': [[4,52,92,9,'32']], '37': [[4,55,92,10,'38']],
  '38': [[4,73,92,9,'37']],
};
const $ = (id) => document.getElementById(id);
const menu = $('menu');
const select = $('choose');
for (const [title, entries] of groups) {
  const group = document.createElement('section');
  const h = document.createElement('h2');
  h.textContent = title; group.append(h);
  const options = document.createElement('optgroup');
  options.label = title; select.append(options);
  for (const [id, label] of entries) {
    const link = document.createElement('a');
    link.href = '#' + id;
    const n = document.createElement('small'); n.textContent = id.slice(0,2);
    link.append(n, document.createTextNode(label)); group.append(link);
    options.append(new Option(id.slice(0,2)+' · '+label,id));
  }
  menu.append(group);
}
function currentIndex() {
  const index = screens.findIndex(([id]) => id === location.hash.slice(1));
  return Math.max(index, 0);
}
function render() {
  const i = currentIndex();
  const [id, label] = screens[i];
  const image = $('screen');
  image.src = 'ecrans/' + id + '.webp';
  image.alt = 'Maquette ' + id.slice(0,2) + ' — ' + label;
  $('count').textContent = (i + 1) + ' / ' + screens.length;
  document.title = label + ' · LocalDrop';
  $('caption').textContent = label;
  select.value = id;
  for (const a of menu.querySelectorAll('a')) {
    if (a.hash === '#'+id) {
      a.setAttribute('aria-current','page');
      if (menu.clientHeight) {
        const r=a.getBoundingClientRect(), m=menu.getBoundingClientRect();
        if (r.top<m.top || r.bottom>m.bottom) menu.scrollTop+=r.top-m.top-menu.clientHeight/2+r.height/2;
      }
    } else a.removeAttribute('aria-current');
  }
  $('prev').disabled = i === 0; $('next').disabled = i === screens.length - 1;
  const hot = $('hotspots'); hot.replaceChildren();
  for (const [x,y,w,h,target] of links[id.slice(0,2)] || []) {
    const [targetId, targetLabel] = byNumber.get(target);
    const a = document.createElement('a'); a.href = '#'+targetId;
    a.title = targetLabel; a.setAttribute('aria-label','Ouvrir '+targetLabel);
    Object.assign(a.style, {left:x+'%',top:y+'%',width:w+'%',height:h+'%'});
    hot.append(a);
  }
}
function step(direction) {
  const screen = screens[currentIndex()+direction]; if (screen) location.hash = screen[0];
}
select.addEventListener('change', () => { location.hash = select.value; });
$('prev').addEventListener('click', () => step(-1));
$('next').addEventListener('click', () => step(1));
document.addEventListener('keydown', event => {
  if (event.target.closest('select,input,textarea,button')) return;
  if (event.key==='ArrowRight') step(1);
  if (event.key==='ArrowLeft') step(-1);
});
window.addEventListener('hashchange', render);
render();
