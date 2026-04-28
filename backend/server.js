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

app.post('/chat', async (req, res) => {
  const { message, userId, context } = req.body ?? {};

  if (!message || typeof message != 'string' || !message.trim()) {
    return res.status(400).json({ error: 'message is required' });
  }

  if (userId != null && typeof userId !== 'string') {
    return res.status(400).json({ error: 'userId must be a string when provided' });
  }

  if (!openRouterApiKey) {
    return res.status(500).json({
      error: 'OPENROUTER_API_KEY is not configured on server',
    });
  }

  try {
    const contextText = context ? `\nContext: ${JSON.stringify(context)}` : '';
    const prompt = [
      'You are Buddy, a calm and supportive mental-health companion.',
      'Keep replies empathetic, concise, and non-diagnostic.',
      `User ID: ${userId ?? 'anonymous'}`,
      `User Message: ${message.trim()}`,
      contextText,
    ].join('\n');

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
        messages: [
          {
            role: 'system',
            content:
              'You are Buddy, a calm and supportive mental-health companion. Keep replies empathetic, concise, and non-diagnostic.',
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
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
