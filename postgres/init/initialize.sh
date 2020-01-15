createuser -U postgres --superuser dejima
psql -U postgres -c "alter user dejima with password 'barfoo'"

bx_setup_file_dir="/etc/bx_setup/$PEER_NAME"
bx_setup_files=$(find $bx_setup_file_dir -maxdepth 1 -type f -name *.sql | sort)
for file in $bx_setup_files;
do
  psql -f $file
  echo "psql -f $file : completed"
done
