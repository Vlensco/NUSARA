import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel

app = FastAPI(title="AI Scholarship Matcher API")

# Setup Path & Model
BASE_MODEL_ID = "Qwen/Qwen2.5-1.5B-Instruct"
# Folder tempat adapter_model.safetensors berada (current directory)
ADAPTER_DIR = os.path.dirname(os.path.abspath(__file__)) 

# Load Tokenizer dan Base Model
print("⏳ Loading Tokenizer...")
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL_ID)

print("⏳ Loading Base Model (Ini mungkin memakan waktu beberapa menit dan butuh RAM lumayan)...")
# Menggunakan device_map="auto" agar otomatis mendeteksi CPU/GPU(MPS di Mac)
base_model = AutoModelForCausalLM.from_pretrained(
    BASE_MODEL_ID, 
    torch_dtype=torch.float16, 
    device_map="auto"
)

print("⏳ Loading LoRA Adapter dari file...")
model = PeftModel.from_pretrained(base_model, ADAPTER_DIR)
print("✅ Model AI Siap Digunakan!")

# Schema data profil user dari Flutter
class UserProfile(BaseModel):
    ipk: float
    semester: int
    jurusan: str
    provinsi: str
    pendapatan_ortu: int
    prestasi_count: int

class MatchResponse(BaseModel):
    result: str

@app.post("/api/match", response_model=MatchResponse)
async def get_scholarship_match(profile: UserProfile):
    try:
        # 1. Bikin Prompt berdasarkan data user
        prompt = f"""Kamu adalah AI spesialis beasiswa. Analisis profil berikut dan berikan estimasi persentase kecocokan beasiswa serta alasannya.
Profil Mahasiswa:
- IPK: {profile.ipk}
- Semester: {profile.semester}
- Jurusan: {profile.jurusan}
- Provinsi: {profile.provinsi}
- Pendapatan Orang Tua: Rp {profile.pendapatan_ortu}
- Jumlah Prestasi: {profile.prestasi_count}

Analisis:"""

        # 2. Format menggunakan template chat Qwen
        messages = [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": prompt}
        ]
        text = tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True
        )

        # 3. Masukkan ke Model AI
        model_inputs = tokenizer([text], return_tensors="pt").to(model.device)
        generated_ids = model.generate(
            model_inputs.input_ids,
            max_new_tokens=150,
            temperature=0.7
        )
        
        # 4. Potong output inputnya
        generated_ids = [
            output_ids[len(input_ids):] for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)
        ]
        
        # 5. Decode hasilnya ke teks biasa
        response = tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0]
        
        return MatchResponse(result=response)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
def read_root():
    return {"message": "AI Backend (Qwen2.5-1.5B + LoRA) is running!"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
