// Proxy goi Google Cloud Text-to-Speech (giong WaveNet/Neural2 tu nhien hon
// TTS mac dinh cua may). API key luu o server (secret GOOGLE_TTS_API_KEY),
// KHONG bao gio dua vao app - neu nhung vao app se bi trich xuat tu file APK
// va bi nguoi khac dung ke quota mien phi.
//
// Xem docs/setup-google-tts.md de biet cach lay API key va set secret nay.

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  const apiKey = Deno.env.get("GOOGLE_TTS_API_KEY");
  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: "Server chua cau hinh GOOGLE_TTS_API_KEY" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  let body: { text?: string; languageCode?: string; voiceName?: string };
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

  const languageCode = body.languageCode ?? "en-US";
  const voiceName = body.voiceName ?? "en-US-Neural2-F";

  const googleRes = await fetch(
    `https://texttospeech.googleapis.com/v1/text:synthesize?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        input: { text },
        voice: { languageCode, name: voiceName },
        audioConfig: { audioEncoding: "MP3" },
      }),
    },
  );

  if (!googleRes.ok) {
    const detail = await googleRes.text();
    return new Response(
      JSON.stringify({ error: "Google TTS tra ve loi", detail }),
      { status: 502, headers: { "Content-Type": "application/json" } },
    );
  }

  const data = await googleRes.json();
  return new Response(JSON.stringify({ audioContent: data.audioContent }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
