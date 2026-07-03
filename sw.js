/* GGG service worker
 * - games.json(데이터) & 앱 셸(html·js·css): 네트워크 우선 → 항상 최신 코드/데이터.
 *   실패(오프라인) 시에만 캐시로 폴백(데이터는 캐시된 JSON, 네비게이션은 index.html). 절대 HTML을 JS/JSON에 폴백하지 않음.
 * - 아이콘·폰트 등 정적 자산: 캐시 우선(속도). */
const CACHE = "ggg-v57";
const SHELL = [
  "./",
  "./index.html",
  "./styles.css",
  "./app.js",
  "./manifest.webmanifest",
  "./icons/icon.svg",
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  const sameOrigin = url.origin === self.location.origin;

  // 데이터: 네트워크 우선. 쿼리(?t=) 제거한 단일 키로 캐시, 실패 시 그 캐시(JSON)로만 폴백.
  if (sameOrigin && url.pathname.endsWith("games.json")) {
    const key = url.origin + url.pathname;
    e.respondWith(
      fetch(req).then((res) => {
        if (res && res.ok) { const copy = res.clone(); caches.open(CACHE).then((c) => c.put(key, copy)); }
        return res;
      }).catch(() => caches.match(key))
    );
    return;
  }

  // 앱 셸(html·js·css): 네트워크 우선 → 온라인이면 항상 최신 코드. 실패 시 캐시(네비게이션은 index.html).
  if (sameOrigin && /(?:\/|\.html|\.js|\.css)$/.test(url.pathname)) {
    e.respondWith(
      fetch(req).then((res) => {
        if (res && res.ok) { const copy = res.clone(); caches.open(CACHE).then((c) => c.put(req, copy)); }
        return res;
      }).catch(() => caches.match(req).then((r) => r || (req.mode === "navigate" ? caches.match("./index.html") : Response.error())))
    );
    return;
  }

  // 교차 출처(인벤·루리웹 이미지, 유튜브 썸네일 등)는 캐싱하지 않으므로 SW가 가로챌 이유가 없다.
  // 그대로 브라우저 기본 처리에 맡긴다 — no-cors opaque 응답을 SW가 대신 fetch()해 반환하면
  // 일부 iOS Safari에서 카드 썸네일이 표시되지 않는 사례가 있어 이를 회피한다.
  if (!sameOrigin) return;

  // 그 외(아이콘·폰트 등 동일 출처 정적 자산): 캐시 우선, 없으면 네트워크.
  e.respondWith(
    caches.match(req).then((r) => r || fetch(req).then((res) => {
      if (res && res.ok) { const copy = res.clone(); caches.open(CACHE).then((c) => c.put(req, copy)); }
      return res;
    }))
  );
});
