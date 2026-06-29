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

  const { message, history = [], user_id } = req.body;

  if (!message) {
    return res.status(400).json({ error: 'Missing "message" in request body.' });
  }

  const systemInstruction =
    'You are an expert AI Health Coach for the Digital Diabetes Prevention Program (DPP). Your sole purpose is to assist users with diabetes management, prediabetes, healthy nutrition, physical activity, sleep, weight management, and overall wellness.\n\n' +
    'STRICT GUARDRAILS & RULES:\n' +
    '1. DO NOT answer questions or perform tasks unrelated to health, nutrition, wellness, or diabetes.\n' +
    '2. IMPORTANT EXCEPTION FOR CONVERSATION CONTINUITY: If the user asks to summarize, shorten, elaborate, rewrite, or clarify a previous response (e.g., "can you short the answer", "make it shorter", "explain more", "give me bullet points"), DO NOT refuse! You must look at the conversation history and fulfill their formatting/summary request for the health topic.\n' +
    '3. If a user asks for programming code (e.g., Python, JavaScript), general trivia, historical facts, entertainment, or anything outside the scope of health/wellness, you MUST refuse politely.\n' +
    '4. Use this refusal template for off-topic questions: "I am your DPP Health Coach. I am here to help you with diabetes prevention, nutrition, and healthy living. I cannot assist with non-health topics like [topic]."\n' +
    '5. Provide supportive, empathetic, and evidence-based health guidance.\n' +
    '6. Always remind users to consult a certified medical professional for formal medical diagnoses.';

  // ─── API KEY CONFIGURATION ────────────────────────────────────────────────
  // You can either set these in Vercel Environment Variables OR paste them directly below:
  const groqApiKey = process.env.GROQ_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;

  // ─── 1. PRIMARY AI: GROQ API ───────────────────────────────────────────────
  let groqErrorMsg = "";
  let geminiErrorMsg = "";

  if (groqApiKey && !groqApiKey.includes('PASTE_YOUR')) {
    try {
      console.log('Attempting Primary Model: Groq (llama-3.1-8b-instant)...');
      const groqReq = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${groqApiKey}`
        },
        body: JSON.stringify({
          model: 'llama-3.1-8b-instant',
          messages: [
            { role: 'system', content: systemInstruction },
            ...history,
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
          return res.status(200).json({ response: reply, model: 'groq-llama-3.1-8b-instant' });
        }
      } else {
        const errText = await groqReq.text();
        groqErrorMsg = `Groq API Error (${groqReq.status}): ${errText}`;
        console.warn(groqErrorMsg);
      }
    } catch (groqError) {
      groqErrorMsg = `Groq Fetch Exception: ${groqError.message}`;
      console.warn(groqErrorMsg, groqError);
    }
  } else {
    groqErrorMsg = "GROQ_API_KEY is missing or contains placeholder.";
    console.warn(groqErrorMsg);
  }

  // ─── 2. FALLBACK AI: GOOGLE GEMINI API ─────────────────────────────────────
  if (geminiApiKey && !geminiApiKey.includes('PASTE_YOUR')) {
    try {
      console.log('Attempting Fallback Model: Google Gemini (gemini-2.0-flash)...');
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${geminiApiKey}`;
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
            ...history.map(h => ({
              role: h.role === 'assistant' ? 'model' : 'user',
              parts: [{ text: h.content }]
            })),
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
          return res.status(200).json({ response: reply, model: 'gemini-2.0-flash' });
        }
      } else {
        const errText = await geminiReq.text();
        geminiErrorMsg = `Gemini API Error (${geminiReq.status}): ${errText}`;
        console.error(geminiErrorMsg);
      }
    } catch (geminiError) {
      geminiErrorMsg = `Gemini Fetch Exception: ${geminiError.message}`;
      console.error(geminiErrorMsg, geminiError);
    }
  } else {
    geminiErrorMsg = "GEMINI_API_KEY is missing or contains placeholder.";
    console.error(geminiErrorMsg);
  }

  // ─── 3. FINAL FALLBACK: ERROR / MOCK MESSAGE ───────────────────────────────
  // Return status 200 so the Flutter app displays the exact API error details in the chat bubble!
  return res.status(200).json({
    response: `⚠️ AI API Request Rejected by Groq & Gemini.\n\n1. ${groqErrorMsg}\n\n2. ${geminiErrorMsg}\n\nPlease check that your API keys are active and valid!`,
    error: 'API keys rejected.'
  });
}
