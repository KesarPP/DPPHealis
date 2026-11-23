# DiaPrevent (DPPHealis)

**DiaPrevent** is a cross-platform digital health mobile application implementing the evidence-based National Diabetes Prevention Program (NDPP) curriculum tailored for Indian dietary, genetic, and lifestyle contexts.

---

## 📚 Complete Codebase Documentation

For a comprehensive explanation of every folder, file, service, screen, and architectural module in this repository, please consult:

👉 **[CODEBASE_DOCUMENTATION.md](CODEBASE_DOCUMENTATION.md)**

---

## 🚀 Key Modules & Architecture

- **Flutter Mobile App (`lib/`):** Full cross-platform client (Android, iOS, Web, Desktop) featuring validated risk assessments (IDRS, GPAQ, FFQ), daily meal and physical activity tracking, weekly weigh-in targets (5–7% weight loss), gamified 16-week retro adventure maps, and an antique skeuomorphic manuscript reader.
- **Web Admin Portal (`admin-panel/`):** React 18 + Vite clinical dashboard for healthcare providers and coaches to manage patient cohorts, monitor adherence, and manage assignments.
- **AI Coaching Backend (`vercel_ai_backend/`):** Serverless Google Gemini AI proxy providing 24/7 personalized health coaching with strict clinical guardrails.
- **Backend Infrastructure (`firebase_functions/` & Cloud Firestore):** Real-time Firestore synchronization, Firebase Authentication, security rules, and automated cleanup Cloud Functions.
- **Device Health Integrations:** Android Health Connect and Apple Health synchronization for step counts and active minutes.
