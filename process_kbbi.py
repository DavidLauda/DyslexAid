import json
import urllib.request
import os

url = 'https://raw.githubusercontent.com/dyazincahya/KBBI-SQL-database/main/dictionary__JSON.json'
temp_file = 'temp_dictionary.json'

print("Mendownload data dari GitHub...")
urllib.request.urlretrieve(url, temp_file)

print("Memuat JSON...")
with open(temp_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Total entri awal: {len(data['dictionary'])}")

# 1. Filter type == 2 (bersih) dan 2. Deduplikasi
cleaned_dict = {}
for item in data['dictionary']:
    # Beberapa field bisa integer atau string, kita cek str()
    if str(item.get('type', '')) == '2':
        word = item.get('word', '').strip()
        if word and word not in cleaned_dict:
            cleaned_dict[word] = item.get('arti', '')

print(f"Total entri setelah dibersihkan (type 2 & deduplikasi): {len(cleaned_dict)}")

# Bikin list untuk disimpan
full_list = [{"kata": k, "arti": v} for k, v in cleaned_dict.items()]

# Simpan full dataset
os.makedirs('assets', exist_ok=True)
full_path = os.path.join('assets', 'kbbi_full.json')
with open(full_path, 'w', encoding='utf-8') as f:
    json.dump(full_list, f, ensure_ascii=False)
print(f"Berhasil menyimpan {len(full_list)} kata ke {full_path}")

# Filter untuk dataset ringan (< 50rb)
# Hapus frasa (mengandung spasi) dan kata hubung/gabungan (mengandung strip)
subset_list = [item for item in full_list if ' ' not in item['kata'] and '-' not in item['kata']]

# Jika masih > 50000, potong berdasarkan panjang kata (yang pendek biasanya lebih umum)
if len(subset_list) > 50000:
    subset_list.sort(key=lambda x: len(x['kata']))
    subset_list = subset_list[:50000]
    # Setelah dipotong, kembalikan ke urutan alfabet (opsional)
    subset_list.sort(key=lambda x: x['kata'])

clean_path = os.path.join('assets', 'kbbi_clean.json')
with open(clean_path, 'w', encoding='utf-8') as f:
    json.dump(subset_list, f, ensure_ascii=False)
print(f"Berhasil menyimpan {len(subset_list)} kata (subset ringan) ke {clean_path}")

# Hapus file sementara
os.remove(temp_file)
print("Selesai!")
