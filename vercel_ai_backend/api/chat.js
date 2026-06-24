// Vercel Serverless Function: /api/chat
// Primary AI: Groq (Llama 3) | Fallback AI: Google Gemini (Gemini 1.5 Flash)

export default async function handler(req, res) {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return res.status(200).json({ status: 'OK' });
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed. Please use POST.' });
  }

  const { message, user_id } = req.body;

  if (!message) {
    return res.status(400).json({ error: 'Missing "message" in request body.' });
  }

  const systemInstruction = 
    'You are an AI Health Coach for the Diabetes Prevention Program (DPP). ' +
    'Provide friendly, empathetic, accurate, and encouraging advice regarding prediabetes, ' +
    'blood sugar management, healthy nutrition, and physical activity. Keep answers helpful, professional, and concise.';

  const groqApiKey = process.env.GROQ_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;

  // ─── 1. PRIMARY AI: GROQ API ───────────────────────────────────────────────
  if (groqApiKey) {
    try {
      console.log('Attempting Primary Model: Groq (llama3-8b-8192)...');
      const groqReq = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${groqApiKey}`
        },
        body: JSON.stringify({
          model: 'llama3-8b-8192',
          messages: [
            { role: 'system', content: systemInstruction },
            { role: 'user', content: message }
          ],
          temperature: 0.7,
          max_tokens: 512
        })
      });

      if (groqReq.ok) {
        const groqData = await groqReq.json();
        const reply = groqData.choices?.[0]?.message?.content;
        if (reply) {
          console.log('Successfully generated response via Groq.');
          return res.status(200).json({ response: reply, model: 'groq-llama3' });
        }
      } else {
        console.warn(`Groq API returned status ${groqReq.status}. Triggering Gemini fallback...`);
      }
    } catch (groqError) {
      console.warn('Groq API exception encountered. Triggering Gemini fallback...', groqError);
    }
  } else {
    console.warn('GROQ_API_KEY not found in environment. Skipping to Gemini fallback...');
  }

  // ─── 2. FALLBACK AI: GOOGLE GEMINI API ─────────────────────────────────────
  if (geminiApiKey) {
    try {
      console.log('Attempting Fallback Model: Google Gemini (gemini-1.5-flash)...');
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`;
      const geminiReq = await fetch(geminiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          systemInstruction: {
            parts: [{ text: systemInstruction }]
          },
          contents: [
            { role: 'user', parts: [{ text: message }] }
          ],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 512
          }
        })
      });

      if (geminiReq.ok) {
        const geminiData = await geminiReq.json();
        const reply = geminiData.candidates?.[0]?.content?.parts?.[0]?.text;
        if (reply) {
          console.log('Successfully generated response via Gemini fallback.');
          return res.status(200).json({ response: reply, model: 'gemini-1.5-flash' });
        }
      } else {
        console.error(`Gemini API fallback also failed with status ${geminiReq.status}.`);
        const errText = await geminiReq.text();
        console.error('Gemini Error details:', errText);
      }
    } catch (geminiError) {
      console.error('Gemini API fallback exception encountered:', geminiError);
    }
  } else {
    console.error('GEMINI_API_KEY not found in environment.');
  }

  // ─── 3. FINAL FALLBACK: ERROR / MOCK MESSAGE ───────────────────────────────
  return res.status(500).json({
    response: 'I am experiencing high server demand right now. Please verify your GROQ_API_KEY and GEMINI_API_KEY in Vercel Environment Variables, and try again in a moment!',
    error: 'Both Primary (Groq) and Fallback (Gemini) models failed or are missing API keys.'
  });
}
