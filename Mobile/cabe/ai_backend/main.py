import os
import re

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

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
# ─── Schema untuk Pencocokan (Lightweight Matching) ───
class MatchProfile(BaseModel):
    # Data Profil Pengguna
    user_jenjang: str          # Contoh: "SMA", "SMK", "D3", "S1"
    user_usia: int             # Contoh: 18
    user_bidang_studi: str     # Contoh: "Informatika", "IPA", "Semua"
    user_ipk: float            # Contoh: 85.0 (Rapor) atau 3.75 (IPK)
    
    # Syarat Beasiswa yang Sedang Dicek
    scholarship_title: str     # Contoh: "Beasiswa Unggulan Kemendikbud"
    req_jenjang: list[str]     # Contoh: ["SMA", "SMK", "S1"]
    req_batas_usia: int        # Contoh: 22
    req_bidang_studi: list[str]# Contoh: ["Informatika", "Semua Jurusan"]
    req_min_ipk: float         # Contoh: 75.0 (Rapor) atau 3.0 (IPK)

class MatchResponse(BaseModel):
    match_percentage: int
    matched_params: int
    total_params: int
    ai_message: str

# ─── Logika Perhitungan Rumus (Lightweight Matching) ───
def _lightweight_matching(data: MatchProfile) -> dict:
    """Hitung persentase kecocokan secara matematis (tanpa AI)."""
    total_params = 4
    fulfilled = 0
    
    # 1. Parameter Jenjang Pendidikan
    if data.user_jenjang in data.req_jenjang or "Semua Jenjang" in data.req_jenjang:
        fulfilled += 1
        
    # 2. Parameter Batas Usia
    if data.user_usia <= data.req_batas_usia:
        fulfilled += 1
        
    # 3. Parameter Bidang Studi
    if data.user_bidang_studi in data.req_bidang_studi or "Semua Jurusan" in data.req_bidang_studi:
        fulfilled += 1
        
    # 4. Parameter Nilai Akademik
    if data.user_ipk >= data.req_min_ipk:
        fulfilled += 1
        
    percentage = int((fulfilled / total_params) * 100)
    
    return {
        "percentage": percentage,
        "fulfilled": fulfilled,
        "total": total_params
    }

