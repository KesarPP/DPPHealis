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

  const { message, history = [], user_id, user_context } = req.body;

  if (!message) {
    return res.status(400).json({ error: 'Missing "message" in request body.' });
  }

  let systemInstruction =
    'You are an expert AI Health Coach for the Digital Diabetes Prevention Program (DPP) app. Your sole purpose is to assist users with diabetes management, prediabetes, healthy nutrition, physical activity, sleep, weight management, overall wellness, and navigating the DPP app.\n\n' +
    'APP KNOWLEDGE & MODULES (Use this to answer questions about the app):\n' +
    '- IDRS (Indian Diabetes Risk Score): An assessment module to determine a user\'s risk of developing Type 2 diabetes based on age, abdominal obesity, family history, and physical activity. A higher score indicates higher risk.\n' +
    '- GPAQ (Global Physical Activity Questionnaire): An assessment that evaluates a user\'s physical activity levels. It calculates MET-minutes and categorizes activity into High, Moderate, or Low.\n' +
    '- FFQ (Food Frequency Questionnaire): An assessment used to understand a user\'s long-term eating habits and frequency of consuming various food groups.\n' +
    '- Food Log Page: A daily tracking module where users log their meals (breakfast, lunch, dinner, snacks). It tracks calorie intake, macronutrients (carbs, proteins, fats), and helps users maintain a healthy diet.\n' +
    '- Activity Page: A tracking module that syncs with health services (like Health Connect/Google Fit/Apple Health) to pull daily active minutes and steps. It tracks "qualifying sessions" (e.g., 10+ minutes of brisk walking) and calculates the user\'s daily activity streak.\n' +
    '- Session Page (Curriculum): The educational core of the DPP (Diabetes Prevention Program). It consists of weekly learning modules (e.g., Session 1 to Session 16) covering topics like healthy eating, being active, and overcoming barriers. Completing sessions unlocks achievements.\n' +
    '- Weekly Weigh-in: A tracking feature where users log their weight once a week to monitor progress toward the DPP goal of 5-7% body weight loss.\n' +
    '- Coach Chat: A messaging interface where users can talk to their assigned human clinician/coach (like Dr. Sarah Mitchell) for medical advice and personalized program guidance.\n\n' +
    'STRICT GUARDRAILS & RULES:\n' +
    '1. You MUST answer questions about the DPP app, its features (IDRS, GPAQ, FFQ, Food Log, Activity, Sessions, Weigh-ins, Coach Chat), and general health, nutrition, wellness, and diabetes.\n' +
    '2. DO NOT answer questions or perform tasks strictly unrelated to health, nutrition, wellness, diabetes, or the DPP app.\n' +
    '3. IMPORTANT EXCEPTION FOR CONVERSATION CONTINUITY: If the user asks to summarize, shorten, elaborate, rewrite, or clarify a previous response, DO NOT refuse!\n' +
    '4. If a user asks for programming code, general trivia, historical facts, entertainment, or anything entirely outside the scope of health/wellness/app support, you MUST refuse politely.\n' +
    '5. Refusal template for STRICTLY off-topic questions: "I am your DPP Health Coach. I am here to help you with diabetes prevention, nutrition, and healthy living, as well as questions about this app. I cannot assist with non-health topics like [topic]."\n' +
    '6. Provide supportive, empathetic, and evidence-based health guidance. When explaining app features (like IDRS or GPAQ), be clear and encouraging.\n' +
    '7. Always remind users to consult a certified medical professional or their assigned human coach in the app for formal medical diagnoses.';

  if (user_context) {
    systemInstruction += '\n\nUSER PROGRESS CONTEXT:\n' + user_context + '\nUse this user context to provide personalized recommendations. Acknowledge their streaks, activity levels, and meal logging when relevant.';
  }

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
