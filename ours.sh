#/bin/bash

# CIL CONFIG
NOTE="final_cifar100_sigma10_ours_freeze_ver4_real_interval10_freeze_1e5_unfreeze_1e3_val_per_100" # Short description of the experiment. (WARNING: logs/results with the same note will be overwritten!)
MODE="ours"
DATASET="cifar100" # cifar10, cifar100, tinyimagenet, imagenet
SIGMA=10
REPEAT=1
INIT_CLS=100
GPU_TRANSFORM="--gpu_transform"
HUMAN_TRAINING="False"
USE_AMP="--use_amp"
SEEDS="1 2 3"
AVG_PROB="0.4"
RECENT_RATIO="0.8"
USE_CLASS_BALANCING="True"
LOSS_BALANCING_OPTION="reverse_class_weight"
WEIGHT_METHOD="count_important"
WEIGHT_OPTION="loss"
KLASS_WARMUP="300"
KLASS_TRAIN_WARMUP="50"
T="8"
CURRICULUM_OPTION="class_acc"
VERSION="ver4"
INTERVAL=10
THRESHOLD="1e-5"
UNFREEZE_THRESHOLD="1e-3"


if [ "$DATASET" == "cifar10" ]; then
    MEM_SIZE=50000 ONLINE_ITER=1
    MODEL_NAME="resnet18" VAL_PERIOD=100 EVAL_PERIOD=100
    BATCHSIZE=16; LR=3e-4 OPT_NAME="adam" SCHED_NAME="default" IMP_UPDATE_PERIOD=1

elif [ "$DATASET" == "cifar100" ]; then
    MEM_SIZE=50000 ONLINE_ITER=0.75
    MODEL_NAME="resnet18" VAL_PERIOD=100 EVAL_PERIOD=100 
    BATCHSIZE=16; LR=3e-4 OPT_NAME="adam" SCHED_NAME="default" IMP_UPDATE_PERIOD=1

elif [ "$DATASET" == "tinyimagenet" ]; then
    MEM_SIZE=4000 ONLINE_ITER=3
    MODEL_NAME="resnet18" EVAL_PERIOD=100
    BATCHSIZE=32; LR=3e-4 OPT_NAME="adam" SCHED_NAME="default" IMP_UPDATE_PERIOD=1

elif [ "$DATASET" == "imagenet" ]; then
    MEM_SIZE=20000 ONLINE_ITER=0.25
    MODEL_NAME="resnet18" EVAL_PERIOD=1000
    BATCHSIZE=256; LR=3e-4 OPT_NAME="adam" SCHED_NAME="default" IMP_UPDATE_PERIOD=10

else
    echo "Undefined setting"
    exit 1
fi

for RND_SEED in $SEEDS
do
    CUDA_VISIBLE_DEVICES=6 nohup python main.py --mode $MODE --loss_balancing_option $LOSS_BALANCING_OPTION \
    --dataset $DATASET --T $T --use_class_balancing $USE_CLASS_BALANCING --klass_train_warmup $KLASS_TRAIN_WARMUP \
    --sigma $SIGMA --repeat $REPEAT --init_cls $INIT_CLS --weight_method $WEIGHT_METHOD \
    --rnd_seed $RND_SEED --weight_option $WEIGHT_OPTION --klass_warmup $KLASS_WARMUP --threshold $THRESHOLD \
    --model_name $MODEL_NAME --opt_name $OPT_NAME --sched_name $SCHED_NAME --version $VERSION --unfreeze_threshold $UNFREEZE_THRESHOLD \
    --lr $LR --batchsize $BATCHSIZE --recent_ratio $RECENT_RATIO --avg_prob $AVG_PROB --interval $INTERVAL \
    --memory_size $MEM_SIZE $GPU_TRANSFORM --online_iter $ONLINE_ITER --curriculum_option $CURRICULUM_OPTION \
    --note $NOTE --val_period $VAL_PERIOD --eval_period $EVAL_PERIOD --imp_update_period $IMP_UPDATE_PERIOD $USE_AMP &
done
