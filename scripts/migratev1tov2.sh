mkdir -p data/.cache data/StableDiffusion data/Codeformer data/GFPGAN data/ESRGAN data/BSRGAN data/RealESRGAN data/SwinIR data/LDSR

cp -f cache/models/model.ckpt data/StableDiffusion/model.ckpt

cp -f cache/models/LDSR.ckpt data/LDSR/model.ckpt
cp -f cache/models/LDSR.yaml data/LDSR/project.yaml

cp -f cache/models/RealESRGAN_x4plus.pth data/RealESRGAN/
cp -f cache/models/RealESRGAN_x4plus_anime_6B.pth data/RealESRGAN/

cp -rf cache/torch data/.cache/

mkdir -p data/.cache/huggingface/transformers/
cp -rf cache/transformers/* data/.cache/huggingface/transformers/

cp cache/custom-models/* data/StableDiffusion/

mkdir -p data/.cache/clip/
cp -f cache/weights/ViT-L-14.pt data/.cache/clip/

cp -f cache/weights/codeformer.pth data/Codeformer/codeformer-v0.1.0.pth

cp -f cache/weights/detection_Resnet50_Final.pth data/.cache/
cp -f cache/weights/parsing_parsenet.pth data/.cache/

echo Dont forget to run: docker compose --profile download up --build
echo the old cache folder can be deleted.
