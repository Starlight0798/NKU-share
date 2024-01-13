# Utility for transcript generation

N=$1

for i in $(seq 1 $N); do
    if [ $[RANDOM%10] -lt 1 ]; then
        echo "$RANDOM$RANDOM$RANDOM $RANDOM$RANDOM$RANDOM";
    else
        echo "$RANDOM$RANDOM$RANDOM";
    fi
done
