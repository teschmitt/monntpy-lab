# ------------------------------ moNNT.py Startup -----------------------------

cd /app/moNNT.py
echo "Starting moNNT.py NNTP server"
nohup poetry run python main.py &>/dev/null &

# -----------------------------------------------------------------------------
