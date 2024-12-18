# Define the base directory
BASE_DIR="Tests/SwoirTests/Fixtures/contracts"

# Iterate over each directory in the base directory
for dir in "$BASE_DIR"/*/; do
    # Check if it's a directory
    if [ -d "$dir" ]; then
        echo "Compiling in $dir"
        # Change to the directory and run nargo compile
        (cd "$dir" && nargo compile)
    fi
done
