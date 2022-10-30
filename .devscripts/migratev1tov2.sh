mkdir -p data/.cache data/StableDiffusion data/Codeformer data/GFPGAN data/ESRGAN data/BSRGAN data/RealESRGAN data/SwinIR data/LDSR data/embeddings

cp -vf cache/models/model.ckpt data/StableDiffusion/model.ckpt

cp -vf cache/models/LDSR.ckpt data/LDSR/model.ckpt
cp -vf cache/models/LDSR.yaml data/LDSR/project.yaml

cp -vf cache/models/RealESRGAN_x4plus.pth data/RealESRGAN/
cp -vf cache/models/RealESRGAN_x4plus_anime_6B.pth data/RealESRGAN/

cp -vrf cache/torch data/.cache/

mkdir -p data/.cache/huggingface/transformers/
cp -vrf cache/transformers/* data/.cache/huggingface/transformers/

cp -v cache/custom-models/* data/StableDiffusion/

mkdir -p data/.cache/clip/
cp -vf cache/weights/ViT-L-14.pt data/.cache/clip/

cp -vf cache/weights/codeformer.pth data/Codeformer/codeformer-v0.1.0.pth

cp -vf cache/weights/detection_Resnet50_Final.pth data/.cache/
cp -vf cache/weights/parsing_parsenet.pth data/.cache/

cp -v embeddings/* data/embeddings/

echo this script was created 10/2022
echo Dont forget to run: docker compose --profile download up --build
echo the cache and embeddings folders can be deleted, but its not necessary.
