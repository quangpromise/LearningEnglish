// Proxy goi VoiceRSS (mien phi, chi can dang ky email lay API key, khong can
// the thanh toan) de co giong doc chat luong cao hon TTS mac dinh cua may.
// API key luu o server (secret VOICERSS_API_KEY), KHONG bao gio dua vao app -
// neu nhung vao app se bi trich xuat tu file APK va bi nguoi khac dung ke
// quota mien phi (350 luot/ngay, dung chung cho toan bo user cua app).
//
// Xem docs/setup-voicerss-tts.md de biet cach lay API key va set secret nay.

import { encodeBase64 } from "jsr:@std/encoding/base64";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  const apiKey = Deno.env.get("VOICERSS_API_KEY");
  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: "Server chua cau hinh VOICERSS_API_KEY" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  let body: { text?: string; locale?: string };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Body JSON khong hop le" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const text = body.text?.trim();
  if (!text) {
    return new Response(JSON.stringify({ error: "Thieu 'text'" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }
  if (text.length > 500) {
    return new Response(
      JSON.stringify({ error: "Text qua dai (toi da 500 ky tu / lan goi)" }),
      { status: 400, headers: { "Content-Type": "application/json" } },
    );
  }

  const locale = body.locale ?? "en-us";
  const url =
    `https://api.voicerss.org/?key=${apiKey}&hl=${encodeURIComponent(locale)}` +
    `&src=${encodeURIComponent(text)}&c=MP3&f=44khz_16bit_stereo`;

  const voiceRes = await fetch(url);
  if (!voiceRes.ok) {
    return new Response(
      JSON.stringify({ error: "VoiceRSS tra ve loi HTTP", status: voiceRes.status }),
      { status: 502, headers: { "Content-Type": "application/json" } },
    );
  }

  const contentType = voiceRes.headers.get("content-type") ?? "";
  const bytes = new Uint8Array(await voiceRes.arrayBuffer());

  // VoiceRSS tra ve HTTP 200 nhung noi dung la text loi (vd het quota,
  // sai key) thay vi audio nhi phan - phai kiem tra content-type.
  if (contentType.includes("text")) {
    const detail = new TextDecoder().decode(bytes);
    return new Response(
      JSON.stringify({ error: "VoiceRSS tra ve loi", detail }),
      { status: 502, headers: { "Content-Type": "application/json" } },
    );
  }

  return new Response(
    JSON.stringify({ audioContent: encodeBase64(bytes) }),
    { status: 200, headers: { "Content-Type": "application/json" } },
  );
});
