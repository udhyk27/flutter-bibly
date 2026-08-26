const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const { initializeApp } = require("firebase-admin/app");
const { getRemoteConfig } = require("firebase-admin/remote-config");
const { getAppCheck } = require("firebase-admin/app-check");

initializeApp();

const geminiApiKey = defineSecret("GEMINI_API_KEY");

// App Check 토큰 검증. 유효하면 true, 없거나 위조면 res로 401 응답 후 false.
// (raw HTTP 함수는 App Check가 자동 적용되지 않아 헤더를 직접 검증한다.)
async function verifyAppCheck(req, res) {
  const token = req.header("X-Firebase-AppCheck");
  if (!token) {
    res.status(401).json({ error: "App Check 토큰이 없습니다." });
    return false;
  }
  try {
    await getAppCheck().verifyToken(token);
    return true;
  } catch (e) {
    console.error("App Check 검증 실패:", e);
    res.status(401).json({ error: "유효하지 않은 App Check 토큰입니다." });
    return false;
  }
}

const DEFAULT_AI_MODEL = "gemini-2.5-flash-lite";

// Remote Config 템플릿은 매 요청마다 받지 않고 10분간 캐싱한다.
const AI_MODEL_TTL_MS = 10 * 60 * 1000;
let _aiModelCache = { value: DEFAULT_AI_MODEL, fetchedAt: 0 };

// Remote Config에서 aiModel 가져오기 (앱은 ai_model, 과거 설정은 aiModel 키를 사용)
async function getAiModel() {
  const now = Date.now();
  if (now - _aiModelCache.fetchedAt < AI_MODEL_TTL_MS) {
    return _aiModelCache.value;
  }

  try {
    const rc = getRemoteConfig();
    const template = await rc.getTemplate();
    const params = template.parameters ?? {};
    const value =
      params.ai_model?.defaultValue?.value ??
      params.aiModel?.defaultValue?.value ??
      DEFAULT_AI_MODEL;

    _aiModelCache = { value, fetchedAt: now };
    return value;
  } catch (e) {
    console.error("Remote Config 조회 실패:", e);
    // 실패 시 마지막으로 알려진 값(없으면 기본값) 사용
    return _aiModelCache.value;
  }
}

exports.askBible = onRequest(
  { secrets: [geminiApiKey] },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Methods", "POST");
      res.set("Access-Control-Allow-Headers", "Content-Type, X-Firebase-AppCheck");
      return res.status(204).send("");
    }

    if (!(await verifyAppCheck(req, res))) return;

    try {
      const { verse, question } = req.body;
      if (!verse || !question) {
        return res.status(400).json({ error: "verse와 question이 필요합니다." });
      }

      const aiModel = await getAiModel();
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({ model: aiModel });

    const prompt = `
        당신은 성경 말씀을 돕는 AI입니다.
        자투리 단어 없이 질문에 대한 답변만 존댓말로 답변하세요.
        형식은 "이 구절은 ~~~ 입니다." 로만 답변해주세요.
        반드시 2문장으로만 답변하세요. 그 이상 절대 쓰지 마세요.

        [구절] ${verse}
        [질문] ${question}
    `;

      const result = await model.generateContent(prompt);
      return res.status(200).json({ answer: result.response.text() });
    } catch (error) {
      console.error("Gemini API 오류:", error);
      return res.status(500).json({ error: "AI 응답 중 오류가 발생했습니다." });
    }
  }
);

exports.getBibleStory = onRequest(
  { secrets: [geminiApiKey] },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Methods", "POST");
      res.set("Access-Control-Allow-Headers", "Content-Type, X-Firebase-AppCheck");
      return res.status(204).send("");
    }

    if (!(await verifyAppCheck(req, res))) return;

    try {
      const { bookName } = req.body;
      if (!bookName) {
        return res.status(400).json({ error: "bookName이 필요합니다." });
      }

      const aiModel = await getAiModel();
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({ model: aiModel },);

      const stories = [
        '가장 드라마틱한 사건이나 반전',
        '잘 알려지지 않은 숨겨진 이야기',
        '주요 인물의 실수나 갈등',
        '당시 시대적 배경과 문화',
        '하나님과 인간의 특별한 만남',
      ];
      const angle = stories[Math.floor(Math.random() * stories.length)];

      const prompt = `
      성경 "${bookName}"에서 실제로 있었던 흥미로운 이야기를 아래 JSON 형식으로만 답변해주세요.
      마크다운, 코드블록, 설명 없이 JSON만 출력하세요.

      관점: ${angle}

      {
        "title": "흥미로운 제목 (질문형이나 호기심 유발 형태로)",
        "content": "해당 이야기를 쉽고 흥미롭게 3~4문장으로 설명",
        "reference": "관련 구절 (장:절)"
      }
      `;

      const result = await model.generateContent(prompt);
      let text = result.response.text().trim();

      // 마크다운 코드블록 제거
      text = text.replace(/```json/g, '').replace(/```/g, '').trim();

      // 모델이 JSON 앞뒤에 설명 문구를 덧붙이는 경우가 있어,
      // 첫 '{' 부터 마지막 '}' 까지만 잘라내 파싱한다.
      const start = text.indexOf('{');
      const end = text.lastIndexOf('}');
      if (start !== -1 && end !== -1 && end > start) {
        text = text.slice(start, end + 1);
      }

      let json;
      try {
        json = JSON.parse(text);
      } catch (parseErr) {
        console.error("이야기 JSON 파싱 실패:", parseErr, "원문:", text);
        return res
          .status(502)
          .json({ error: "AI 응답 형식 오류로 이야기를 만들지 못했습니다." });
      }

      return res.status(200).json({
        title: json.title ?? "",
        content: json.content ?? "",
        reference: json.reference ?? "",
      });
    } catch (error) {
      console.error("Gemini API 오류:", error);
      return res.status(500).json({ error: "AI 응답 중 오류가 발생했습니다." });
    }
  }
);