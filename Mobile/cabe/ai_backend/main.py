import os
import re
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import uvicorn
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel

app = FastAPI(title="AI Scholarship Matcher API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Setup Path & Model
BASE_MODEL_ID = "Qwen/Qwen2.5-1.5B-Instruct"
ADAPTER_DIR = os.path.dirname(os.path.abspath(__file__))

print("⏳ Loading Tokenizer...")
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL_ID)

print("⏳ Loading Base Model...")
base_model = AutoModelForCausalLM.from_pretrained(
    BASE_MODEL_ID,
    torch_dtype=torch.float16,
    device_map="auto"
)

print("⏳ Loading LoRA Adapter...")
model = PeftModel.from_pretrained(base_model, ADAPTER_DIR)
print("✅ Model AI Siap Digunakan!")

# Schema
class UserProfile(BaseModel):
    ipk: float
    semester: int
    jurusan: str
    provinsi: str
    pendapatan_ortu: int
    prestasi_count: int
    scholarship_title: Optional[str] = "Beasiswa Umum"
    min_nilai: Optional[float] = 70.0

class MatchResponse(BaseModel):
    result: str
    match_percentage: int

def _extract_percentage(text: str) -> int:
    """Ekstrak angka persentase dari teks AI"""
    matches = re.findall(r'(\d{1,3})\s*%', text)
    if not matches:
        matches = re.findall(r'(\d{1,3})\s*persen', text, re.IGNORECASE)

    values = [int(m) for m in matches if 0 < int(m) <= 100]
    if values:
        return int(sum(values) / len(values))
    return 0

def _rule_based_match(profile: UserProfile) -> int:
    """Fallback rule-based scoring jika AI tidak memberikan persentase"""
    score = 0
    nilai_scaled = profile.ipk * 10 if profile.ipk <= 10 else profile.ipk

    if nilai_scaled >= profile.min_nilai:
        score += 40
    elif nilai_scaled >= profile.min_nilai - 5:
        score += 20

    if profile.semester >= 1:
        score += 30

    score += 20

    if profile.prestasi_count > 0:
        score += min(profile.prestasi_count * 3, 10)

    return min(score, 100)

@app.post("/api/match", response_model=MatchResponse)
def get_scholarship_match(profile: UserProfile):
    try:
        prompt = f"""Kamu adalah AI spesialis beasiswa Indonesia. Analisis kecocokan profil pelajar berikut untuk {profile.scholarship_title} dan berikan SATU ANGKA persentase kecocokan (0-100%).

Profil Pelajar:
- Nilai rata-rata: {profile.ipk} (skala 0-10) / {profile.ipk * 10:.0f} (skala 100)
- Semester: {profile.semester}
- Jurusan: {profile.jurusan}
- Jumlah Prestasi: {profile.prestasi_count}
- Persyaratan minimum nilai beasiswa: {profile.min_nilai}

Jawab HANYA dengan format: "Persentase kecocokan: XX%" diikuti alasan singkat 1-2 kalimat."""

        messages = [
            {"role": "system", "content": "Kamu adalah asisten AI ahli analisis beasiswa. Berikan estimasi persentase kecocokan beasiswa secara singkat dan akurat."},
            {"role": "user", "content": prompt}
        ]
        text = tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True
        )

        model_inputs = tokenizer([text], return_tensors="pt").to(model.device)
        generated_ids = model.generate(
            model_inputs.input_ids,
            max_new_tokens=120,
            temperature=0.3,
            do_sample=True,
        )

        generated_ids = [
            output_ids[len(input_ids):]
            for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)
        ]

        response_text = tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0]

        pct = _extract_percentage(response_text)
        if pct == 0:
            pct = _rule_based_match(profile)

        return MatchResponse(result=response_text, match_percentage=pct)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
def read_root():
    return {"message": "AI Backend (Qwen2.5-1.5B + LoRA) is running!", "status": "ok"}

@app.get("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
