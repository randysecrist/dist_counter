cd challenge
MIX_ENV=dev CHALLENGE_ID=$1 elixir --detached -S mix run --no-halt
# MIX_ENV=dev CHALLENGE_ID=$1 iex -S mix
cd ..