# ─── Endpoint API Match ───
@app.post("/api/match", response_model=MatchResponse)
def get_scholarship_match(data: MatchProfile):
    try:
        # 1. Backend menghitung angka secara pasti lewat rumus (Lightweight Matching)
        match_result = _lightweight_matching(data)
        pct = match_result["percentage"]
        fulfilled = match_result["fulfilled"]
        total = match_result["total"]

        # 2. Teks Prompt untuk AI Agent
        prompt = f"""Pengguna baru saja mengecek kecocokan profilnya dengan beasiswa: "{data.scholarship_title}". 
Sistem (Backend) telah menghitung secara otomatis bahwa tingkat kecocokan pengguna adalah: {pct}%.

Tugasmu:
Buatkan maksimal 2 kalimat singkat yang ramah dan memotivasi untuk ditampilkan di layar aplikasi (UI) guna memberitahu pengguna mengenai hasil persentase ini.

Aturan ketat:
1. JIKA persentase >= 70%: Berikan ucapan selamat/antusias dan dorong mereka untuk segera menyiapkan dokumen pendaftaran.
2. JIKA persentase < 70%: Berikan semangat, sarankan untuk mencari opsi beasiswa lain yang lebih pas.
3. DILARANG KERAS menjelaskan rumus, menyebutkan jumlah parameter, atau melakukan perhitungan matematika apapun di dalam balasanmu!
4. Gunakan bahasa gaul yang sopan (seperti "Kamu", "Yuk") khas aplikasi CaBe."""

        messages = [
            {
                "role": "system", 
                "content": "Kamu adalah 'CaBe', AI Mentor Beasiswa yang ramah, ringkas, dan suportif. Kamu hanya bertugas menyampaikan hasil perhitungan sistem dengan kalimat yang memotivasi, BUKAN sebagai kalkulator."
            },
            {
                "role": "user", 
                "content": prompt
            }
        ]
        
        text = tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True
        )

        model_inputs = tokenizer([text], return_tensors="pt").to(model.device)
        generated_ids = model.generate(
            model_inputs.input_ids,
            max_new_tokens=100,
            temperature=0.4, # Suhu rendah agar respon lebih fokus
            do_sample=True,
        )

        generated_ids = [
            output_ids[len(input_ids):]
            for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)
        ]

        response_text = tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0].strip()

        return MatchResponse(
            match_percentage=pct,
            matched_params=fulfilled,
            total_params=total,
            ai_message=response_text
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
class ReadinessProfile(BaseModel):
    # Data Profil Pengguna
    user_name: str = "Pengguna"  # Nama user untuk tips personalisasi
    
    # Akademik (40%)
    tipe_nilai: str = "rapor"  # "rapor" (skala 0-100) atau "ipk" (skala 0-4.0)
    nilai_rapor: float  # angka mentah dari user

    # Finansial (25%)
    penghasilan_ortu: str       # "< 1 juta", "1 - 3 Juta", "3 - 5 Juta", "> 5 Juta"
    bantuan_sosial: str         # "Ada", "Tidak ada"
    tanggungan: str             # "> 4", "3 - 4", "1 - 2", "Tidak ada"
    pekerjaan_ortu: str         # "Tidak Tetap", "Informal", "Tetap"

    # Non-Akademik (25%)
    level_prestasi: str         # "Internasional", "Nasional", "Provinsi", "Sekolah", "Tidak ada"
    jumlah_prestasi: str        # "> 3", "2 - 3", "1", "Tidak Ada"
    organisasi: str             # "Ketua / Leader", "Pengurus Aktif", "Anggota", "Tidak ada"
    aktivitas_tambahan: str     # "Aktif (>2 kegiatan)", "Pernah ikut", "Tidak ada"

    # Sertifikat / Rekomendasi (5%)
    dokumen_pendukung: list[str]  # ["Rekomendasi", "CV", "Sertifikat Khusus"]

    # Motivasi & Karir (5%)
    kejelasan_tujuan: str       # "Sudah jelas dan spesifik", "Sudah ada gambaran", "Belum yakin"
    tujuan_karir: str           # "Sudah jelas", "Masih umum", "Belum ada"
    keterkaitan: str            # "Sangat sesuai", "Cukup sesuai", "Belum sesuai / belum tahu"

class ReadinessResponse(BaseModel):
    total_score: float
    skor_akademik: float
    skor_finansial: float
    skor_non_akademik: float
    skor_sertifikat: float
    skor_motivasi: float
    label: str
    tips: str

def _calculate_readiness(p: ReadinessProfile) -> dict:
    """Hitung skor kesiapan beasiswa berdasarkan rule-based scoring."""
    # 1. AKADEMIK (40%) — normalisasi nilai berdasarkan tipe
    if p.tipe_nilai == "ipk":
        # Konversi IPK (0-4) ke skala 100: IPK × 25
        raw_akademik = min(p.nilai_rapor * 25, 100)
    else:
        # Sudah dalam skala 0-100
        raw_akademik = min(p.nilai_rapor, 100)
    final_akademik = (raw_akademik / 100) * 40

    # 2. FINANSIAL (25%) — max 100 poin internal
    skor_fin = 0
    if p.penghasilan_ortu == "< 1 juta": skor_fin += 40
    elif p.penghasilan_ortu == "1 - 3 Juta": skor_fin += 30
    elif p.penghasilan_ortu == "3 - 5 Juta": skor_fin += 20
    else: skor_fin += 10

    if p.bantuan_sosial == "Ada": skor_fin += 25

    if p.tanggungan == "> 4": skor_fin += 20
    elif p.tanggungan == "3 - 4": skor_fin += 15
    elif p.tanggungan == "1 - 2": skor_fin += 10

    if p.pekerjaan_ortu == "Tidak Tetap": skor_fin += 15
    elif p.pekerjaan_ortu == "Informal": skor_fin += 10
    elif p.pekerjaan_ortu == "Tetap": skor_fin += 5

    final_finansial = (skor_fin / 100) * 25

    # 3. NON-AKADEMIK (25%) — max 100 poin internal
    skor_na = 0
    if p.level_prestasi == "Internasional": skor_na += 50
    elif p.level_prestasi == "Nasional": skor_na += 45
    elif p.level_prestasi == "Provinsi": skor_na += 35
    elif p.level_prestasi == "Sekolah": skor_na += 25

    if p.jumlah_prestasi == "> 3": skor_na += 10
    elif p.jumlah_prestasi == "2 - 3": skor_na += 7
    elif p.jumlah_prestasi == "1": skor_na += 5

    if p.organisasi == "Ketua / Leader": skor_na += 30
    elif p.organisasi == "Pengurus Aktif": skor_na += 20
    elif p.organisasi == "Anggota": skor_na += 10

    if p.aktivitas_tambahan == "Aktif (>2 kegiatan)": skor_na += 10
    elif p.aktivitas_tambahan == "Pernah ikut": skor_na += 5

    final_non_akademik = (skor_na / 100) * 25

    # 4. SERTIFIKAT (5%) — max 100 poin internal
    skor_sert = 0
    if "Rekomendasi" in p.dokumen_pendukung: skor_sert += 80
    if "CV" in p.dokumen_pendukung: skor_sert += 10
    if "Sertifikat Khusus" in p.dokumen_pendukung: skor_sert += 10
    final_sertifikat = (skor_sert / 100) * 5

    # 5. MOTIVASI (5%) — max 100 poin internal
    skor_mot = 0
    if p.kejelasan_tujuan == "Sudah jelas dan spesifik": skor_mot += 40
    elif p.kejelasan_tujuan == "Sudah ada gambaran": skor_mot += 25
    elif p.kejelasan_tujuan == "Belum yakin": skor_mot += 10

    if p.tujuan_karir == "Sudah jelas": skor_mot += 40
    elif p.tujuan_karir == "Masih umum": skor_mot += 25
    elif p.tujuan_karir == "Belum ada": skor_mot += 10

    if p.keterkaitan == "Sangat sesuai": skor_mot += 20
    elif p.keterkaitan == "Cukup sesuai": skor_mot += 10

    final_motivasi = (skor_mot / 100) * 5

    total = round(final_akademik + final_finansial + final_non_akademik + final_sertifikat + final_motivasi, 2)

    # Label status
    if total >= 80:
        label = "Sangat Siap!"
    elif total >= 60:
        label = "Siap"
    elif total >= 40:
        label = "Cukup Siap"
    else:
        label = "Perlu Persiapan"

    # Identifikasi area terlemah untuk tips
    scores = {
        "Akademik": (raw_akademik, 40),
        "Finansial": (skor_fin, 25),
        "Non-Akademik": (skor_na, 25),
        "Sertifikat": (skor_sert, 5),
        "Motivasi": (skor_mot, 5),
    }
    weakest = min(scores, key=lambda k: scores[k][0])

    return {
        "total": total,
        "skor_akademik": round(final_akademik, 2),
        "skor_finansial": round(final_finansial, 2),
        "skor_non_akademik": round(final_non_akademik, 2),
        "skor_sertifikat": round(final_sertifikat, 2),
        "skor_motivasi": round(final_motivasi, 2),
        "label": label,
        "weakest": weakest,
        "raw_scores": scores,
    }


def _clean_tips_format(raw_tips: str, weakest: str, result: dict, user_name: str = "Pengguna") -> str:
    """Post-process AI tips to ensure consistent structured format."""
    
    # Remove any markdown artifacts from AI (e.g., ```text blocks)
    cleaned = raw_tips.strip()
    cleaned = re.sub(r'```\w*\n?', '', cleaned)
    cleaned = cleaned.replace('```', '')
    
    # Check if AI output already has the expected format
    has_ringkasan = 'Ringkasan Evaluasi' in cleaned
    has_langkah = 'Langkah Peningkatan' in cleaned
    
    # Count numbered items (1. **...**:, 2. **...**:, 3. **...**:)
    numbered_items = re.findall(r'\d+\.\s*\*\*', cleaned)
    has_3_items = len(numbered_items) >= 3
    
    if has_ringkasan and has_langkah and has_3_items:
        # Normalize whitespace: ensure consistent newlines
        # Remove excessive blank lines (more than 2 consecutive)
        cleaned = re.sub(r'\n{3,}', '\n\n', cleaned)
        return cleaned.strip()
    
    # ─── Fallback: Generate structured tips from scratch ───
    # Rank aspects from weakest to strongest
    raw_scores = result.get("raw_scores", {})
    sorted_aspects = sorted(raw_scores.items(), key=lambda x: x[1][0])
    
    # Build structured fallback tips
    fallback_saran = {
        "Akademik": f"{user_name} dapat meningkatkan kualitas tugas akhir dan presentasi dengan lebih banyak belajar dan praktik secara teratur.",
        "Finansial": f"Lengkapi data kondisi finansial dan kumpulkan dokumen pendukung seperti SKTM atau bukti bantuan sosial untuk memperkuat profil.",
        "Non-Akademik": f"Berpartisipasi aktif dalam kompetisi lokal atau nasional untuk mengasah kemampuan dan mencari pengalaman baru.",
        "Sertifikat": f"Siapkan surat rekomendasi dari guru/dosen, CV yang rapi, dan sertifikat keahlian khusus yang relevan.",
        "Motivasi": f"Tuliskan dengan jelas tujuan studi dan karir masa depan agar lebih meyakinkan penyeleksi beasiswa.",
    }
    
    # Take 3 weakest
    top3_weakest = sorted_aspects[:3]
    
    # Build ringkasan with user name
    ringkasan = f"{user_name} memiliki beberapa kelebihan yang bisa dimanfaatkan, namun masih memerlukan perbaikan dalam beberapa aspek untuk meningkatkan kesiapan beasiswa."
    
    langkah_lines = []
    for i, (aspect, _) in enumerate(top3_weakest, 1):
        saran = fallback_saran.get(aspect, "Perkuat aspek ini untuk meningkatkan skor kesiapanmu.")
        langkah_lines.append(f"{i}. **{aspect}**: {saran}")
    
    return f"Ringkasan Evaluasi:\n{ringkasan}\n\nLangkah Peningkatan:\n" + "\n\n".join(langkah_lines)

@app.post("/api/readiness", response_model=ReadinessResponse)
def get_readiness_score(profile: ReadinessProfile):
    try:
        result = _calculate_readiness(profile)
        weakest = result["weakest"]
        user_name = profile.user_name if profile.user_name and profile.user_name != "Pengguna" else "Pengguna"
        # Get first name for prompt
        first_name = user_name.split()[0] if user_name else "Pengguna"

        # Rank aspects from weakest to strongest for prompt
        raw_scores = result.get("raw_scores", {})
        sorted_aspects = sorted(raw_scores.items(), key=lambda x: x[1][0])
        top3_names = [a[0] for a in sorted_aspects[:3]]

        # ─── Prompt Engineering: Structured Tips Format ───
        prompt = f"""Kamu adalah mentor beasiswa di aplikasi CaBe (Cari Beasiswa). Nama pengguna: {first_name}.

Buatkan evaluasi dan tips peningkatan untuk {first_name} dengan format PERSIS berikut:

Ringkasan Evaluasi:
{first_name} memiliki beberapa kelebihan seperti [sebutkan 1-2 kelebihan], namun masih memerlukan perbaikan dalam [sebutkan area lemah].

Langkah Peningkatan:
1. **{top3_names[0]}**: [Tulis 1-2 kalimat saran spesifik dan memotivasi].

2. **{top3_names[1]}**: [Tulis 1-2 kalimat saran spesifik dan memotivasi].

3. **{top3_names[2]}**: [Tulis 1-2 kalimat saran spesifik dan memotivasi].

Aturan KETAT:
- HARUS ada tepat 3 langkah peningkatan, TIDAK BOLEH kurang.
- JANGAN menyebutkan angka skor, rumus, atau perhitungan apapun.
- Gunakan bahasa ramah dan memotivasi.
- JANGAN mengubah format di atas."""

        messages = [
            {"role": "system", "content": "Kamu adalah mentor beasiswa yang suportif. Kamu SELALU menjawab dengan format: Ringkasan Evaluasi lalu Langkah Peningkatan dengan tepat 3 item bernomor. Setiap item harus lengkap dan bermakna. JANGAN pernah memotong atau menghilangkan item."},
            {"role": "user", "content": prompt}
        ]
        text = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
        model_inputs = tokenizer([text], return_tensors="pt").to(model.device)
        generated_ids = model.generate(model_inputs.input_ids, max_new_tokens=500, temperature=0.4, do_sample=True)
        generated_ids = [output_ids[len(input_ids):] for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)]
        tips_text = tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0].strip()

        # ─── Post-process: Clean & Ensure Consistent Format ───
        tips_text = _clean_tips_format(tips_text, weakest, result, user_name)

        return ReadinessResponse(
            total_score=result["total"],
            skor_akademik=result["skor_akademik"],
            skor_finansial=result["skor_finansial"],
            skor_non_akademik=result["skor_non_akademik"],
            skor_sertifikat=result["skor_sertifikat"],
            skor_motivasi=result["skor_motivasi"],
            label=result["label"],
            tips=tips_text,
        )
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
