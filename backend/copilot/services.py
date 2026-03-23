import json
import re

from django.conf import settings


class BaseCopilotService:
    def get_greeting(self):
        return (
            "Hi! I'm your health copilot. I'm here to help you "
            "schedule a visit with the right doctor. "
            "Could you tell me what you've been experiencing?"
        )

    def get_response(self, history):
        raise NotImplementedError


class MockCopilotService(BaseCopilotService):
    """Simulates a symptom assessment conversation with scripted logic."""

    SYMPTOM_KEYWORDS = {
        'Cardiology': [
            'chest', 'heart', 'palpitation', 'shortness of breath',
            'blood pressure', 'dizzy', 'faint',
        ],
        'Dermatology': [
            'skin', 'rash', 'itch', 'acne', 'mole', 'bump', 'hives',
        ],
        'Orthopedics': [
            'bone', 'joint', 'knee', 'back pain', 'shoulder', 'fracture',
            'sprain', 'muscle', 'hip',
        ],
        'Neurology': [
            'headache', 'migraine', 'numbness', 'tingling', 'seizure',
            'memory', 'confusion', 'tremor',
        ],
        'ENT': [
            'ear', 'nose', 'throat', 'sinus', 'hearing', 'tonsil',
            'sore throat', 'congestion',
        ],
        'Gastroenterology': [
            'stomach', 'nausea', 'vomit', 'diarrhea', 'constipation',
            'abdominal', 'bloat', 'acid reflux', 'heartburn',
        ],
    }

    FOLLOW_UP_QUESTIONS = [
        "How long have you been experiencing these symptoms?",
        "On a scale of 1-10, how would you rate the severity?",
        "Have you taken any medication for this?",
    ]

    def _count_user_messages(self, history):
        return sum(1 for msg in history if msg['role'] == 'user')

    def _detect_specialty(self, history):
        all_user_text = ' '.join(
            msg['content'].lower()
            for msg in history
            if msg['role'] == 'user'
        )

        scores = {}
        for specialty, keywords in self.SYMPTOM_KEYWORDS.items():
            score = sum(1 for kw in keywords if kw in all_user_text)
            if score > 0:
                scores[specialty] = score

        if scores:
            return max(scores, key=scores.get)
        return 'General Practice'

    def _assess_urgency(self, history):
        all_user_text = ' '.join(
            msg['content'].lower()
            for msg in history
            if msg['role'] == 'user'
        )

        high_urgency = ['severe', 'unbearable', 'emergency', 'worst', '9', '10']
        medium_urgency = ['moderate', 'getting worse', 'persistent', '6', '7', '8']

        if any(word in all_user_text for word in high_urgency):
            return 'high'
        if any(word in all_user_text for word in medium_urgency):
            return 'medium'
        return 'low'

    def _build_summary(self, history):
        user_messages = [
            msg['content'] for msg in history if msg['role'] == 'user'
        ]
        return ' '.join(user_messages)[:200]

    def get_response(self, history):
        user_msg_count = self._count_user_messages(history)

        # Ask follow-up questions for the first 2-3 user messages
        if user_msg_count <= len(self.FOLLOW_UP_QUESTIONS):
            question = self.FOLLOW_UP_QUESTIONS[user_msg_count - 1]
            return {'content': question, 'recommendation': None}

        # After enough info, provide recommendation
        specialty = self._detect_specialty(history)
        urgency = self._assess_urgency(history)
        summary = self._build_summary(history)

        recommendation = {
            'specialty': specialty,
            'urgency': urgency,
            'summary': summary,
        }

        content = (
            f"Based on what you've described, I'd recommend seeing a "
            f"**{specialty}** specialist. "
            f"I'd rate the urgency as **{urgency}**.\n\n"
            f"Let me help you find an available doctor and schedule a visit."
        )

        return {'content': content, 'recommendation': recommendation}


class ClaudeCopilotService(BaseCopilotService):
    """Uses Claude API for intelligent symptom assessment."""

    SYSTEM_PROMPT = """You are a medical copilot helping patients schedule doctor visits.
Your role is to:
1. Ask about their symptoms (what, where, when, severity)
2. Ask 2-3 relevant follow-up questions based on their answers
3. After gathering enough information, provide a recommendation

When you have enough information, include a JSON block in your response:
```json
{"specialty": "<specialty>", "urgency": "<low|medium|high>", "summary": "<brief summary>"}
```

Available specialties: General Practice, Cardiology, Dermatology, Orthopedics, Neurology, ENT, Gastroenterology

Be empathetic, professional, and concise. You are NOT diagnosing — just helping route to the right specialist."""

    def get_response(self, history):
        import anthropic

        client = anthropic.Anthropic(api_key=settings.ANTHROPIC_API_KEY)

        api_messages = [
            {'role': msg['role'], 'content': msg['content']}
            for msg in history
            if msg['role'] in ('user', 'assistant')
        ]

        response = client.messages.create(
            model='claude-sonnet-4-20250514',
            max_tokens=500,
            system=self.SYSTEM_PROMPT,
            messages=api_messages,
        )

        content = response.content[0].text

        # Try to extract recommendation JSON
        recommendation = None
        json_match = re.search(r'```json\s*({.*?})\s*```', content, re.DOTALL)
        if json_match:
            try:
                recommendation = json.loads(json_match.group(1))
                content = re.sub(
                    r'```json\s*{.*?}\s*```', '', content, flags=re.DOTALL
                ).strip()
            except json.JSONDecodeError:
                pass

        return {'content': content, 'recommendation': recommendation}


def get_ai_service():
    backend = getattr(settings, 'AI_SERVICE_BACKEND', 'mock')
    if backend == 'claude':
        return ClaudeCopilotService()
    return MockCopilotService()
