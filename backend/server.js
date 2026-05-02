import 'dotenv/config';
import express from 'express';
import cors from 'cors';

const app = express();
const port = process.env.PORT || 8080;
const openRouterApiKey = process.env.OPENROUTER_API_KEY;
const openRouterModel = process.env.OPENROUTER_MODEL || 'openrouter/free';

app.use(cors());
app.use(express.json());

app.get('/', (_req, res) => {
  res.json({ status: 'ok', service: 'Buddy backend' });
});

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

function sanitizeFirstName(value) {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  if (!trimmed) return null;
  const first = trimmed.split(/\s+/)[0]?.replace(/[^A-Za-z'-]/g, '');
  if (!first) return null;
  return `${first.charAt(0).toUpperCase()}${first.slice(1).toLowerCase()}`;
}

function sanitizeHistory(value) {
  if (value == null) return [];
  if (!Array.isArray(value)) return null;

  const normalized = value
    .map((item) => {
      if (!item || typeof item !== 'object') return null;
      const role = item.role === 'assistant' ? 'assistant' : item.role === 'user' ? 'user' : null;
      const content = typeof item.content === 'string' ? item.content.trim() : '';
      if (!role || !content) return null;
      return { role, content };
    })
    .filter(Boolean);

  return normalized.slice(-12);
}

app.post('/chat', async (req, res) => {
  const { message, userId, context, history, firstName } = req.body ?? {};

  if (!message || typeof message != 'string' || !message.trim()) {
    return res.status(400).json({ error: 'message is required' });
  }

  if (userId != null && typeof userId !== 'string') {
    return res.status(400).json({ error: 'userId must be a string when provided' });
  }

  const sanitizedHistory = sanitizeHistory(history);
  if (history !== undefined && sanitizedHistory == null) {
    return res.status(400).json({ error: 'history must be an array when provided' });
  }

  const sanitizedFirstName = sanitizeFirstName(firstName);
  if (firstName !== undefined && firstName !== null && sanitizedFirstName == null) {
    return res.status(400).json({ error: 'firstName must be a non-empty string when provided' });
  }

  if (!openRouterApiKey) {
    return res.status(500).json({
      error: 'OPENROUTER_API_KEY is not configured on server',
    });
  }

  try {
    const nameInstruction = sanitizedFirstName
      ? `The user's first name is ${sanitizedFirstName}. Use it naturally when appropriate.`
      : '';

    const systemMessage = [
      'You are Buddy, a warm, supportive AI companion. Be helpful, gentle, and clear.',
      'Remember the conversation context provided in recent messages.',
      'If the user\'s first name is available, use it naturally, but not in every single reply.',
      'Do not pretend to remember things that are not in the current context.',
      nameInstruction,
    ]
      .filter(Boolean)
      .join(' ');

    const userContent = [
      message.trim(),
      context ? `Context: ${JSON.stringify(context)}` : '',
    ]
      .filter(Boolean)
      .join('\n\n');

    const messages = [
      {
        role: 'system',
        content: systemMessage,
      },
      ...(sanitizedHistory ?? []),
      {
        role: 'user',
        content: userContent,
      },
    ];

    const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${openRouterApiKey}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://buddy.local',
        'X-Title': 'Buddy',
      },
      body: JSON.stringify({
        model: openRouterModel,
        temperature: 0.7,
        max_tokens: 300,
        messages,
      }),
    });

    if (!response.ok) {
      const errorBody = await response.text();
      console.error('OpenRouter error:', response.status, errorBody);
      return res.status(502).json({
        error: 'Upstream AI service error',
      });
    }

    const data = await response.json();
    const rawContent = data?.choices?.[0]?.message?.content;
    const reply =
      (typeof rawContent === 'string'
        ? rawContent
        : Array.isArray(rawContent)
          ? rawContent
              .map((part) =>
                typeof part === 'string'
                  ? part
                  : typeof part?.text === 'string'
                    ? part.text
                    : '',
              )
              .join('')
          : '') ||
      "I'm here with you. Can you share a little more about how you're feeling?";

    return res.json({ reply });
  } catch (error) {
    console.error('POST /chat failed:', error);
    return res.status(500).json({ error: 'Failed to process chat request' });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Buddy backend running on port ${port}`);
});
