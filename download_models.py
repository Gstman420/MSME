import gdown

files = {
    "demand_features.pkl": "1ykUTOP84Lsg-qhgDk1l-Yi3MxIdG9ors",
    "demand_model.pkl": "1qqkxTQSu5JfHHpH_p20aCb2Tu2dkYfR3",
    "price_features.pkl": "1JYl6pPrpcgDzPT-VcMKFgcJilTydAmAW",
    "price_model.pkl": "1flgZQ_zRsHcF1FoHlPnqG6rG35hu6log",
    "stock_features.pkl": "1Vv7XZtugkQAlmOKdYZscraug6vd2W_Am",
    "stock_model.pkl": "1uukR8ZsvQrPp2MfGPni6__h-7w_LDISH",
}

for file_name, file_id in files.items():
    url = f"https://drive.google.com/uc?id={file_id}"
    print(f"Downloading {file_name}...")
    gdown.download(url, file_name, quiet=False)

print("All model files downloaded successfully.")