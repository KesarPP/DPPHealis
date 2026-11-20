// Vercel Serverless Function: /api/chat
// Primary AI: Google Gemini (gemini-2.5-flash)

export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization');

  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return res.status(200).json({ status: 'OK' });
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed. Please use POST.' });
  }

  let body = req.body;
  if (typeof body === 'string') {
    try {
      body = JSON.parse(body);
    } catch (_) {
      body = {};
    }
  } else if (!body) {
    body = {};
  }

  const { message, history = [], user_id, user_context } = body;

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
  const geminiApiKey = (process.env.GEMINI_API_KEY || '').trim().replace(/^["']|["']$/g, '');

  // ─── GOOGLE GEMINI API (Primary: gemini-2.5-flash) ─────────────────────────
  let geminiErrorMsg = "";

  if (geminiApiKey) {
    // Gemini conversation requirements:
    // 1. Roles must be 'user' or 'model'
    // 2. The conversation in `contents` must begin with a 'user' turn
    // 3. Turns must strictly alternate between user and model
    const contents = [];
    if (Array.isArray(history)) {
      for (const h of history) {
        if (!h || !h.content || typeof h.content !== 'string') continue;
        const role = (h.role === 'assistant' || h.role === 'model') ? 'model' : 'user';

        // Skip leading assistant/model messages
        if (contents.length === 0 && role === 'model') continue;

        // Skip consecutive messages with the same role
        if (contents.length > 0 && contents[contents.length - 1].role === role) continue;

        contents.push({
          role,
          parts: [{ text: h.content }]
        });
      }
    }

    // If last history turn was user, drop it so current user message doesn't repeat 'user' role
    if (contents.length > 0 && contents[contents.length - 1].role === 'user') {
      contents.pop();
    }

    contents.push({
      role: 'user',
      parts: [{ text: message }]
    });

    const geminiModels = ['gemini-2.5-flash', 'gemini-3.8-flash', 'gemini-flash-latest'];
    for (const geminiModel of geminiModels) {
      try {
        console.log(`Attempting Gemini Model: ${geminiModel}...`);
        const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:generateContent?key=${geminiApiKey}`;

        const geminiReq = await fetch(geminiUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            systemInstruction: {
              parts: [{ text: systemInstruction }]
            },
            contents,
            generationConfig: {
              temperature: 0.7,
              maxOutputTokens: 2048
            }
          }),
          signal: AbortSignal.timeout(9000)
        });

        if (geminiReq.ok) {
          const geminiData = await geminiReq.json();
          const reply = geminiData.candidates?.[0]?.content?.parts?.[0]?.text;
          if (reply) {
            console.log(`Successfully generated response via Gemini (${geminiModel}).`);
            return res.status(200).json({ response: reply, model: geminiModel });
          }
        } else {
          const errText = await geminiReq.text();
          geminiErrorMsg = `Gemini API Error (${geminiModel} - ${geminiReq.status}): ${errText}`;
          console.error(geminiErrorMsg);
          if (geminiReq.status === 404) continue;
          break;
        }
      } catch (geminiError) {
        geminiErrorMsg = `Gemini Fetch Exception (${geminiModel}): ${geminiError.message}`;
        console.error(geminiErrorMsg);
      }
    }
  } else {
    geminiErrorMsg = "GEMINI_API_KEY is missing or contains placeholder.";
    console.error(geminiErrorMsg);
  }

  // ─── FINAL FALLBACK: ERROR MESSAGE ─────────────────────────────────────────
  return res.status(200).json({
    response: `⚠️ AI API Request Failed.\n\n${geminiErrorMsg}\n\nPlease check your Gemini API key and quota!`,
    error: 'Gemini API call failed.'
  });
}
