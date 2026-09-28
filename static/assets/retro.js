/* ============================================================================
   dedcom 95 — оконный менеджер рабочего стола.
   TUI-демо в окне dedcom.exe рисует общий движок assets/app.js
   (он находит #term-screen и .term-tab по классам сам).
   ========================================================================== */
(() => {
  'use strict';

  const d = document;
  const $  = (s, c = d) => c.querySelector(s);
  const $$ = (s, c = d) => [...c.querySelectorAll(s)];
  const REDUCED = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const SMALL = () => innerWidth < 720;

  /* ------------------------------- бут-экран ----------------------------- */
  const boot = $('#boot');
  let bootGone = REDUCED || !boot;
  const killBoot = () => {
    if (!bootGone) { bootGone = true; boot.remove(); autoOpen(); }
  };
  if (!bootGone) {
    const t = setTimeout(killBoot, 1900);
    boot.addEventListener('pointerdown', () => { clearTimeout(t); killBoot(); });
    addEventListener('keydown', () => { clearTimeout(t); killBoot(); }, { once: true });
  }

  /* --------------------------- оконный менеджер -------------------------- */
  const desktop = $('#desktop');
  const tasksEl = $('#tasks');
  let zTop = 30;
  const tasks = new Map();   // id -> кнопка на панели задач

  const winOf = (id) => $('#win-' + id);
  const topWin = () => $$('.win.show').filter((w) => !w.hidden)
    .sort((a, b) => (+b.style.zIndex || 0) - (+a.style.zIndex || 0))[0];

  function focusWin(id) {
    const w = winOf(id);
    if (!w) return;
    $$('.win').forEach((x) => x.classList.remove('active'));
    w.classList.add('active');
    w.style.zIndex = ++zTop;
    tasks.forEach((btn, tid) => btn.setAttribute('aria-pressed', String(tid === id)));
  }

  function openWin(id) {
    const w = winOf(id);
    if (!w) return;
    if (!w.classList.contains('show')) {
      w.classList.add('show');
      if (SMALL() && !w.classList.contains('dialog')) w.classList.add('max');
      clampWin(w);
      addTask(id, w);
    }
    w.hidden = false;
    focusWin(id);
  }

  function closeWin(id) {
    const w = winOf(id);
    if (!w) return;
    w.classList.remove('show', 'max');
    tasks.get(id)?.remove();
    tasks.delete(id);
    const t = topWin();
    if (t) focusWin(t.id.replace('win-', ''));
  }

  function minWin(id) {
    const w = winOf(id);
    if (!w) return;
    w.hidden = true;
    tasks.get(id)?.setAttribute('aria-pressed', 'false');
  }

  function maxWin(id) {
    const w = winOf(id);
    if (!w) return;
    w.classList.toggle('max');
    focusWin(id);
  }

  function clampWin(w) {
    const r = w.getBoundingClientRect();
    const maxX = Math.max(4, innerWidth - Math.min(r.width, innerWidth) - 4);
    const maxY = Math.max(4, innerHeight - 120);
    /* left/top могут быть в calc() — такие координаты не трогаем */
    const x = parseInt(w.style.left, 10);
    const y = parseInt(w.style.top, 10);
    if (!Number.isNaN(x)) w.style.left = Math.max(2, Math.min(x, maxX)) + 'px';
    if (!Number.isNaN(y)) w.style.top = Math.max(2, Math.min(y, maxY)) + 'px';
  }

  function addTask(id, w) {
    if (tasks.has(id)) return;
    const btn = d.createElement('button');
    btn.className = 'b95 task';
    btn.setAttribute('aria-pressed', 'false');
    const ico = w.dataset.ico;
    btn.innerHTML = (ico ? `<svg viewBox="0 0 32 32" aria-hidden="true"><use href="${ico}"/></svg>` : '') +
      `<span>${w.dataset.title}</span>`;
    btn.addEventListener('click', () => {
      const hidden = w.hidden;
      const isActive = w.classList.contains('active') && !hidden;
      if (isActive) minWin(id);
      else openWin(id);
    });
    tasksEl.append(btn);
    tasks.set(id, btn);
  }

  /* перетаскивание за тайтл-бар */
  function dragify(w) {
    const bar = $('.tbar', w);
    if (!bar) return;
    bar.addEventListener('pointerdown', (e) => {
      if (e.target.closest('.tb-btn') || w.classList.contains('max')) return;
      const r = w.getBoundingClientRect();
      const dx = e.clientX - r.left, dy = e.clientY - r.top;
      const move = (ev) => {
        w.style.left = Math.min(Math.max(ev.clientX - dx, 44 - r.width), innerWidth - 44) + 'px';
        w.style.top = Math.min(Math.max(ev.clientY - dy, 0), innerHeight - 90) + 'px';
      };
      const up = () => {
        removeEventListener('pointermove', move);
        removeEventListener('pointerup', up);
      };
      addEventListener('pointermove', move);
      addEventListener('pointerup', up);
      focusWin(w.id.replace('win-', ''));
    });
    bar.addEventListener('dblclick', (e) => {
      if (!e.target.closest('.tb-btn')) maxWin(w.id.replace('win-', ''));
    });
  }

  $$('.win').forEach((w) => {
    dragify(w);
    w.addEventListener('pointerdown', () => focusWin(w.id.replace('win-', '')));
    $$('.tb-btn', w).forEach((btn) => btn.addEventListener('click', () => {
      const id = w.id.replace('win-', '');
      const act = btn.dataset.act;
      if (act === 'close') closeWin(id);
      else if (act === 'min') minWin(id);
      else if (act === 'max') maxWin(id);
    }));
  });

  /* кнопки внутри окон: data-open / data-close */
  d.addEventListener('click', (e) => {
    const opener = e.target.closest('[data-open]');
    if (opener) { openWin(opener.dataset.open); return; }
    const closer = e.target.closest('[data-close]');
    if (closer) closeWin(closer.closest('.win').id.replace('win-', ''));
  });

  /* ------------------------------- значки -------------------------------- */
  const COARSE = matchMedia('(pointer: coarse)').matches;
  const runIcon = (icon) => {
    if (icon.dataset.open) openWin(icon.dataset.open);
    else if (icon.dataset.href) {
      /* data-blank — уходить наружу (GitHub) в новой вкладке, не бросая стол */
      if ('blank' in icon.dataset) open(icon.dataset.href, '_blank', 'noopener');
      else location.href = icon.dataset.href;
    }
    else if (icon.dataset.act === 'off') shutdown();
  };
  $$('.icon').forEach((icon) => {
    icon.addEventListener('click', () => {
      $$('.icon').forEach((i) => i.classList.remove('sel'));
      icon.classList.add('sel');
      if (COARSE) runIcon(icon);
    });
    icon.addEventListener('dblclick', () => runIcon(icon));
    icon.addEventListener('keydown', (e) => { if (e.key === 'Enter') runIcon(icon); });
  });
  desktop.addEventListener('pointerdown', (e) => {
    if (e.target === desktop || e.target.id === 'icons')
      $$('.icon').forEach((i) => i.classList.remove('sel'));
  });

  /* ------------------------------ меню «Пуск» ---------------------------- */
  const menu = $('#startmenu');
  const startBtn = $('#startbtn');
  const toggleMenu = (on) => {
    menu.classList.toggle('open', on ?? !menu.classList.contains('open'));
    startBtn.setAttribute('aria-expanded', String(menu.classList.contains('open')));
  };
  startBtn.addEventListener('click', (e) => { e.stopPropagation(); toggleMenu(); });
  d.addEventListener('pointerdown', (e) => {
    if (menu.classList.contains('open') && !e.target.closest('#startmenu, #startbtn')) toggleMenu(false);
  });
  $$('.sm-item', menu).forEach((it) => it.addEventListener('click', () => {
    toggleMenu(false);
    if (it.dataset.open) openWin(it.dataset.open);
    else if (it.dataset.act === 'minall') $$('.win.show').forEach((w) => minWin(w.id.replace('win-', '')));
    else if (it.dataset.act === 'off') shutdown();
  }));

  /* --------------------------- завершение работы ------------------------- */
  const off = $('#off');
  let wasOpen = [];
  function shutdown() {
    wasOpen = $$('.win.show').filter((w) => !w.hidden).map((w) => w.id.replace('win-', ''));
    wasOpen.forEach(minWin);
    off.classList.add('show');
  }
  off.addEventListener('click', () => {
    off.classList.remove('show');
    wasOpen.forEach(openWin);   /* «включили обратно» — рабочий стол как был */
    wasOpen = [];
  });
  addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      if (off.classList.contains('show')) { off.classList.remove('show'); return; }
      if (menu.classList.contains('open')) { toggleMenu(false); return; }
      const t = topWin();
      if (t && !t.hidden) closeWin(t.id.replace('win-', ''));
    }
  });

  /* --------------------------------- часы -------------------------------- */
  const clock = $('#clock');
  const tickClock = () => {
    const n = new Date();
    clock.textContent = String(n.getHours()).padStart(2, '0') + ':' +
                        String(n.getMinutes()).padStart(2, '0');
  };
  tickClock();
  setInterval(tickClock, 20000);

  /* --------------------- автозапуск: сразу показываем демо ---------------- */
  let autoDone = false;
  function autoOpen() {
    if (autoDone) return;
    autoDone = true;
    openWin('demo');
  }
  if (bootGone) setTimeout(autoOpen, 150);
})();
